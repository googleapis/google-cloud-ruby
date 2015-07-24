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

module Gcloud
  module Bigquery
    ##
    # Represents Table Data.
    class Data < DelegateClass(::Array)
      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

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

      def initialize arr = []
        @gapi = {}
        super arr
      end

      ##
      # New Data from a response object.
      def self.from_response resp, table #:nodoc:
        rows = Array resp.data["rows"]
        fields = table.gapi["schema"]["fields"]

        formatted_rows = format_rows rows, fields

        data = new formatted_rows
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
    end
  end
end
