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
        @insert_count ||= @rows.count - error_count
      end

      def error_count
        @error_count ||= Array(@gapi["insertErrors"]).count
      end

      def insert_errors
        @insert_errors ||= begin
          Array(@gapi["insertErrors"]).map do |ie|
            row = @rows[ie["index"]]
            errors = ie["errors"]
            InsertError.new row, errors
          end
        end
      end

      def error_rows
        @error_rows ||= begin
          Array(@gapi["insertErrors"]).map do |ie|
            @rows[ie["index"]]
          end
        end
      end

      def errors_for row
        ie = insert_errors.detect { |e| e.row == row }
        return ie.errors if ie
        []
      end

      # @private
      def self.from_gapi rows, gapi
        gapi = gapi.to_hash if gapi.respond_to? :to_hash
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
