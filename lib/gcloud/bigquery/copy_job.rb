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
    # = CopyJob
    #
    # A {Job} subclass representing a copy operation that may be performed on a
    # {Table}. A CopyJob instance is created when you call {Table#copy}.
    #
    # @see https://cloud.google.com/bigquery/docs/tables#copyingtable Copying an
    #   Existing Table
    # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
    #   reference
    #
    class CopyJob < Job
      ##
      # The table from which data is copied. This is the table on
      # which {Table#copy} was called. Returns a {Table} instance.
      def source
        table = config["copy"]["sourceTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      ##
      # The table to which data is copied. Returns a {Table} instance.
      def destination
        table = config["copy"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      ##
      # Checks if the create disposition for the job is +CREATE_IF_NEEDED+,
      # which provides the following behavior: If the table does not exist,
      # the copy operation creates the table. This is the default.
      def create_if_needed?
        disp = config["copy"]["createDisposition"]
        disp == "CREATE_IF_NEEDED"
      end

      ##
      # Checks if the create disposition for the job is +CREATE_NEVER+, which
      # provides the following behavior: The table must already exist; if it
      # does not, an error is returned in the job result.
      def create_never?
        disp = config["copy"]["createDisposition"]
        disp == "CREATE_NEVER"
      end

      ##
      # Checks if the write disposition for the job is +WRITE_TRUNCATE+, which
      # provides the following behavior: If the table already exists, the copy
      # operation overwrites the table data.
      def write_truncate?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_TRUNCATE"
      end

      ##
      # Checks if the write disposition for the job is +WRITE_APPEND+, which
      # provides the following behavior: If the table already exists, the copy
      # operation appends the data to the table.
      def write_append?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_APPEND"
      end

      ##
      # Checks if the write disposition for the job is +WRITE_EMPTY+, which
      # provides the following behavior: If the table already exists and
      # contains data, the job will have an error. This is the default.
      def write_empty?
        disp = config["copy"]["writeDisposition"]
        disp == "WRITE_EMPTY"
      end
    end
  end
end
