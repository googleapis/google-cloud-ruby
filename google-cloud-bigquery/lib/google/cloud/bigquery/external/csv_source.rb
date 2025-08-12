# Copyright 2021 Google LLC
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


require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      module External
        ##
        # # CsvSource
        #
        # {External::CsvSource} is a subclass of {External::DataSource} and
        # represents a CSV external data source that can be queried from
        # directly, such as Google Cloud Storage or Google Drive, even though
        # the data is not stored in BigQuery. Instead of loading or streaming
        # the data, this object references the external data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = bigquery.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: csv_table }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        class CsvSource < External::DataSource
          ##
          # @private Create an empty CsvSource object.
          def initialize
            super
            @gapi.csv_options = Google::Apis::BigqueryV2::CsvOptions.new
          end

          ##
          # Indicates if BigQuery should accept rows that are missing trailing
          # optional columns.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.jagged_rows = true
          #   end
          #
          #   csv_table.jagged_rows #=> true
          #
          def jagged_rows
            @gapi.csv_options.allow_jagged_rows
          end

          ##
          # Set whether BigQuery should accept rows that are missing trailing
          # optional columns.
          #
          # @param [Boolean] new_jagged_rows New jagged_rows value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.jagged_rows = true
          #   end
          #
          #   csv_table.jagged_rows #=> true
          #
          def jagged_rows= new_jagged_rows
            frozen_check!
            @gapi.csv_options.allow_jagged_rows = new_jagged_rows
          end

          ##
          # Indicates if BigQuery should allow quoted data sections that contain
          # newline characters in a CSV file.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.quoted_newlines = true
          #   end
          #
          #   csv_table.quoted_newlines #=> true
          #
          def quoted_newlines
            @gapi.csv_options.allow_quoted_newlines
          end

          ##
          # Set whether BigQuery should allow quoted data sections that contain
          # newline characters in a CSV file.
          #
          # @param [Boolean] new_quoted_newlines New quoted_newlines value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.quoted_newlines = true
          #   end
          #
          #   csv_table.quoted_newlines #=> true
          #
          def quoted_newlines= new_quoted_newlines
            frozen_check!
            @gapi.csv_options.allow_quoted_newlines = new_quoted_newlines
          end

          ##
          # The character encoding of the data.
          #
          # @return [String]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.encoding = "UTF-8"
          #   end
          #
          #   csv_table.encoding #=> "UTF-8"
          #
          def encoding
            @gapi.csv_options.encoding
          end

          ##
          # Set the character encoding of the data.
          #
          # @param [String] new_encoding New encoding value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.encoding = "UTF-8"
          #   end
          #
          #   csv_table.encoding #=> "UTF-8"
          #
          def encoding= new_encoding
            frozen_check!
            @gapi.csv_options.encoding = new_encoding
          end

          ##
          # Checks if the character encoding of the data is "UTF-8". This is the
          # default.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.encoding = "UTF-8"
          #   end
          #
          #   csv_table.encoding #=> "UTF-8"
          #   csv_table.utf8? #=> true
          #
          def utf8?
            return true if encoding.nil?
            encoding == "UTF-8"
          end

          ##
          # Checks if the character encoding of the data is "ISO-8859-1".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.encoding = "ISO-8859-1"
          #   end
          #
          #   csv_table.encoding #=> "ISO-8859-1"
          #   csv_table.iso8859_1? #=> true
          #
          def iso8859_1?
            encoding == "ISO-8859-1"
          end

          ##
          # The separator for fields in a CSV file.
          #
          # @return [String]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.delimiter = "|"
          #   end
          #
          #   csv_table.delimiter #=> "|"
          #
          def delimiter
            @gapi.csv_options.field_delimiter
          end

          ##
          # Set the separator for fields in a CSV file.
          #
          # @param [String] new_delimiter New delimiter value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.delimiter = "|"
          #   end
          #
          #   csv_table.delimiter #=> "|"
          #
          def delimiter= new_delimiter
            frozen_check!
            @gapi.csv_options.field_delimiter = new_delimiter
          end

          ##
          # The value that is used to quote data sections in a CSV file.
          #
          # @return [String]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.quote = "'"
          #   end
          #
          #   csv_table.quote #=> "'"
          #
          def quote
            @gapi.csv_options.quote
          end

          ##
          # Set the value that is used to quote data sections in a CSV file.
          #
          # @param [String] new_quote New quote value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.quote = "'"
          #   end
          #
          #   csv_table.quote #=> "'"
          #
          def quote= new_quote
            frozen_check!
            @gapi.csv_options.quote = new_quote
          end

          ##
          # The number of rows at the top of a CSV file that BigQuery will skip
          # when reading the data.
          #
          # @return [Integer]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.skip_leading_rows = 1
          #   end
          #
          #   csv_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows
            @gapi.csv_options.skip_leading_rows
          end

          ##
          # Set the number of rows at the top of a CSV file that BigQuery will
          # skip when reading the data.
          #
          # @param [Integer] row_count New skip_leading_rows value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.skip_leading_rows = 1
          #   end
          #
          #   csv_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows= row_count
            frozen_check!
            @gapi.csv_options.skip_leading_rows = row_count
          end

          ##
          # Specifies a string that represents a null value in a CSV file. For
          # example, if you specify `\N`, BigQuery interprets `\N` as a null value when
          # querying a CSV file. The default value is the empty string. If you set this
          # property to a custom value, BigQuery throws an error if an empty string is
          # present for all data types except for STRING and BYTE. For STRING and BYTE
          # columns, BigQuery interprets the empty string as an empty value.
          #
          # @return [String, nil] The null marker string. `nil` if not set.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.null_marker = "\N"
          #   end
          #
          #   csv_table.null_marker #=> "\N"
          #
          def null_marker
            @gapi.csv_options.null_marker
          end

          ##
          # Sets a string that represents a null value in a CSV file. For
          # example, if you specify `\N`, BigQuery interprets `\N` as a null value when
          # querying a CSV file. The default value is the empty string. If you set this
          # property to a custom value, BigQuery throws an error if an empty string is
          # present for all data types except for STRING and BYTE. For STRING and BYTE
          # columns, BigQuery interprets the empty string as an empty value.
          #
          # @param [String, nil] null_marker The null marker string. `nil` to unset.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.null_marker = "\N"
          #   end
          #
          #   csv_table.null_marker #=> "\N"
          #
          def null_marker= null_marker
            frozen_check!
            @gapi.csv_options.null_marker = null_marker
          end

          ##
          # The list of strings represented as SQL NULL value in a CSV file.
          # null_marker and null_markers can't be set at the same time. If null_marker is
          # set, null_markers has to be not set. If null_markers is set, null_marker has
          # to be not set. If both null_marker and null_markers are set at the same time,
          # a user error would be thrown. Any strings listed in null_markers, including
          # empty string would be interpreted as SQL NULL. This applies to all column
          # types.
          #
          # @return [Array<String>] The array of null marker strings.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.null_markers = ["\N", "NULL"]
          #   end
          #
          #   csv_table.null_markers #=> ["\N", "NULL"]
          #
          def null_markers
            @gapi.csv_options.null_markers || []
          end

          ##
          # Sets the list of strings represented as SQL NULL value in a CSV file.
          # null_marker and null_markers can't be set at the same time. If null_marker is
          # set, null_markers has to be not set. If null_markers is set, null_marker has
          # to be not set. If both null_marker and null_markers are set at the same time,
          # a user error would be thrown. Any strings listed in null_markers, including
          # empty string would be interpreted as SQL NULL. This applies to all column
          # types.
          #
          # @param [Array<String>] null_markers The array of null marker strings.
          #
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.null_markers = ["\N", "NULL"]
          #   end
          #
          #   csv_table.null_markers #=> ["\N", "NULL"]
          #
          def null_markers= null_markers
            frozen_check!
            @gapi.csv_options.null_markers = null_markers
          end

          # Controls the strategy used to match loaded columns to the schema.
          # If not set, a sensible default is chosen based on how the schema is
          # provided. If autodetect is used, then columns are matched by name.
          # Otherwise, columns are matched by position. This is done to keep the
          # behavior backward-compatible.
          #
          # Acceptable values are:
          # - `POSITION`: matches by position. Assumes columns are ordered the
          #   same way as the schema.
          # - `NAME`: matches by name. Reads the header row as column names and
          #   reorders columns to match the schema.
          #
          # @return [String, nil] The source column match value. `nil` if not set.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.source_column_match = "NAME"
          #   end
          #
          #   csv_table.source_column_match #=> "NAME"
          #
          def source_column_match
            @gapi.csv_options.source_column_match
          end

          # Sets the strategy used to match loaded columns to the schema.
          # If not set, a sensible default is chosen based on how the schema is
          # provided. If autodetect is used, then columns are matched by name.
          # Otherwise, columns are matched by position. This is done to keep the
          # behavior backward-compatible. Optional.
          #
          # Acceptable values are:
          # - `POSITION`: matches by position. Assumes columns are ordered the
          #   same way as the schema.
          # - `NAME`: matches by name. Reads the header row as column names and
          #   reorders columns to match the schema.
          #
          # @param [String, nil] source_column_match The new source column match value. `nil` to unset.
          #
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.source_column_match = "NAME"
          #   end
          #
          #   csv_table.source_column_match #=> "NAME"
          #
          def source_column_match= source_column_match
            frozen_check!
            @gapi.csv_options.source_column_match = source_column_match
          end

          ##
          # The schema for the data.
          #
          # @param [Boolean] replace Whether to replace the existing schema with
          #   the new schema. If `true`, the fields will replace the existing
          #   schema. If `false`, the fields will be added to the existing
          #   schema. The default value is `false`.
          # @yield [schema] a block for setting the schema
          # @yieldparam [Schema] schema the object accepting the schema
          #
          # @return [Google::Cloud::Bigquery::Schema]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.schema do |schema|
          #       schema.string "name", mode: :required
          #       schema.string "email", mode: :required
          #       schema.integer "age", mode: :required
          #       schema.boolean "active", mode: :required
          #     end
          #   end
          #
          def schema replace: false
            @schema ||= Schema.from_gapi @gapi.schema
            if replace
              frozen_check!
              @schema = Schema.from_gapi
            end
            @schema.freeze if frozen?
            yield @schema if block_given?
            @schema
          end

          ##
          # Set the schema for the data.
          #
          # @param [Schema] new_schema The schema object.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_shema = bigquery.schema do |schema|
          #     schema.string "name", mode: :required
          #     schema.string "email", mode: :required
          #     schema.integer "age", mode: :required
          #     schema.boolean "active", mode: :required
          #   end
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url
          #   csv_table.schema = csv_shema
          #
          def schema= new_schema
            frozen_check!
            @schema = new_schema
          end

          ##
          # The fields of the schema.
          #
          # @return [Array<Schema::Field>] An array of field objects.
          #
          def fields
            schema.fields
          end

          ##
          # The names of the columns in the schema.
          #
          # @return [Array<Symbol>] An array of column names.
          #
          def headers
            schema.headers
          end

          ##
          # The types of the fields in the data in the schema, using the same
          # format as the optional query parameter types.
          #
          # @return [Hash] A hash with field names as keys, and types as values.
          #
          def param_types
            schema.param_types
          end

          ##
          # @private Google API Client object.
          def to_gapi
            @gapi.schema = @schema.to_gapi if @schema
            @gapi
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_table = super
            schema = Schema.from_gapi gapi.schema
            new_table.instance_variable_set :@schema, schema
            new_table
          end
        end
      end
    end
  end
end
