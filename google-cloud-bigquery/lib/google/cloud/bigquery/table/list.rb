# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "delegate"

module Google
  module Cloud
    module BigQuery
      class Table
        ##
        # Table::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          # A hash of this page of results.
          attr_accessor :etag

          # Total number of tables in this collection.
          attr_accessor :total

          ##
          # @private Create a new Table::List with an array of tables.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of tables.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   tables = dataset.tables
          #   if tables.next?
          #     next_tables = tables.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of tables.
          #
          # @return [Table::List]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   tables = dataset.tables
          #   if tables.next?
          #     next_tables = tables.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            options = { token: token, max: @max }
            gapi = @service.list_tables @dataset_id, options
            self.class.from_gapi gapi, @service, @dataset_id, @max
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
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all tables. Default is no limit.
          # @yield [table] The block for accessing each table.
          # @yieldparam [Table] table The table object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each result by passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.tables.all do |table|
          #     puts table.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   all_names = dataset.tables.all.map do |table|
          #     table.name
          #   end
          #
          # @example Limit the number of API requests made:
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::BigQuery.new
          #   dataset = bigquery.dataset "my_dataset"
          #
          #   dataset.tables.all(request_limit: 10) do |table|
          #     puts table.name
          #   end
          #
          def all request_limit: nil
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for(:all, request_limit: request_limit)
            end
            results = self
            loop do
              results.each { |r| yield r }
              if request_limit
                request_limit -= 1
                break if request_limit < 0
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # @private New Table::List from a response object.
          def self.from_gapi gapi_list, service, dataset_id = nil, max = nil
            tables = List.new(Array(gapi_list.tables).map do |gapi_object|
              Table.from_gapi gapi_object, service
            end)
            tables.instance_variable_set :@token,      gapi_list.next_page_token
            tables.instance_variable_set :@etag,       gapi_list.etag
            tables.instance_variable_set :@total,      gapi_list.total_items
            tables.instance_variable_set :@service,    service
            tables.instance_variable_set :@dataset_id, dataset_id
            tables.instance_variable_set :@max,        max
            tables
          end

          protected

          ##
          # Raise an error unless an active service is available.
          def ensure_service!
            fail "Must have active connection" unless @service
          end
        end
      end
    end
  end
end
