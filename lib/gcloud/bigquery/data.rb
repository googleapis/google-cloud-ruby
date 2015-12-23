#--
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
        @gapi["kind"]
      end

      ##
      # A token used for paging results.
      def token
        @gapi["pageToken"]
      end

      # A hash of this page of results.
      def etag
        @gapi["etag"]
      end

      # The total number of rows in the complete table.
      def total
        @gapi["totalRows"]
      end

      ##
      # Is there a next page of data?
      def next?
        !token.nil?
      end

      def next
        return nil unless next?
        ensure_table!
        table.data token: token
      end

      ##
      # Represents Table Data as a list of positional values (array of arrays).
      # No type conversion is made, e.g. numbers are formatted as strings.
      def raw
        Array(gapi["rows"]).map { |row| row["f"].map { |f| f["v"] } }
      end

      ##
      # @private New Data from a response object.
      def self.from_response resp, table
        formatted_rows = format_rows resp.data["rows"], table.fields

        data = new formatted_rows
        data.table = table
        data.gapi = resp.data
        data
      end

      # rubocop:disable all
      # Disabled rubocop because this implementation will not last.

      def self.format_rows rows, fields
        headers = fields.map { |f| f["name"] }
        field_types = fields.map { |f| f["type"] }

        Array(rows).map do |row|
          values = row["f"].map { |f| f["v"] }
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
      # Raise an error unless an active connection is available.
      def ensure_table!
        fail "Must have active connection" unless table
      end
    end
  end
end
