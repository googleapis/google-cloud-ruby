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
    # = Load Job
    class LoadJob < Job
      def sources
        Array config["load"]["sourceUris"]
      end

      def destination
        table = config["load"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      def delimiter
        val = @gapi["configuration"]["load"]["fieldDelimiter"]
        val = "," if val.nil?
        val
      end

      def skip_leading_rows
        val = @gapi["configuration"]["load"]["skipLeadingRows"]
        val = 0 if val.nil?
        val
      end

      def utf8?
        val = @gapi["configuration"]["load"]["encoding"]
        return true if val.nil?
        val == "UTF-8"
      end

      def iso8859_1?
        val = @gapi["configuration"]["load"]["encoding"]
        val == "ISO-8859-1"
      end

      def quote
        val = @gapi["configuration"]["load"]["quote"]
        val = "\"" if val.nil?
        val
      end

      def max_bad_records
        val = @gapi["configuration"]["load"]["maxBadRecords"]
        val = 0 if val.nil?
        val
      end

      def quoted_newlines?
        val = @gapi["configuration"]["load"]["allowQuotedNewlines"]
        val = true if val.nil?
        val
      end

      def json?
        val = @gapi["configuration"]["load"]["sourceFormat"]
        val == "NEWLINE_DELIMITED_JSON"
      end

      def csv?
        val = @gapi["configuration"]["load"]["sourceFormat"]
        return true if val.nil?
        val == "CSV"
      end

      def backup?
        val = @gapi["configuration"]["load"]["sourceFormat"]
        val == "DATASTORE_BACKUP"
      end

      def allow_jagged_rows?
        val = @gapi["configuration"]["load"]["allowJaggedRows"]
        val = false if val.nil?
        val
      end

      def ignore_unknown_values?
        val = @gapi["configuration"]["load"]["ignoreUnknownValues"]
        val = false if val.nil?
        val
      end

      def schema
        val = @gapi["configuration"]["load"]["schema"]
        val = {} if val.nil?
        val
      end
    end
  end
end
