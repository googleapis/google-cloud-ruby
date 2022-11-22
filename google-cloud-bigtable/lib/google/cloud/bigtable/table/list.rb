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


module Google
  module Cloud
    module Bigtable
      class Table
        ##
        # Table::List is a special-case array with additional
        # values.
        #
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # The gRPC page enumerable object.
          attr_accessor :grpc

          # @private
          # Creates a new Table::List with an array of table instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of tables.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   tables = bigtable.tables "my-instance"
          #   if tables.next?
          #     next_tables = tables.next
          #   end
          #
          def next?
            grpc.next_page?
          end

          ##
          # Retrieves the next page of tables.
          #
          # @return [Table::List] The list of table instances.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   tables = bigtable.tables "my-instance"
          #   if tables.next?
          #     next_tables = tables.next
          #   end
          #
          def next
            ensure_grpc!

            return nil unless next?
            grpc.next_page
            self.class.from_grpc grpc, service
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved (unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call). Use with caution.
          #
          # @yield [table] The block for accessing each table instance.
          # @yieldparam [Table] table The table instance object.
          #
          # @return [Enumerator,nil] An enumerator is returned if no block is given, otherwise `nil`.
          #
          # @example Iterating each table by passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   bigtable.tables("my-instance").all do |table|
          #     puts table.table_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   all_table_ids = bigtable.tables("my-instance").all.map do |table|
          #     puts table.table_id
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

          # @private
          # New Table::List from a Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::Table> object.
          #
          def self.from_grpc grpc, service
            tables = List.new(Array(grpc.response.tables).map do |table|
              Table.from_grpc table, service, view: :NAME_ONLY
            end)
            tables.grpc = grpc
            tables.service = service
            tables
          end

          protected

          # @private
          #
          # Raises an error unless an active grpc call is available.
          #
          def ensure_grpc!
            raise "Must have grpc call" unless grpc
          end
        end
      end
    end
  end
end
