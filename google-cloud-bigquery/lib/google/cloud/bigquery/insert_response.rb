# Copyright 2015 Google LLC
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


require "json"

module Google
  module Cloud
    module Bigquery
      ##
      # InsertResponse
      #
      # Represents the response from BigQuery when data is inserted into a table
      # for near-immediate querying, without the need to complete a load
      # operation before the data can appear in query results. See
      # {Dataset#insert} and {Table#insert}.
      #
      # @see https://cloud.google.com/bigquery/streaming-data-into-bigquery
      #   Streaming Data Into BigQuery
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   rows = [
      #     { "first_name" => "Alice", "age" => 21 },
      #     { "first_name" => "Bob", "age" => 22 }
      #   ]
      #
      #   insert_response = dataset.insert "my_table", rows
      #
      class InsertResponse
        # @private
        def initialize rows, gapi
          @rows = rows
          @gapi = gapi
        end

        ##
        # Checks if the error count is zero, meaning that all of the rows were
        # inserted. Use {#insert_errors} to access the errors.
        #
        # @return [Boolean] `true` when the error count is zero, `false`
        #   otherwise.
        #
        def success?
          error_count.zero?
        end

        ##
        # The count of rows in the response, minus the count of errors for rows
        # that were not inserted.
        #
        # @return [Integer] The number of rows inserted.
        #
        def insert_count
          @rows.count - error_count
        end

        ##
        # The count of errors for rows that were not inserted.
        #
        # @return [Integer] The number of errors.
        #
        def error_count
          Array(@gapi.insert_errors).count
        end

        ##
        # The error objects for rows that were not inserted.
        #
        # @return [Array<InsertError>] An array containing error objects.
        #
        def insert_errors
          Array(@gapi.insert_errors).map do |ie|
            row = @rows[ie.index]
            errors = ie.errors.map { |e| JSON.parse e.to_json }
            InsertError.new ie.index, row, errors
          end
        end

        ##
        # The rows that were not inserted.
        #
        # @return [Array<Hash>] An array of hash objects containing the row
        #   data.
        #
        def error_rows
          Array(@gapi.insert_errors).map do |ie|
            @rows[ie.index]
          end
        end

        ##
        # Returns the error object for a row that was not inserted.
        #
        # @param [Hash] row A hash containing the data for a row.
        #
        # @return [InsertError, nil] An error object, or `nil` if no error is
        #   found in the response for the row.
        #
        def insert_error_for row
          insert_errors.detect { |e| e.row == row }
        end

        ##
        # Returns the error hashes for a row that was not inserted. Each error
        # hash contains the following keys: `reason`, `location`, `debugInfo`,
        # and `message`.
        #
        # @param [Hash] row A hash containing the data for a row.
        #
        # @return [Array<Hash>, nil] An array of error hashes, or `nil` if no
        #   errors are found in the response for the row.
        #
        def errors_for row
          ie = insert_error_for row
          return ie.errors if ie
          []
        end

        ##
        # Returns the index for a row that was not inserted.
        #
        # @param [Hash] row A hash containing the data for a row.
        #
        # @return [Integer, nil] An error object, or `nil` if no error is
        #   found in the response for the row.
        #
        def index_for row
          ie = insert_error_for row
          return ie.index if ie
          nil
        end

        # @private New InsertResponse from the inserted rows and a
        # Google::Apis::BigqueryV2::InsertAllTableDataResponse object.
        def self.from_gapi rows, gapi
          new rows, gapi
        end

        ##
        # InsertError
        #
        # Represents the errors for a row that was not inserted.
        #
        # @attr_reader [Integer] index The index of the row that error applies
        #   to.
        # @attr_reader [Hash] row The row that error applies to.
        # @attr_reader [Hash] errors Error information for the row indicated by
        #   the index property, with the following keys: `reason`, `location`,
        #   `debugInfo`, and `message`.
        #
        class InsertError
          attr_reader :index
          attr_reader :row
          attr_reader :errors

          # @private
          def initialize index, row, errors
            @index = index
            @row = row
            @errors = errors
          end
        end
      end
    end
  end
end
