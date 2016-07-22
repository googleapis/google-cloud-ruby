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
require "gcloud/bigquery/service"

module Gcloud
  module Bigquery
    ##
    # # Data
    #
    # Represents {Table} Data as a list of name/value pairs.
    # Also contains metadata such as `etag` and `total`.
    class Data < DelegateClass(::Array)
      ##
      # @private The {Table} object the data belongs to.
      attr_accessor :table

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      # @private
      def initialize arr = []
        @table = nil
        @gapi = {}
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
      # Whether there is a next page of data.
      #
      # @return [Boolean]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   table = dataset.table "my_table"
      #
      #   data = table.data
      #   if data.next?
      #     next_data = data.next
      #   end
      #
      def next
        return nil unless next?
        ensure_table!
        table.data token: token
      end

      ##
      # Retrieves all rows by repeatedly loading {#next} until {#next?} returns
      # `false`. Calls the given block once for each row, which is passed as the
      # parameter.
      #
      # An Enumerator is returned if no block is given.
      #
      # This method may make several API calls until all rows are retrieved. Be
      # sure to use as narrow a search criteria as possible. Please use with
      # caution.
      #
      # @param [Integer] request_limit The upper limit of API requests to make
      #   to load all data. Default is no limit.
      # @yield [row] The block for accessing each row of data.
      # @yieldparam [Hash] row The row object.
      #
      # @return [Enumerator]
      #
      # @example Iterating each rows by passing a block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   table = dataset.table "my_table"
      #
      #   table.data.all do |row|
      #     puts row["word"]
      #   end
      #
      # @example Using the enumerator by not passing a block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   table = dataset.table "my_table"
      #
      #   words = table.data.all.map do |row|
      #     row["word"]
      #   end
      #
      # @example Limit the number of API calls made:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   table = dataset.table "my_table"
      #
      #   table.data.all(request_limit: 10) do |row|
      #     puts row["word"]
      #   end
      #
      def all request_limit: nil
        request_limit = request_limit.to_i if request_limit
        return enum_for(:all, request_limit: request_limit) unless block_given?
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
      # Represents Table Data as a list of positional values (array of arrays).
      # No type conversion is made, e.g. numbers are formatted as strings.
      def raw
        Array(gapi.rows).map { |row| row.f.map(&:v) }
      end

      ##
      # @private New Data from a response object.
      def self.from_gapi gapi, table
        formatted_rows = format_rows gapi.rows, table.fields

        data = new formatted_rows
        data.table = table
        data.gapi = gapi
        data
      end

      # rubocop:disable all
      # Disabled rubocop because this implementation will not last.

      def self.format_rows rows, fields
        headers = Array(fields).map { |f| f.name }
        field_types = Array(fields).map { |f| f.type }

        Array(rows).map do |row|
          values = row.f.map { |f| f.v }
          formatted_values = format_values field_types, values
          Hash[headers.zip formatted_values]
        end
      end

      def self.format_values field_types, values
        field_types.zip(values).map do |type, value|
          begin
            if value.nil?
              nil
            elsif type == "INTEGER"
              Integer value
            elsif type == "FLOAT"
              Float value
            elsif type == "BOOLEAN"
              (value == "true" ? true : (value == "false" ? false : nil))
            else
              value
            end
          rescue
            value
          end
        end
      end
      # rubocop:enable all

      protected

      ##
      # Raise an error unless an active service is available.
      def ensure_table!
        fail "Must have active connection" unless table
      end
    end
  end
end
