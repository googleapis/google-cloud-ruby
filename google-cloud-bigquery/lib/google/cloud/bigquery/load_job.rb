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
    module BigQuery
      ##
      # # LoadJob
      #
      # A {Job} subclass representing a load operation that may be performed
      # on a {Table}. A LoadJob instance is created when you call
      # {Table#load_job}.
      #
      # @see https://cloud.google.com/bigquery/loading-data
      #   Loading Data Into BigQuery
      # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
      #   reference
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::BigQuery.new
      #   dataset = bigquery.dataset "my_dataset"
      #
      #   gs_url = "gs://my-bucket/file-name.csv"
      #   load_job = dataset.load_job "my_new_table", gs_url do |schema|
      #     schema.string "first_name", mode: :required
      #     schema.record "cities_lived", mode: :repeated do |nested_schema|
      #       nested_schema.string "place", mode: :required
      #       nested_schema.integer "number_of_years", mode: :required
      #     end
      #   end
      #
      #   load_job.wait_until_done!
      #   load_job.done? #=> true
      #
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
        # which {Table#load_job} was invoked.
        #
        # @return [Table] A table instance.
        #
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
        #
        # @return [String] A string containing the character, such as `","`.
        #
        def delimiter
          @gapi.configuration.load.field_delimiter || ","
        end

        ##
        # The number of rows at the top of a CSV file that BigQuery will skip
        # when loading the data. The default value is 0. This property is useful
        # if you have header rows in the file that should be skipped.
        #
        # @return [Integer] The number of header rows at the top of a CSV file
        #   to skip.
        #
        def skip_leading_rows
          @gapi.configuration.load.skip_leading_rows || 0
        end

        ##
        # Checks if the character encoding of the data is UTF-8. This is the
        # default.
        #
        # @return [Boolean] `true` when the character encoding is UTF-8,
        #   `false` otherwise.
        #
        def utf8?
          val = @gapi.configuration.load.encoding
          return true if val.nil?
          val == "UTF-8"
        end

        ##
        # Checks if the character encoding of the data is ISO-8859-1.
        #
        # @return [Boolean] `true` when the character encoding is ISO-8859-1,
        #   `false` otherwise.
        #
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
        #
        # @return [String] A string containing the character, such as `"\""`.
        #
        def quote
          val = @gapi.configuration.load.quote
          val = "\"" if val.nil?
          val
        end

        ##
        # The maximum number of bad records that the load operation can ignore.
        # If the number of bad records exceeds this value, an error is returned.
        # The default value is `0`, which requires that all records be valid.
        #
        # @return [Integer] The maximum number of bad records.
        #
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
        #
        # @return [String] A string representing null value in a CSV file.
        #
        def null_marker
          val = @gapi.configuration.load.null_marker
          val = "" if val.nil?
          val
        end

        ##
        # Checks if quoted data sections may contain newline characters in a CSV
        # file. The default is `false`.
        #
        # @return [Boolean] `true` when quoted newlines are allowed, `false`
        #   otherwise.
        #
        def quoted_newlines?
          val = @gapi.configuration.load.allow_quoted_newlines
          val = false if val.nil?
          val
        end

        ##
        # Checks if BigQuery should automatically infer the options and schema
        # for CSV and JSON sources. The default is `false`.
        #
        # @return [Boolean] `true` when autodetect is enabled, `false`
        #   otherwise.
        #
        def autodetect?
          val = @gapi.configuration.load.autodetect
          val = false if val.nil?
          val
        end

        ##
        # Checks if the format of the source data is [newline-delimited
        # JSON](http://jsonlines.org/). The default is `false`.
        #
        # @return [Boolean] `true` when the source format is
        #   `NEWLINE_DELIMITED_JSON`, `false` otherwise.
        #
        def json?
          val = @gapi.configuration.load.source_format
          val == "NEWLINE_DELIMITED_JSON"
        end

        ##
        # Checks if the format of the source data is CSV. The default is `true`.
        #
        # @return [Boolean] `true` when the source format is `CSV`, `false`
        #   otherwise.
        #
        def csv?
          val = @gapi.configuration.load.source_format
          return true if val.nil?
          val == "CSV"
        end

        ##
        # Checks if the source data is a Google Cloud Datastore backup.
        #
        # @return [Boolean] `true` when the source format is `DATASTORE_BACKUP`,
        #   `false` otherwise.
        #
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
        #
        # @return [Boolean] `true` when jagged rows are allowed, `false`
        #   otherwise.
        #
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
        #
        # @return [Boolean] `true` when unknown values are ignored, `false`
        #   otherwise.
        #
        def ignore_unknown_values?
          val = @gapi.configuration.load.ignore_unknown_values
          val = false if val.nil?
          val
        end

        ##
        # The schema for the destination table. The schema can be omitted if the
        # destination table already exists, or if you're loading data from
        # Google Cloud Datastore.
        #
        # The returned object is frozen and changes are not allowed. Use
        # {Table#schema} to update the schema.
        #
        # @return [Schema, nil] A schema object, or `nil`.
        #
        def schema
          Schema.from_gapi(@gapi.configuration.load.schema).freeze
        end

        ##
        # The number of source data files in the load job.
        #
        # @return [Integer] The number of source files.
        #
        def input_files
          Integer @gapi.statistics.load.input_files
        rescue
          nil
        end

        ##
        # The number of bytes of source data in the load job.
        #
        # @return [Integer] The number of bytes.
        #
        def input_file_bytes
          Integer @gapi.statistics.load.input_file_bytes
        rescue
          nil
        end

        ##
        # The number of rows that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        #
        # @return [Integer] The number of rows that have been loaded.
        #
        def output_rows
          Integer @gapi.statistics.load.output_rows
        rescue
          nil
        end

        ##
        # The number of bytes that have been loaded into the table. While an
        # import job is in the running state, this value may change.
        #
        # @return [Integer] The number of bytes that have been loaded.
        #
        def output_bytes
          Integer @gapi.statistics.load.output_bytes
        rescue
          nil
        end
      end
    end
  end
end
