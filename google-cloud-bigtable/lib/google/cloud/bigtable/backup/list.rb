# frozen_string_literal: true

# Copyright 2020 Google LLC
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


module Google
  module Cloud
    module Bigtable
      class Backup
        ##
        # Backup::List is a special-case array with additional values.
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # The gRPC page enumerable object.
          attr_accessor :grpc

          # @private
          # Creates a new Backup::List with an array of backups.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of backups.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   cluster = instance.cluster "my-cluster"
          #
          #   backups = cluster.backups
          #
          #   if backups.next?
          #     next_backups = backups.next
          #   end
          #
          def next?
            grpc.next_page?
          end

          ##
          # Retrieves the next page of backups.
          #
          # @return [Backup::List] The list of backups.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   cluster = instance.cluster "my-cluster"
          #
          #   backups = cluster.backups
          #
          #   if backups.next?
          #     next_backups = backups.next
          #   end
          #
          def next
            ensure_grpc!

            return nil unless next?
            grpc.next_page
            self.class.from_grpc grpc, service
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until {#next?} returns `false`. Calls the given
          # block once for each result, which is passed as the argument to the block.
          #
          # An enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results are retrieved (unlike `#each`, for
          # example, which merely iterates over the results returned by a single API call). Use with caution.
          #
          # @yield [backup] The block for accessing each backup.
          # @yieldparam [Backup] backup The backup object.
          #
          # @return [Enumerator,nil] An enumerator is returned if no block is given, otherwise `nil`.
          #
          # @example Iterating each backup by passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   cluster = instance.cluster "my-cluster"
          #
          #   cluster.backups.all do |backup|
          #     puts backup.backup_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   instance = bigtable.instance "my-instance"
          #   cluster = instance.cluster "my-cluster"
          #
          #   all_backup_ids = cluster.backups.all.map(&:backup_id)
          #
          def all &block
            return enum_for :all unless block_given?

            results = self
            loop do
              results.each(&block)
              break unless next?
              grpc.next_page
              results = self.class.from_grpc grpc, service
            end
          end

          # @private
          # New Snapshot::List from a Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::Backup> object.
          # @param grpc [Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::Backup> ]
          # @param service [Google::Cloud::Bigtable::Service]
          # @return [Array<Google::Cloud::Bigtable::Backup>]
          def self.from_grpc grpc, service
            backups = List.new(
              Array(grpc.response.backups).map do |backup|
                Backup.from_grpc backup, service
              end
            )
            backups.grpc = grpc
            backups.service = service
            backups
          end

          protected

          # @private
          #
          # Raises an error if an active gRPC call is not available.
          def ensure_grpc!
            raise "Must have active gRPC call" unless grpc
          end
        end
      end
    end
  end
end
