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


require "google/cloud/bigquery/service"

module Google
  module Cloud
    module Bigquery
      ##
      # # LoadJob
      #
      # A {Job} subclass representing a load operation that may be performed
      # on a {Table}. A LoadJob instance is created when you call
      # {Table#load_job}.
      #
      # @see https://cloud.google.com/bigquery/loading-data-into-bigquery
      #   Loading Data Into BigQuery
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      class LoadJob < Job
        ##
        # The URI or URIs representing the Google Cloud Storage files from which
        # the operation loads data.
        def sources
          Array @gapi.configuration.load.source_uris
        end

        ##
        # The table into which the operation loads data. This is the table on
        # which {Table#load_job} was invoked. Returns a {Table} instance.
        def destination
          table = @gapi.configuration.load.destination_table
          return nil unless table
          retrieve_table table.project_id,
                         table.dataset_id,
                         table.table_id
        end

        ##
        # The delimiter used between fields in the source data. The default is a
        # comma (,).
        def delimiter
          @gapi.configuration.load.field_delimiter || ","
        end

        ##
        # The number of header rows at the top of a CSV file to skip. The
        # default value is `0`.
        def skip_leading_rows
          @gapi.configuration.load.skip_leading_rows || 0
        end

        ##
        # Checks if the character encoding of the data is UTF-8. This is the
        # default.
        def utf8?
          val = @gapi.configuration.load.encoding
          return true if val.nil?
          val == "UTF-8"
        end

        ##
        # Checks if the character encoding of the data is ISO-8859-1.
        def iso8859_1?
          val = @gapi.configuration.load.encoding
          val == "ISO-8859-1"
        end

        ##
        # The value that is used to quote data sections in a CSV file. The
        # default value is a double-quote (`"`). If your data does not contain
        # quoted sections, the value should be an empty string. If your data
        # contains quoted newline characters, {#quoted_newlines?} should return
        # `true`.
        def quote
          val = @gapi.configuration.load.quote
          val = "\"" if val.nil?
          val
        end

        ##
        # The maximum number of bad records that the load operation can ignore.
        # If the number of bad records exceeds this value, an error is returned.
        # The default value is `0`, which requires that all records be valid.
        def max_bad_records
          val = @gapi.configuration.load.max_bad_records
          val = 0 if val.nil?
          val
        end

        ##
        # Specifies a string that represents a null value in a CSV file. For
        # example, if you specify `\N`, BigQuery interprets `\N` as a null value
        # when loading a CSV file. The default value is the empty string. If you
        # set this property to a custom value, BigQuery throws an error if an
        # empty string is present for all data types except for STRING and BYTE.
        # For STRING and BYTE columns, BigQuery interprets the empty string as
        # an empty value.
        def null_marker
          val = @gapi.configuration.load.null_marker
          val = "" if val.nil?
          val
        end

        ##
        # Checks if quoted data sections may contain newline characters in a CSV
        # file. The default is `false`.
        def quoted_newlines?
          val = @gapi.configuration.load.allow_quoted_newlines
          val = false if val.nil?
          val
        end

        ##
        # Checks if BigQuery should automatically infer the options and schema
        # for CSV and JSON sources. The default is `false`.
        def autodetect?
          val = @gapi.configuration.load.autodetect
          val = false if val.nil?
          val
        end

        ##
        # Checks if the format of the source data is [newline-delimited
        # JSON](http://jsonlines.org/). The default is `false`.
        def json?
          val = @gapi.configuration.load.source_format
          val == "NEWLINE_DELIMITED_JSON"
        end

        ##
        # Checks if the format of the source data is CSV. The default is `true`.
        def csv?
          val = @gapi.configuration.load.source_format
          return true if val.nil?
          val == "CSV"
        end

        ##
        # Checks if the source data is a Google Cloud Datastore backup.
        def backup?
          val = @gapi.configuration.load.source_format
          val == "DATASTORE_BACKUP"
        end

        ##
        # Checks if the load operation accepts rows that are missing trailing
        # optional columns. The missing values are treated as nulls. If `false`,
        # records with missing trailing columns are treated as bad records, and
        # if there are too many bad records, an error is returned. The default
        # value is `false`. Only applicable to CSV, ignored for other formats.
        def allow_jagged_rows?
          val = @gapi.configuration.load.allow_jagged_rows
          val = false if val.nil?
          val
        end

        ##
        # Checks if the load operation allows extra values that are not
        # represented in the table schema. If `true`, the extra values are
        # ignored. If `false`, records with extra columns are treated as bad
        # records, and if there are too many bad records, an invalid error is
        # returned. The default is `false`.
        def ignore_unknown_values?
          val = @gapi.configuration.load.ignore_unknown_values
          val = false if val.nil?
          val
        end

        ##
        # The schema for the data. Returns a hash. Can be empty if the table has
        # already has the correct schema (see {Table#schema}), or if the schema
        # can be inferred from the loaded data.
        def schema
          Schema.from_gapi(@gapi.configuration.load.schema).freeze
        end

        ##
        # The number of source files.
        def input_files
          Integer @gapi.statistics.load.input_files
        rescue
          nil
        end

        ##
        # The number of bytes of source data.
        def input_file_bytes
          Integer @gapi.statistics.load.input_file_bytes
        rescue
          nil
        end

        ##
        # The number of rows that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        def output_rows
          Integer @gapi.statistics.load.output_rows
        rescue
          nil
        end

        ##
        # The number of bytes that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        def output_bytes
          Integer @gapi.statistics.load.output_bytes
        rescue
          nil
        end
      end
    end
  end
end
