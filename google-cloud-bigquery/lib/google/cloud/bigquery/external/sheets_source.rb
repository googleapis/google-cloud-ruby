# Copyright 2021 Google LLC
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


require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      module External
        ##
        # # SheetsSource
        #
        # {External::SheetsSource} is a subclass of {External::DataSource} and
        # represents a Google Sheets external data source that can be queried
        # from directly, even though the data is not stored in BigQuery. Instead
        # of loading or streaming the data, this object references the external
        # data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
        #   sheets_table = bigquery.external sheets_url do |sheets|
        #     sheets.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: sheets_table }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        class SheetsSource < External::DataSource
          ##
          # @private Create an empty SheetsSource object.
          def initialize
            super
            @gapi.google_sheets_options = Google::Apis::BigqueryV2::GoogleSheetsOptions.new
          end

          ##
          # The number of rows at the top of a sheet that BigQuery will skip
          # when reading the data. The default value is `0`.
          #
          # This property is useful if you have header rows that should be
          # skipped. When `autodetect` is on, behavior is the following:
          #
          # * `nil` - Autodetect tries to detect headers in the first row. If
          #   they are not detected, the row is read as data. Otherwise data is
          #   read starting from the second row.
          # * `0` - Instructs autodetect that there are no headers and data
          #   should be read starting from the first row.
          # * `N > 0` - Autodetect skips `N-1` rows and tries to detect headers
          #   in row `N`. If headers are not detected, row `N` is just skipped.
          #   Otherwise row `N` is used to extract column names for the detected
          #   schema.
          #
          # @return [Integer]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.skip_leading_rows = 1
          #   end
          #
          #   sheets_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows
            @gapi.google_sheets_options.skip_leading_rows
          end

          ##
          # Set the number of rows at the top of a sheet that BigQuery will skip
          # when reading the data.
          #
          # @param [Integer] row_count New skip_leading_rows value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.skip_leading_rows = 1
          #   end
          #
          #   sheets_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows= row_count
            frozen_check!
            @gapi.google_sheets_options.skip_leading_rows = row_count
          end

          ##
          # Range of a sheet to query from. Only used when non-empty. Typical
          # format: `{sheet_name}!{top_left_cell_id}:{bottom_right_cell_id}`.
          #
          # @return [String] Range of a sheet to query from.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.range = "sheet1!A1:B20"
          #   end
          #
          #   sheets_table.range #=> "sheet1!A1:B20"
          #
          def range
            @gapi.google_sheets_options.range
          end

          ##
          # Set the range of a sheet to query from. Only used when non-empty.
          # Typical format:
          # `{sheet_name}!{top_left_cell_id}:{bottom_right_cell_id}`.
          #
          # @param [String] new_range New range of a sheet to query from.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.range = "sheet1!A1:B20"
          #   end
          #
          #   sheets_table.range #=> "sheet1!A1:B20"
          #
          def range= new_range
            frozen_check!
            @gapi.google_sheets_options.range = new_range
          end
        end
      end
    end
  end
end
