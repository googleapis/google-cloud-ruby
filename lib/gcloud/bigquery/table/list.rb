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

module Gcloud
  module Bigquery
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
        # Create a new Table::List with an array of tables.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there is a next page of tables.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of tables.
        def next
          return nil unless next?
          ensure_connection!
          options = { token: token, max: @max }
          resp = @connection.list_tables @dataset_id, options
          if resp.success?
            self.class.from_response resp, @connection, @dataset_id, @max
          else
            fail ApiError.from_response(resp)
          end
        end

        ##
        # Retrieves all tables by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each result and cursor
        # combination, which are passed as parameters.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all log entries are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example Iterating each result by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.tables.all do |table|
        #     puts table.name
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   all_names = dataset.tables.all.map do |table|
        #     table.name
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.tables.all(max_api_calls: 10) do |table|
        #     puts table.name
        #   end
        #
        def all max_api_calls: nil
          max_api_calls = max_api_calls.to_i if max_api_calls
          unless block_given?
            return enum_for(:all, max_api_calls: max_api_calls)
          end
          results = self
          loop do
            results.each { |r| yield r }
            if max_api_calls
              max_api_calls -= 1
              break if max_api_calls < 0
            end
            break unless results.next?
            results = results.next
          end
        end

        ##
        # @private New Table::List from a response object.
        def self.from_response resp, conn, dataset_id = nil, max = nil
          tables = List.new(Array(resp.data["tables"]).map do |gapi_object|
            Table.from_gapi gapi_object, conn
          end)
          tables.instance_variable_set "@token", resp.data["nextPageToken"]
          tables.instance_variable_set "@etag",  resp.data["etag"]
          tables.instance_variable_set "@total", resp.data["totalItems"]
          tables.instance_variable_set "@connection", conn
          tables.instance_variable_set "@dataset_id", dataset_id
          tables.instance_variable_set "@max",        max
          tables
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_connection!
          fail "Must have active connection" unless @connection
        end
      end
    end
  end
end
