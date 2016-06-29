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


require "json"

module Gcloud
  module Bigquery
    ##
    # InsertResponse
    class InsertResponse
      # @private
      def initialize rows, gapi
        @rows = rows
        @gapi = gapi
      end

      def success?
        error_count.zero?
      end

      def insert_count
        @rows.count - error_count
      end

      def error_count
        Array(@gapi.insert_errors).count
      end

      def insert_errors
        Array(@gapi.insert_errors).map do |ie|
          row = @rows[ie.index]
          errors = ie.errors.map { |e| JSON.parse e.to_json }
          InsertError.new row, errors
        end
      end

      def error_rows
        Array(@gapi.insert_errors).map do |ie|
          @rows[ie.index]
        end
      end

      def errors_for row
        ie = insert_errors.detect { |e| e.row == row }
        return ie.errors if ie
        []
      end

      # @private New InsertResponse from the inserted rows and a
      # Google::Apis::BigqueryV2::InsertAllTableDataResponse object.
      def self.from_gapi rows, gapi
        new rows, gapi
      end

      ##
      # InsertError
      class InsertError
        attr_reader :row
        attr_reader :errors

        # @private
        def initialize row, errors
          @row = row
          @errors = errors
        end
      end
    end
  end
end
