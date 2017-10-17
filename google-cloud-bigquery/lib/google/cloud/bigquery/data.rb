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
      # Represents {Table} Data as a list of name/value pairs (hashes.)
      # Also contains metadata such as `etag` and `total`, and provides access
      # to the schema of the table from which the data was read.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   data = table.data
      #   puts "#{data.count} of #{data.total}"
      #   if data.next?
      #     next_data = data.next
      #   end
      #
      class Data < DelegateClass(::Array)
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The {Table} object the data belongs to.
        attr_accessor :table_gapi

        ##
        # @private The Google API Client object in JSON Hash.
        attr_accessor :gapi_json

        # @private
        def initialize arr = []
          @service = nil
          @table_gapi = nil
          @gapi_json = nil
          super arr
        end

        ##
        # The resource type of the API response.
        #
        # @return [String] The resource type.
        #
        def kind
          @gapi_json["kind"]
        end

        ##
        # An ETag hash for the page of results represented by the data instance.
        #
        # @return [String] The ETag hash.
        #
        def etag
          @gapi_json["etag"]
        end

        ##
        # A token used for paging results. Used by the data instance to retrieve
        # subsequent pages. See {#next}.
        #
        # @return [String] The pagination token.
        #
        def token
          @gapi_json["pageToken"]
        end

        ##
        # The total number of rows in the complete table.
        #
        # @return [Integer] The number of rows.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #   puts "#{data.count} of #{data.total}"
        #   if data.next?
        #     next_data = data.next
        #   end
        #
        def total
          Integer @gapi_json["totalRows"]
        rescue
          nil
        end

        ##
        # The schema of the table from which the data was read.
        #
        # The returned object is frozen and changes are not allowed. Use
        # {Table#schema} to update the schema.
        #
        # @return [Schema] A schema object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   schema = data.schema
        #   field = schema.field "name"
        #   field.required? #=> true
        #
        def schema
          Schema.from_gapi(@table_gapi.schema).freeze
        end

        ##
        # The fields of the data, obtained from the schema of the table from
        # which the data was read.
        #
        # @return [Array<Schema::Field>] An array of field objects.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   data.fields.each do |field|
        #     puts field.name
        #   end
        #
        def fields
          schema.fields
        end

        ##
        # The names of the columns in the data, obtained from the schema of the
        # table from which the data was read.
        #
        # @return [Array<Symbol>] An array of column names.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #
        #   data = table.data
        #
        #   data.headers.each do |header|
        #     puts header
        #   end
        #
        def headers
          schema.headers
        end

        ##
        # Whether there is a next page of data.
        #
        # @return [Boolean] `true` when there is a next page, `false` otherwise.
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
        # Retrieves the next page of data.
        #
        # @return [Data] A new instance providing the next page of data.
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
          data_json = service.list_tabledata_raw_json \
            @table_gapi.table_reference.dataset_id,
            @table_gapi.table_reference.table_id,
            token: token
          self.class.from_json data_json, @table_gapi, @service
        end

        ##
        # Retrieves all rows by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each row, which is
        # passed as the parameter.
        #
        # An enumerator is returned if no block is given.
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
        # @return [Enumerator] An enumerator providing access to all of the
        #   data.
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
        def self.from_json gapi_json, table_gapi, service
          formatted_rows = Convert.format_rows(gapi_json["rows"],
                                               table_gapi.schema.fields)

          data = new formatted_rows
          data.table_gapi = table_gapi
          data.gapi_json = gapi_json
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
