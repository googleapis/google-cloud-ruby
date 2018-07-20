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
          Google::Rpc::Code::ABORTED => true,
          Google::Rpc::Code::UNAVAILABLE => true
        }.freeze

        # @private
        RETRY_LIMIT = 3

        # @private
        #
        # Create mutate rows instance
        #
        # @param table [Google::Cloud::Bigtable::TableDataOperations]
        # @param entries [Array<Google::Cloud::Bigtable::MutationEntry>]
        #
        def initialize table, entries
          @table = table
          @entries = entries
        end

        # Apply mutations.
        #
        # @return [Array<Google::Bigtable::V2::MutateRowsResponse::Entry>]
        #
        def apply_mutations
          @req_entries = @entries.map(&:to_grpc)
          statuses = mutate_rows(@req_entries)

          # Collect retryable mutations indices
          indices = statuses.each_with_object([]) do |e, r|
            if @entries[e.index].retryable? && RETRYABLE_CODES[e.status.code]
              r << e.index
            end
          end

          return statuses if indices.empty?

          (RETRY_LIMIT - 1).times do
            break if indices.empty?
            indices = retry_entries(statuses, indices)
          end

          statuses
        end

        private

        # Mutate rows
        #
        # @param entries [Array<Google::Cloud::Bigtable::MutationEntry>]
        # @return [Array<Google::Bigtable::V2::MutateRowsResponse::Entry>]
        #
        def mutate_rows entries
          response = @table.client.mutate_rows(
            @table.path,
            entries,
            app_profile_id: @table.app_profile_id
          )
          response.each_with_object([]) do |res, statuses|
            statuses.concat(res.entries)
          end
        rescue Google::Gax::GaxError => e
          raise Google::Cloud::Error.from_error(e.cause)
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end

        # Collected failed entries, retry mutation and update status
        #
        # @param statuses [Array<Google::Bigtable::V2::MutateRowsResponse::Entry>]
        # @param indices [Array<Integer>]
        #   Retry entries position mapping list
        # @return [Array<Integer>]
        #   New list of failed entries positions
        #
        def retry_entries statuses, indices
          entries = indices.map { |i| @req_entries[i] }
          retry_statuses = mutate_rows(entries)

          retry_statuses.each_with_object([]) do |e, next_indices|
            next_indices << indices[e.index] if RETRYABLE_CODES[e.status.code]
            statuses[indices[e.index]].status = e.status
          end
        end
      end
    end
  end
end
