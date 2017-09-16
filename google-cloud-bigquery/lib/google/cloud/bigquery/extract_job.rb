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


module Google
  module Cloud
    module Bigquery
      ##
      # # ExtractJob
      #
      # A {Job} subclass representing an export operation that may be performed
      # on a {Table}. A ExtractJob instance is created when you call
      # {Table#extract_job}.
      #
      # @see https://cloud.google.com/bigquery/exporting-data-from-bigquery
      #   Exporting Data From BigQuery
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      class ExtractJob < Job
        ##
        # The URI or URIs representing the Google Cloud Storage files to which
        # the data is exported.
        def destinations
          Array @gapi.configuration.extract.destination_uris
        end

        ##
        # The table from which the data is exported. This is the table upon
        # which {Table#extract_job} was called. Returns a {Table} instance.
        def source
          table = @gapi.configuration.extract.source_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # Checks if the export operation compresses the data using gzip. The
        # default is `false`.
        def compression?
          val = @gapi.configuration.extract.compression
          val == "GZIP"
        end

        ##
        # Checks if the destination format for the data is [newline-delimited
        # JSON](http://jsonlines.org/). The default is `false`.
        def json?
          val = @gapi.configuration.extract.destination_format
          val == "NEWLINE_DELIMITED_JSON"
        end

        ##
        # Checks if the destination format for the data is CSV. Tables with
        # nested or repeated fields cannot be exported as CSV. The default is
        # `true`.
        def csv?
          val = @gapi.configuration.extract.destination_format
          return true if val.nil?
          val == "CSV"
        end

        ##
        # Checks if the destination format for the data is
        # [Avro](http://avro.apache.org/). The default is `false`.
        def avro?
          val = @gapi.configuration.extract.destination_format
          val == "AVRO"
        end

        ##
        # The symbol the operation uses to delimit fields in the exported data.
        # The default is a comma (,).
        def delimiter
          val = @gapi.configuration.extract.field_delimiter
          val = "," if val.nil?
          val
        end

        ##
        # Checks if the exported data contains a header row. The default is
        # `true`.
        def print_header?
          val = @gapi.configuration.extract.print_header
          val = true if val.nil?
          val
        end

        ##
        # The count of files per destination URI or URI pattern specified in
        # {#destinations}. Returns an Array of values in the same order as the
        # URI patterns.
        def destinations_file_counts
          Array @gapi.statistics.extract.destination_uri_file_counts
        end

        ##
        # The count of files per destination URI or URI pattern specified in
        # {#destinations}. Returns a Hash with the URI patterns as keys and the
        # counts as values.
        def destinations_counts
          Hash[destinations.zip destinations_file_counts]
        end
      end
    end
  end
end
