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
    # = Copy Job
    class CopyJob < Job
      def source
        table = config["copy"]["sourceTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      def destination
        table = config["copy"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      def create_if_needed?
        disp = config["copy"]["createDisposition"]
        disp == "CREATE_IF_NEEDED"
      end

      def create_never?
        disp = config["copy"]["createDisposition"]
        disp == "CREATE_NEVER"
      end

      def write_truncate?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_TRUNCATE"
      end

      def write_append?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_APPEND"
      end

      def write_empty?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_EMPTY"
      end
    end
  end
end
