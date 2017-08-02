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
require "google/cloud/bigquery/service"

module Google
  module Cloud
    module Bigquery
      ##
      # # Data
      #
      # Represents {Table} Data as a list of name/value pairs.
      # Also contains metadata such as `etag` and `total`.
      class Data < DelegateClass(::Array)
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The {Table} object the data belongs to.
        attr_accessor :table_gapi

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        # @private
        def initialize arr = []
          @service = nil
          @table_gapi = nil
          @gapi = nil
          super arr
        end

        ##
        # The resource type of the API response.
        def kind
          @gapi.kind
        end

        ##
        # The etag.
        def etag
          @gapi.etag
        end

        ##
        # A token used for paging results.
        def token
          @gapi.page_token
        end

        # The total number of rows in the complete table.
        def total
          Integer @gapi.total_rows
        rescue
          nil
        end

        ##
        # The schema of the data.
        def schema
          Schema.from_gapi @table_gapi.schema
        end

        ##
        # The fields of the data.
        def fields
          schema.fields
        end

        ##
        # The name of the columns in the data.
        def headers
          schema.headers
        end

        ##
        # Whether there is a next page of data.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #   if data.next?
        #     next_data = data.next
        #   end
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of data.
        #
        # @return [Data]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #   if data.next?
        #     next_data = data.next
        #   end
        #
        def next
          return nil unless next?
          ensure_service!
          data_gapi = service.list_tabledata \
            @table_gapi.table_reference.dataset_id,
            @table_gapi.table_reference.table_id,
            token: token
          self.class.from_gapi data_gapi, @table_gapi, @service
        end

        ##
        # Retrieves all rows by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each row, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all rows are retrieved.
        # Be sure to use as narrow a search criteria as possible. Please use
        # with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all data. Default is no limit.
        # @yield [row] The block for accessing each row of data.
        # @yieldparam [Hash] row The row object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each rows by passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.data.all do |row|
        #     puts row[:word]
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   words = table.data.all.map do |row|
        #     row[:word]
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   table.data.all(request_limit: 10) do |row|
        #     puts row[:word]
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
        # @private New Data from a response object.
        def self.from_gapi gapi, table_gapi, service
          formatted_rows = Convert.format_rows(gapi.rows,
                                               table_gapi.schema.fields)

          data = new formatted_rows
          data.table_gapi = table_gapi
          data.gapi = gapi
          data.service = service
          data
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end
      end
    end
  end
end
