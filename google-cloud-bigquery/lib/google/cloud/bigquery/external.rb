# Copyright 2017 Google Inc. All rights reserved.
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


require "google/apis/bigquery_v2"
require "base64"

module Google
  module Cloud
    module Bigquery
      ##
      # # External
      #
      # Creates a new {External::DataSource} (or subclass) object that
      # represents the external data source that can be queried from directly,
      # even though the data is not stored in BigQuery. Instead of loading or
      # streaming the data, this object references the external data source.
      #
      # See {External::DataSource}, {External::CsvSource},
      # {External::JsonSource}, {External::SheetsSource},
      # {External::BigtableSource}
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
      #   data.each do |row|
      #     puts row[:name]
      #   end
      #
      module External
        ##
        # @private New External from URLs and format
        def self.from_urls urls, format = nil
          external_format = source_format_for urls, format
          if external_format.nil?
            fail ArgumentError, "Unable to determine external table format"
          end
          external_class = table_class_for external_format
          external_class.new.tap do |e|
            e.gapi.source_uris = Array(urls)
            e.gapi.source_format = external_format
          end
        end

        ##
        # @private Google API Client object.
        def self.from_gapi gapi
          external_format = source_format_for gapi.source_uris,
                                              gapi.source_format
          if external_format.nil?
            fail ArgumentError, "Unable to determine external table format"
          end
          external_class = table_class_for external_format
          external_class.from_gapi gapi
        end

        ##
        # @private Determine source_format from inputs
        def self.source_format_for urls, format
          val = { "csv"                    => "CSV",
                  "json"                   => "NEWLINE_DELIMITED_JSON",
                  "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
                  "sheets"                 => "GOOGLE_SHEETS",
                  "google_sheets"          => "GOOGLE_SHEETS",
                  "avro"                   => "AVRO",
                  "datastore"              => "DATASTORE_BACKUP",
                  "backup"                 => "DATASTORE_BACKUP",
                  "datastore_backup"       => "DATASTORE_BACKUP",
                  "bigtable"               => "BIGTABLE"
                }[format.to_s.downcase]
          return val unless val.nil?
          Array(urls).each do |url|
            return "CSV" if url.end_with? ".csv"
            return "NEWLINE_DELIMITED_JSON" if url.end_with? ".json"
            return "AVRO" if url.end_with? ".avro"
            return "DATASTORE_BACKUP" if url.end_with? ".backup_info"
            if url.start_with? "https://docs.google.com/spreadsheets/"
              return "GOOGLE_SHEETS"
            end
            if url.start_with? "https://googleapis.com/bigtable/projects/"
              return "BIGTABLE"
            end
          end
          nil
        end

        ##
        # @private Determine table class from source_format
        def self.table_class_for format
          case format
          when "CSV"                    then External::CsvSource
          when "NEWLINE_DELIMITED_JSON" then External::JsonSource
          when "GOOGLE_SHEETS"          then External::SheetsSource
          when "BIGTABLE"               then External::BigtableSource
          else
            # AVRO and DATASTORE_BACKUP
            External::DataSource
          end
        end

        ##
        # # DataSource
        #
        # External::DataSource and its subclasses represents an external data
        # source that can be queried from directly, even though the data is not
        # stored in BigQuery. Instead of loading or streaming the data, this
        # object references the external data source.
        #
        # The AVRO and Datastore Backup formats use {External::DataSource}. See
        # {External::CsvSource}, {External::JsonSource},
        # {External::SheetsSource}, {External::BigtableSource} for the other
        # formats.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   avro_url = "gs://bucket/path/to/data.avro"
        #   avro_table = bigquery.external avro_url do |avro|
        #     avro.autodetect = true
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: avro_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        class DataSource
          ##
          # @private The Google API Client object.
          attr_accessor :gapi

          ##
          # @private Create an empty Table object.
          def initialize
            @gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new
          end

          ##
          # The data format. For CSV files, specify "CSV". For Google sheets,
          # specify "GOOGLE_SHEETS". For newline-delimited JSON, specify
          # "NEWLINE_DELIMITED_JSON". For Avro files, specify "AVRO". For Google
          # Cloud Datastore backups, specify "DATASTORE_BACKUP". [Beta] For
          # Google Cloud Bigtable, specify "BIGTABLE".
          #
          # @return [String]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url
          #
          #   csv_table.format #=> "CSV"
          #
          def format
            @gapi.source_format
          end

          ##
          # Whether the data format is "CSV".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url
          #
          #   csv_table.format #=> "CSV"
          #   csv_table.csv? #=> true
          #
          def csv?
            @gapi.source_format == "CSV"
          end

          ##
          # Whether the data format is "NEWLINE_DELIMITED_JSON".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   json_url = "gs://bucket/path/to/data.json"
          #   json_table = bigquery.external json_url
          #
          #   json_table.format #=> "NEWLINE_DELIMITED_JSON"
          #   json_table.json? #=> true
          #
          def json?
            @gapi.source_format == "NEWLINE_DELIMITED_JSON"
          end

          ##
          # Whether the data format is "GOOGLE_SHEETS".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url
          #
          #   sheets_table.format #=> "GOOGLE_SHEETS"
          #   sheets_table.sheets? #=> true
          #
          def sheets?
            @gapi.source_format == "GOOGLE_SHEETS"
          end

          ##
          # Whether the data format is "AVRO".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   avro_url = "gs://bucket/path/to/data.avro"
          #   avro_table = bigquery.external avro_url
          #
          #   avro_table.format #=> "AVRO"
          #   avro_table.avro? #=> true
          #
          def avro?
            @gapi.source_format == "AVRO"
          end

          ##
          # Whether the data format is "DATASTORE_BACKUP".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   backup_url = "gs://bucket/path/to/data.backup_info"
          #   backup_table = bigquery.external backup_url
          #
          #   backup_table.format #=> "DATASTORE_BACKUP"
          #   backup_table.backup? #=> true
          #
          def backup?
            @gapi.source_format == "DATASTORE_BACKUP"
          end

          ##
          # Whether the data format is "BIGTABLE".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url
          #
          #   bigtable_table.format #=> "BIGTABLE"
          #   bigtable_table.bigtable? #=> true
          #
          def bigtable?
            @gapi.source_format == "BIGTABLE"
          end

          ##
          # The fully-qualified URIs that point to your data in Google Cloud.
          # For Google Cloud Storage URIs: Each URI can contain one '*' wildcard
          # character and it must come after the 'bucket' name. Size limits
          # related to load jobs apply to external data sources. For Google
          # Cloud Bigtable URIs: Exactly one URI can be specified and it has be
          # a fully specified and valid HTTPS URL for a Google Cloud Bigtable
          # table. For Google Cloud Datastore backups, exactly one URI can be
          # specified, and it must end with '.backup_info'. Also, the '*'
          # wildcard character is not allowed.
          #
          # @return [Array<String>]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url
          #
          #   csv_table.urls #=> ["gs://bucket/path/to/data.csv"]
          #
          def urls
            @gapi.source_uris
          end

          ##
          # Indicates if the schema and format options are detected
          # automatically.
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
          #     csv.autodetect = true
          #   end
          #
          #   csv_table.autodetect #=> true
          #
          def autodetect
            @gapi.autodetect
          end

          ##
          # Set whether to detect schema and format options automatically. Any
          # option specified explicitly will be honored.
          #
          # @param [Boolean] new_autodetect New autodetect value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.autodetect = true
          #   end
          #
          #   csv_table.autodetect #=> true
          #
          def autodetect= new_autodetect
            frozen_check!
            @gapi.autodetect = new_autodetect
          end

          ##
          # The compression type of the data source. Possible values include
          # `"GZIP"` and `nil`. The default value is `nil`. This setting is
          # ignored for Google Cloud Bigtable, Google Cloud Datastore backups
          # and Avro formats. Optional.
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
          #     csv.compression = "GZIP"
          #   end
          #
          #   csv_table.compression #=> "GZIP"
          def compression
            @gapi.compression
          end

          ##
          # Set the compression type of the data source. Possible values include
          # `"GZIP"` and `nil`. The default value is `nil`. This setting is
          # ignored for Google Cloud Bigtable, Google Cloud Datastore backups
          # and Avro formats. Optional.
          #
          # @param [String] new_compression New compression value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.compression = "GZIP"
          #   end
          #
          #   csv_table.compression #=> "GZIP"
          #
          def compression= new_compression
            frozen_check!
            @gapi.compression = new_compression
          end

          ##
          # Indicates if BigQuery should allow extra values that are not
          # represented in the table schema. If `true`, the extra values are
          # ignored. If `false`, records with extra columns are treated as bad
          # records, and if there are too many bad records, an invalid error is
          # returned in the job result. The default value is `false`.
          #
          # BigQuery treats trailing columns as an extra in `CSV`, named values
          # that don't match any column names in `JSON`. This setting is ignored
          # for Google Cloud Bigtable, Google Cloud Datastore backups and Avro
          # formats. Optional.
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
          #     csv.ignore_unknown = true
          #   end
          #
          #   csv_table.ignore_unknown #=> true
          #
          def ignore_unknown
            @gapi.ignore_unknown_values
          end

          ##
          # Set whether BigQuery should allow extra values that are not
          # represented in the table schema. If `true`, the extra values are
          # ignored. If `false`, records with extra columns are treated as bad
          # records, and if there are too many bad records, an invalid error is
          # returned in the job result. The default value is `false`.
          #
          # BigQuery treats trailing columns as an extra in `CSV`, named values
          # that don't match any column names in `JSON`. This setting is ignored
          # for Google Cloud Bigtable, Google Cloud Datastore backups and Avro
          # formats. Optional.
          #
          # @param [Boolean] new_ignore_unknown New ignore_unknown value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.ignore_unknown = true
          #   end
          #
          #   csv_table.ignore_unknown #=> true
          #
          def ignore_unknown= new_ignore_unknown
            frozen_check!
            @gapi.ignore_unknown_values = new_ignore_unknown
          end

          ##
          # The maximum number of bad records that BigQuery can ignore when
          # reading data. If the number of bad records exceeds this value, an
          # invalid error is returned in the job result. The default value is 0,
          # which requires that all records are valid. This setting is ignored
          # for Google Cloud Bigtable, Google Cloud Datastore backups and Avro
          # formats.
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
          #     csv.max_bad_records = 10
          #   end
          #
          #   csv_table.max_bad_records #=> 10
          #
          def max_bad_records
            @gapi.max_bad_records
          end

          ##
          # Set the maximum number of bad records that BigQuery can ignore when
          # reading data. If the number of bad records exceeds this value, an
          # invalid error is returned in the job result. The default value is 0,
          # which requires that all records are valid. This setting is ignored
          # for Google Cloud Bigtable, Google Cloud Datastore backups and Avro
          # formats.
          #
          # @param [Integer] new_max_bad_records New max_bad_records value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   csv_url = "gs://bucket/path/to/data.csv"
          #   csv_table = bigquery.external csv_url do |csv|
          #     csv.max_bad_records = 10
          #   end
          #
          #   csv_table.max_bad_records #=> 10
          #
          def max_bad_records= new_max_bad_records
            frozen_check!
            @gapi.max_bad_records = new_max_bad_records
          end

          ##
          # @private Google API Client object.
          def to_gapi
            @gapi
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_table = new
            new_table.instance_variable_set :@gapi, gapi
            new_table
          end

          protected

          def frozen_check!
            return unless frozen?
            fail ArgumentError, "Cannot modify external data source when frozen"
          end
        end

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
        #   data.each do |row|
        #     puts row[:name]
        #   end
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
          def fields
            schema.fields
          end

          ##
          # The names of the columns in the schema.
          #
          def headers
            schema.headers
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

        ##
        # # JsonSource
        #
        # {External::JsonSource} is a subclass of {External::DataSource} and
        # represents a JSON external data source that can be queried from
        # directly, such as Google Cloud Storage or Google Drive, even though
        # the data is not stored in BigQuery. Instead of loading or streaming
        # the data, this object references the external data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   json_url = "gs://bucket/path/to/data.json"
        #   json_table = bigquery.external json_url do |json|
        #     json.schema do |schema|
        #       schema.string "name", mode: :required
        #       schema.string "email", mode: :required
        #       schema.integer "age", mode: :required
        #       schema.boolean "active", mode: :required
        #     end
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: json_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        class JsonSource < External::DataSource
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
          #   json_url = "gs://bucket/path/to/data.json"
          #   json_table = bigquery.external json_url do |json|
          #     json.schema do |schema|
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
          #   json_shema = bigquery.schema do |schema|
          #     schema.string "name", mode: :required
          #     schema.string "email", mode: :required
          #     schema.integer "age", mode: :required
          #     schema.boolean "active", mode: :required
          #   end
          #
          #   json_url = "gs://bucket/path/to/data.json"
          #   json_table = bigquery.external json_url
          #   json_table.schema = json_shema
          #
          def schema= new_schema
            frozen_check!
            @schema = new_schema
          end

          ##
          # The fields of the schema.
          #
          def fields
            schema.fields
          end

          ##
          # The names of the columns in the schema.
          #
          def headers
            schema.headers
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

        ##
        # # SheetsSource
        #
        # {External::SheetsSource} is a subclass of {External::DataSource} and
        # represents a Google Sheets external data source that can be queried
        # from directly, even though the data is not stored in BigQuery. Instead
        # of loading or streaming the data, this object references the external
        # data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
        #   sheets_table = bigquery.external sheets_url do |sheets|
        #     sheets.skip_leading_rows = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: sheets_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        class SheetsSource < External::DataSource
          ##
          # @private Create an empty SheetsSource object.
          def initialize
            super
            @gapi.google_sheets_options = \
              Google::Apis::BigqueryV2::GoogleSheetsOptions.new
          end

          ##
          # The number of rows at the top of a sheet that BigQuery will skip
          # when reading the data. The default value is `0`.
          #
          # This property is useful if you have header rows that should be
          # skipped. When `autodetect` is on, behavior is the following:
          #
          # * `nil` - Autodetect tries to detect headers in the first row. If
          #   they are not detected, the row is read as data. Otherwise data is
          #   read starting from the second row.
          # * `0` - Instructs autodetect that there are no headers and data
          #   should be read starting from the first row.
          # * `N > 0` - Autodetect skips `N-1` rows and tries to detect headers
          #   in row `N`. If headers are not detected, row `N` is just skipped.
          #   Otherwise row `N` is used to extract column names for the detected
          #   schema.
          #
          # @return [Integer]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.skip_leading_rows = 1
          #   end
          #
          #   sheets_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows
            @gapi.google_sheets_options.skip_leading_rows
          end

          ##
          # Set the number of rows at the top of a sheet that BigQuery will skip
          # when reading the data.
          #
          # @param [Integer] row_count New skip_leading_rows value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   sheets_url = "https://docs.google.com/spreadsheets/d/1234567980"
          #   sheets_table = bigquery.external sheets_url do |sheets|
          #     sheets.skip_leading_rows = 1
          #   end
          #
          #   sheets_table.skip_leading_rows #=> 1
          #
          def skip_leading_rows= row_count
            frozen_check!
            @gapi.google_sheets_options.skip_leading_rows = row_count
          end
        end

        ##
        # # BigtableSource
        #
        # {External::BigtableSource} is a subclass of {External::DataSource} and
        # represents a Bigtable external data source that can be queried from
        # directly, even though the data is not stored in BigQuery. Instead of
        # loading or streaming the data, this object references the external
        # data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
        #   bigtable_table = bigquery.external bigtable_url do |bt|
        #     bt.rowkey_as_string = true
        #     bt.add_family "user" do |u|
        #       u.add_string "name"
        #       u.add_string "email"
        #       u.add_integer "age"
        #       u.add_boolean "active"
        #     end
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: bigtable_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        class BigtableSource < External::DataSource
          ##
          # @private Create an empty BigtableSource object.
          def initialize
            super
            @gapi.bigtable_options = \
              Google::Apis::BigqueryV2::BigtableOptions.new
            @families = []
          end

          ##
          # List of column families to expose in the table schema along with
          # their types. This list restricts the column families that can be
          # referenced in queries and specifies their value types. You can use
          # this list to do type conversions - see
          # {BigtableSource::ColumnFamily#type} for more details. If you leave
          # this list empty, all column families are present in the table schema
          # and their values are read as `BYTES`. During a query only the column
          # families referenced in that query are read from Bigtable.
          #
          # @return [Array<BigtableSource::ColumnFamily>]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #     bt.add_family "user" do |u|
          #       u.add_string "name"
          #       u.add_string "email"
          #       u.add_integer "age"
          #       u.add_boolean "active"
          #     end
          #   end
          #
          #   bigtable_table.families.count #=> 1
          #
          def families
            @families
          end

          ##
          # Add a column family to expose in the table schema along with its
          # types. Columns belonging to the column family may also be exposed.
          #
          # @param [String] family_id Identifier of the column family. See
          #   {BigtableSource::ColumnFamily#family_id}.
          # @param [String] encoding The encoding of the values when the type is
          #   not `STRING`. See {BigtableSource::ColumnFamily#encoding}.
          # @param [Boolean] latest Whether only the latest version of value are
          #   exposed for all columns in this column family. See
          #   {BigtableSource::ColumnFamily#latest}.
          # @param [String] type The type to convert the value in cells of this
          #   column. See {BigtableSource::ColumnFamily#type}.
          #
          # @yield [family] a block for setting the family
          # @yieldparam [BigtableSource::ColumnFamily] family the family object
          #
          # @return [BigtableSource::ColumnFamily]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #     bt.add_family "user" do |u|
          #       u.add_string "name"
          #       u.add_string "email"
          #       u.add_integer "age"
          #       u.add_boolean "active"
          #     end
          #   end
          #
          def add_family family_id, encoding: nil, latest: nil, type: nil
            frozen_check!
            fam = BigtableSource::ColumnFamily.new
            fam.family_id = family_id
            fam.encoding = encoding if encoding
            fam.latest = latest if latest
            fam.type = type if type
            yield fam if block_given?
            @families << fam
            fam
          end

          ##
          # Whether the rowkey column families will be read and converted to
          # string. Otherwise they are read with `BYTES` type values and users
          # need to manually cast them with `CAST` if necessary. The default
          # value is `false`.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #   end
          #
          #   bigtable_table.rowkey_as_string #=> true
          #
          def rowkey_as_string
            @gapi.bigtable_options.read_rowkey_as_string
          end

          ##
          # Set the number of rows at the top of a sheet that BigQuery will skip
          # when reading the data.
          #
          # @param [Boolean] row_rowkey New rowkey_as_string value
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #   end
          #
          #   bigtable_table.rowkey_as_string #=> true
          #
          def rowkey_as_string= row_rowkey
            frozen_check!
            @gapi.bigtable_options.read_rowkey_as_string = row_rowkey
          end

          ##
          # @private Google API Client object.
          def to_gapi
            @gapi.bigtable_options.column_families = @families.map(&:to_gapi)
            @gapi
          end

          ##
          # @private Google API Client object.
          def self.from_gapi gapi
            new_table = super
            families = Array gapi.bigtable_options.column_families
            families = families.map do |fam_gapi|
              BigtableSource::ColumnFamily.from_gapi fam_gapi
            end
            new_table.instance_variable_set :@families, families
            new_table
          end

          ##
          # @private
          def freeze
            @families.map(&:freeze!)
            @families.freeze!
            super
          end

          protected

          def frozen_check!
            return unless frozen?
            fail ArgumentError, "Cannot modify external data source when frozen"
          end

          ##
          # # BigtableSource::ColumnFamily
          #
          # A Bigtable column family used to expose in the table schema along
          # with its types and columns.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #     bt.add_family "user" do |u|
          #       u.add_string "name"
          #       u.add_string "email"
          #       u.add_integer "age"
          #       u.add_boolean "active"
          #     end
          #   end
          #
          #   data = bigquery.query "SELECT * FROM my_ext_table",
          #                         external: { my_ext_table: bigtable_table }
          #
          #   data.each do |row|
          #     puts row[:name]
          #   end
          #
          class ColumnFamily
            ##
            # @private Create an empty BigtableSource::ColumnFamily object.
            def initialize
              @gapi = Google::Apis::BigqueryV2::BigtableColumnFamily.new
              @columns = []
            end

            ##
            # The encoding of the values when the type is not `STRING`.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.encoding = "UTF-8"
            #     end
            #   end
            #
            #   bigtable_table.families[0].encoding #=> "UTF-8"
            #
            def encoding
              @gapi.encoding
            end

            ##
            # Set the encoding of the values when the type is not `STRING`.
            # Acceptable encoding values are:
            #
            # * `TEXT` - indicates values are alphanumeric text strings.
            # * `BINARY` - indicates values are encoded using HBase
            #   `Bytes.toBytes` family of functions. This can be overridden on a
            #   column.
            #
            # @param [String] new_encoding New encoding value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.encoding = "UTF-8"
            #     end
            #   end
            #
            #   bigtable_table.families[0].encoding #=> "UTF-8"
            #
            def encoding= new_encoding
              frozen_check!
              @gapi.encoding = new_encoding
            end

            ##
            # Identifier of the column family.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user"
            #   end
            #
            #   bigtable_table.families[0].family_id #=> "user"
            #
            def family_id
              @gapi.family_id
            end

            ##
            # Set the identifier of the column family.
            #
            # @param [String] new_family_id New family_id value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user"
            #   end
            #
            #   bigtable_table.families[0].family_id #=> "user"
            #   bigtable_table.families[0].family_id = "User"
            #   bigtable_table.families[0].family_id #=> "User"
            #
            def family_id= new_family_id
              frozen_check!
              @gapi.family_id = new_family_id
            end

            ##
            # Whether only the latest version of value are exposed for all
            # columns in this column family.
            #
            # @return [Boolean]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.latest = true
            #     end
            #   end
            #
            #   bigtable_table.families[0].latest #=> true
            #
            def latest
              @gapi.only_read_latest
            end

            ##
            # Set whether only the latest version of value are exposed for all
            # columns in this column family.
            #
            # @param [Boolean] new_latest New latest value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.latest = true
            #     end
            #   end
            #
            #   bigtable_table.families[0].latest #=> true
            #
            def latest= new_latest
              frozen_check!
              @gapi.only_read_latest = new_latest
            end

            ##
            # The type to convert the value in cells of this column family. The
            # values are expected to be encoded using HBase `Bytes.toBytes`
            # function when using the `BINARY` encoding value. The following
            # BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. This can be overridden on a column.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.type = "STRING"
            #     end
            #   end
            #
            #   bigtable_table.families[0].type #=> "STRING"
            #
            def type
              @gapi.type
            end

            ##
            # Set the type to convert the value in cells of this column family.
            # The values are expected to be encoded using HBase `Bytes.toBytes`
            # function when using the `BINARY` encoding value. The following
            # BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. This can be overridden on a column.
            #
            # @param [String] new_type New type value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.type = "STRING"
            #     end
            #   end
            #
            #   bigtable_table.families[0].type #=> "STRING"
            #
            def type= new_type
              frozen_check!
              @gapi.type = new_type
            end

            ##
            # Lists of columns that should be exposed as individual fields.
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_string "name"
            #       u.add_string "email"
            #       u.add_integer "age"
            #       u.add_boolean "active"
            #     end
            #   end
            #
            #   bigtable_table.families[0].columns.count #=> 4
            #
            def columns
              @columns
            end

            ##
            # Add a column to the column family to expose in the table schema
            # along with its types.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            # @param [String] type The type to convert the value in cells of
            #   this column. See {BigtableSource::Column#type}. The following
            #   BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_column "name", type: "STRING"
            #     end
            #   end
            #
            def add_column qualifier, as: nil, type: nil
              frozen_check!
              col = BigtableSource::Column.new
              col.qualifier = qualifier
              col.field_name = as if as
              col.type = type if type
              yield col if block_given?
              @columns << col
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `BYTES` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_bytes "avatar"
            #     end
            #   end
            #
            def add_bytes qualifier, as: nil
              col = add_column qualifier, as: as, type: "BYTES"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `STRING` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_string "name"
            #     end
            #   end
            #
            def add_string qualifier, as: nil
              col = add_column qualifier, as: as, type: "STRING"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `INTEGER` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_integer "age"
            #     end
            #   end
            #
            def add_integer qualifier, as: nil
              col = add_column qualifier, as: as, type: "INTEGER"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `FLOAT` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_float "score"
            #     end
            #   end
            #
            def add_float qualifier, as: nil
              col = add_column qualifier, as: as, type: "FLOAT"
              yield col if block_given?
              col
            end

            ##
            # Add a column to the column family to expose in the table schema
            # that is specified as the `BOOLEAN` type.
            #
            # @param [String] qualifier Qualifier of the column. See
            #   {BigtableSource::Column#qualifier}.
            # @param [String] as A valid identifier to be used as the column
            #   field name if the qualifier is not a valid BigQuery field
            #   identifier (i.e. does not match `[a-zA-Z][a-zA-Z0-9_]*`). See
            #   {BigtableSource::Column#field_name}.
            #
            # @yield [column] a block for setting the column
            # @yieldparam [BigtableSource::Column] column the column object
            #
            # @return [Array<BigtableSource::Column>]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.rowkey_as_string = true
            #     bt.add_family "user" do |u|
            #       u.add_boolean "active"
            #     end
            #   end
            #
            def add_boolean qualifier, as: nil
              col = add_column qualifier, as: as, type: "BOOLEAN"
              yield col if block_given?
              col
            end

            ##
            # @private Google API Client object.
            def to_gapi
              @gapi.columns = @columns.map(&:to_gapi)
              @gapi
            end

            ##
            # @private Google API Client object.
            def self.from_gapi gapi
              new_fam = new
              new_fam.instance_variable_set :@gapi, gapi
              columns = Array(gapi.columns).map do |col_gapi|
                BigtableSource::Column.from_gapi col_gapi
              end
              new_fam.instance_variable_set :@columns, columns
              new_fam
            end

            ##
            # @private
            def freeze
              @columns.map(&:freeze!)
              @columns.freeze!
              super
            end

            protected

            def frozen_check!
              return unless frozen?
              fail ArgumentError,
                   "Cannot modify external data source when frozen"
            end
          end

          ##
          # # BigtableSource::Column
          #
          # A Bigtable column to expose in the table schema along with its
          # types.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
          #   bigtable_table = bigquery.external bigtable_url do |bt|
          #     bt.rowkey_as_string = true
          #     bt.add_family "user" do |u|
          #       u.add_string "name"
          #       u.add_string "email"
          #       u.add_integer "age"
          #       u.add_boolean "active"
          #     end
          #   end
          #
          #   data = bigquery.query "SELECT * FROM my_ext_table",
          #                         external: { my_ext_table: bigtable_table }
          #
          #   data.each do |row|
          #     puts row[:name]
          #   end
          #
          class Column
            ##
            # @private Create an empty BigtableSource::Column object.
            def initialize
              @gapi = Google::Apis::BigqueryV2::BigtableColumn.new
            end

            ##
            # Qualifier of the column. Columns in the parent column family that
            # has this exact qualifier are exposed as `.` field. If the
            # qualifier is valid UTF-8 string, it will be represented as a UTF-8
            # string. Otherwise, it will represented as a ASCII-8BIT string.
            #
            # If the qualifier is not a valid BigQuery field identifier (does
            # not match `[a-zA-Z][a-zA-Z0-9_]*`) a valid identifier must be
            # provided as `field_name`.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.qualifier # "user"
            #         col.qualifier = "User"
            #         col.qualifier # "User"
            #       end
            #     end
            #   end
            #
            def qualifier
              @gapi.qualifier_string || \
                Base64.strict_decode64(@gapi.qualifier_encoded.to_s)
            end

            ##
            # Set the qualifier of the column. Columns in the parent column
            # family that has this exact qualifier are exposed as `.` field.
            # Values that are valid UTF-8 strings will be treated as such. All
            # other values will be treated as `BINARY`.
            #
            # @param [String] new_qualifier New qualifier value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.qualifier # "user"
            #         col.qualifier = "User"
            #         col.qualifier # "User"
            #       end
            #     end
            #   end
            #
            def qualifier= new_qualifier
              frozen_check!
              fail ArgumentError if new_qualifier.nil?

              utf8_qualifier = new_qualifier.encode Encoding::UTF_8
              if utf8_qualifier.valid_encoding?
                @gapi.qualifier_string = utf8_qualifier
                if @gapi.instance_variables.include? :@qualifier_encoded
                  @gapi.remove_instance_variable :@qualifier_encoded
                end
              else
                @gapi.qualifier_encoded = Base64.strict_encode64 new_qualifier
                if @gapi.instance_variables.include? :@qualifier_string
                  @gapi.remove_instance_variable :@qualifier_string
                end
              end
            rescue EncodingError
              @gapi.qualifier_encoded = Base64.strict_encode64 new_qualifier
              if @gapi.instance_variables.include? :@qualifier_string
                @gapi.remove_instance_variable :@qualifier_string
              end
            end

            ##
            # The encoding of the values when the type is not `STRING`.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_bytes "name" do |col|
            #         col.encoding = "TEXT"
            #         col.encoding # "TEXT"
            #       end
            #     end
            #   end
            #
            def encoding
              @gapi.encoding
            end

            ##
            # Set the encoding of the values when the type is not `STRING`.
            # Acceptable encoding values are:
            #
            # * `TEXT` - indicates values are alphanumeric text strings.
            # * `BINARY` - indicates values are encoded using HBase
            #   `Bytes.toBytes` family of functions. This can be overridden on a
            #   column.
            #
            # @param [String] new_encoding New encoding value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_bytes "name" do |col|
            #         col.encoding = "TEXT"
            #         col.encoding # "TEXT"
            #       end
            #     end
            #   end
            #
            def encoding= new_encoding
              frozen_check!
              @gapi.encoding = new_encoding
            end

            ##
            # If the qualifier is not a valid BigQuery field identifier  (does
            # not match `[a-zA-Z][a-zA-Z0-9_]*`) a valid identifier must be
            # provided as the column field name and is used as field name in
            # queries.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "001_name", as: "user" do |col|
            #         col.field_name # "user"
            #         col.field_name = "User"
            #         col.field_name # "User"
            #       end
            #     end
            #   end
            #
            def field_name
              @gapi.field_name
            end

            ##
            # Sets the identifier to be used as the column field name in queries
            # when the qualifier is not a valid BigQuery field identifier  (does
            # not match `[a-zA-Z][a-zA-Z0-9_]*`).
            #
            # @param [String] new_field_name New field_name value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "001_name", as: "user" do |col|
            #         col.field_name # "user"
            #         col.field_name = "User"
            #         col.field_name # "User"
            #       end
            #     end
            #   end
            #
            def field_name= new_field_name
              frozen_check!
              @gapi.field_name = new_field_name
            end

            ##
            # Whether only the latest version of value in this column are
            # exposed. Can also be set at the column family level. However, this
            # value takes precedence when set at both levels.
            #
            # @return [Boolean]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.latest = true
            #         col.latest # true
            #       end
            #     end
            #   end
            #
            def latest
              @gapi.only_read_latest
            end

            ##
            # Set whether only the latest version of value in this column are
            # exposed. Can also be set at the column family level. However, this
            # value takes precedence when set at both levels.
            #
            # @param [Boolean] new_latest New latest value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.latest = true
            #         col.latest # true
            #       end
            #     end
            #   end
            #
            def latest= new_latest
              frozen_check!
              @gapi.only_read_latest = new_latest
            end

            ##
            # The type to convert the value in cells of this column. The values
            # are expected to be encoded using HBase `Bytes.toBytes` function
            # when using the `BINARY` encoding value. The following BigQuery
            # types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. Can also be set at the column family
            # level. However, this value takes precedence when set at both
            # levels.
            #
            # @return [String]
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.type # "STRING"
            #       end
            #     end
            #   end
            #
            def type
              @gapi.type
            end

            ##
            # Set the type to convert the value in cells of this column. The
            # values are expected to be encoded using HBase `Bytes.toBytes`
            # function when using the `BINARY` encoding value. The following
            # BigQuery types are allowed:
            #
            # * `BYTES`
            # * `STRING`
            # * `INTEGER`
            # * `FLOAT`
            # * `BOOLEAN`
            #
            # Default type is `BYTES`. Can also be set at the column family
            # level. However, this value takes precedence when set at both
            # levels.
            #
            # @param [String] new_type New type value
            #
            # @example
            #   require "google/cloud/bigquery"
            #
            #   bigquery = Google::Cloud::Bigquery.new
            #
            #   bigtable_url = "https://googleapis.com/bigtable/projects/..."
            #   bigtable_table = bigquery.external bigtable_url do |bt|
            #     bt.add_family "user" do |u|
            #       u.add_string "name" do |col|
            #         col.type # "STRING"
            #         col.type = "BYTES"
            #         col.type # "BYTES"
            #       end
            #     end
            #   end
            #
            def type= new_type
              frozen_check!
              @gapi.type = new_type
            end

            ##
            # @private Google API Client object.
            def to_gapi
              @gapi
            end

            ##
            # @private Google API Client object.
            def self.from_gapi gapi
              new_col = new
              new_col.instance_variable_set :@gapi, gapi
              new_col
            end

            protected

            def frozen_check!
              return unless frozen?
              fail ArgumentError,
                   "Cannot modify external data source when frozen"
            end
          end
        end
      end
    end
  end
end
