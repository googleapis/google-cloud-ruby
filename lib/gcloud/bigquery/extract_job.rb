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
    # = Extract Job
    class ExtractJob < Job
      def destinations
        Array config["extract"]["destinationUris"]
      end

      def source
        table = config["extract"]["sourceTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      def compression?
        val = config["extract"]["compression"]
        val == "GZIP"
      end

      def json?
        val = config["extract"]["destinationFormat"]
        val == "NEWLINE_DELIMITED_JSON"
      end

      def csv?
        val = config["extract"]["destinationFormat"]
        return true if val.nil?
        val == "CSV"
      end

      def avro?
        val = config["extract"]["destinationFormat"]
        val == "AVRO"
      end

      def delimiter
        val = config["extract"]["fieldDelimiter"]
        val = "," if val.nil?
        val
      end

      def print_header?
        val = config["extract"]["printHeader"]
        val = true if val.nil?
        val
      end

      def destinations_file_counts
        Array stats["extract"]["destinationUriFileCounts"]
      end

      def destinations_counts
        Hash[destinations.zip destinations_file_counts]
      end
    end
  end
end
