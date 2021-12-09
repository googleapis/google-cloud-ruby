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

# DO NOT EDIT: Unless you're fixing a P0/P1 and/or a security issue. This class
# is frozen to all new features from `google-cloud-spanner/v2.11.0` onwards.


require "delegate"

module Google
  module Cloud
    module Spanner
      class Backup
        ##
        # # List
        #
        # Google::Cloud::Spanner::Backup::List is a special case Array with
        # additional values.
        #
        # @deprecated Use the result of
        # {Google::Cloud::Spanner::Admin::Database#database_admin Client#list_backups}
        # instead.
        #
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # The gRPC page enumerable object.
          attr_accessor :grpc

          ##
          # @private Create a new Backup::List with an array of
          # Backup instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of backups.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instance = spanner.instance "my-instance"
          #   backups = instance.backups
          #
          #   if backups.next?
          #     next_backups = backups.next
          #   end
          #
          def next?
            grpc.next_page?
          end

          ##
          # Retrieve the next page of backups.
          #
          # @return [Google::Cloud::Spanner::Backup::List]
          #
          # @example
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instance = spanner.instance "my-instance"
          #   backups = instance.backups

          #   if backups.next?
          #     next_backups = backups.next
          #   end
          #
          def next
            ensure_service!

            return nil unless next?
            grpc.next_page
            self.class.from_grpc grpc, service
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @yield [backup] The block for accessing each backup.
          # @yieldparam [Google::Cloud::Spanner::Backup] backup The backup
          #   object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each backup by passing a block:
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instance = spanner.instance "my-instance"
          #   backups = instance.backups
          #
          #   backups.all do |backup|
          #     puts backup.backup_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instance = spanner.instance "my-instance"
          #   backups = instance.backups
          #
          #   all_backup_ids = backups.all.map do |backup|
          #     backup.backup_id
          #   end
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

          ##
          # @private
          # New Backup::List from a
          # `Gapic::PagedEnumerable<Google::Cloud::Spanner::Admin::Database::V1::Backup>`
          # object.
          def self.from_grpc grpc, service
            backups = List.new(Array(grpc.response.backups).map do |backup|
              Backup.from_grpc backup, service
            end)

            backups.grpc = grpc
            backups.service = service
            backups
          end

          protected

          ##
          # Raise an error unless an active service is available.
          def ensure_service!
            raise "Must have active connection" unless @service
          end
        end
      end
    end
  end
end
