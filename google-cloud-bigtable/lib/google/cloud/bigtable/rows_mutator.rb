# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/rpc/code_pb"
require "google/cloud/bigtable/mutation_entry"

module Google
  module Cloud
    module Bigtable
      # @private
      # # RowsMutator
      #
      # Retryable mutate rows helper
      #
      class RowsMutator
        # @private
        # Retryable status codes
        RETRYABLE_CODES = {
          Google::Rpc::Code::DEADLINE_EXCEEDED => true,
          Google::Rpc::Code::ABORTED           => true,
          Google::Rpc::Code::UNAVAILABLE       => true
        }.freeze

        # @private
        RETRY_LIMIT = 3

        # @private
        # The prefix for routing cookies. Used to dynamically find cookie
        # headers in metadata.
        COOKIE_KEY_PREFIX = "x-goog-cbt-cookie"

        #
        # Creates a mutate rows instance.
        #
        # @param table [Google::Cloud::Bigtable::TableDataOperations]
        # @param entries [Array<Google::Cloud::Bigtable::MutationEntry>]
        #
        def initialize table, entries
          @table = table
          @entries = entries
        end

        ##
        # Applies mutations.
        #
        # @return [Array<Google::Cloud::Bigtable::V2::MutateRowsResponse::Entry>]
        #
        def apply_mutations
          @req_entries = @entries.map(&:to_grpc)
          statuses, delay, cookies = mutate_rows @req_entries

          indices = statuses.each_with_object [] do |e, r|
            r << e.index if @entries[e.index].retryable? && RETRYABLE_CODES[e.status.code]
          end

          return statuses if indices.empty?

          RETRY_LIMIT.times do
            break if indices.empty?

            sleep delay if delay

            indices, delay, cookies = retry_entries statuses, indices, cookies
          end

          statuses
        end

        private

        ##
        # Mutates rows.
        #
        # @param entries [Array<Google::Cloud::Bigtable::MutationEntry>]
        # @param cookies [Hash]
        # @return [Array<Google::Cloud::Bigtable::V2::MutateRowsResponse::Entry>, Float|nil, Hash]
        #
        def mutate_rows entries, cookies = {}
          call_options = Gapic::CallOptions.new(metadata: cookies) unless cookies.empty?

          response = @table.service.mutate_rows(
            @table.path,
            entries,
            app_profile_id: @table.app_profile_id,
            call_options: call_options
          )
          [response.flat_map(&:entries), nil, cookies]
        rescue GRPC::BadStatus => e
          info = e.status_details.find { |d| d.is_a? Google::Rpc::RetryInfo }
          delay = if info&.retry_delay
                    info.retry_delay.seconds + (info.retry_delay.nanos / 1_000_000_000.0)
                  end

          cookies.merge!(e.metadata.select { |k, _| k.start_with? COOKIE_KEY_PREFIX })

          status = Google::Rpc::Status.new code: e.code, message: e.message
          statuses = entries.map.with_index do |_, i|
            Google::Cloud::Bigtable::V2::MutateRowsResponse::Entry.new(
              index: i,
              status: status
            )
          end
          [statuses, delay, cookies]
        end

        ##
        # Collects failed entries, retries mutation, and updates status.
        #
        # @param statuses [Array<Google::Cloud::Bigtable::V2::MutateRowsResponse::Entry>]
        # @param indices [Array<Integer>]
        # @param cookies [Hash]
        # @return [Array<Integer>, Float|nil, Hash]
        #
        def retry_entries statuses, indices, cookies
          entries = indices.map { |i| @req_entries[i] }
          retry_statuses, delay, cookies = mutate_rows entries, cookies

          next_indices = retry_statuses.each_with_object [] do |e, list|
            next_index = indices[e.index]
            statuses[next_index].status = e.status
            list << next_index if RETRYABLE_CODES[e.status.code]
          end
          [next_indices, delay, cookies]
        end
      end
    end
  end
end
