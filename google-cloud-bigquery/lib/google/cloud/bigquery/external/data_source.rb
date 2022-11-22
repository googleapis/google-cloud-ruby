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
        #   avro_url = "gs://bucket/path/to/*.avro"
        #   avro_table = bigquery.external avro_url do |avro|
        #     avro.autodetect = true
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: avro_table }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Hive partitioning options:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
        #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
        #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
        #     ext.hive_partitioning_mode = :auto
        #     ext.hive_partitioning_require_partition_filter = true
        #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
        #   end
        #
        #   external_data.hive_partitioning? #=> true
        #   external_data.hive_partitioning_mode #=> "AUTO"
        #   external_data.hive_partitioning_require_partition_filter? #=> true
        #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
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
          #   avro_url = "gs://bucket/path/to/*.avro"
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
          # Whether the data format is "ORC".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :orc do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #   external_data.format #=> "ORC"
          #   external_data.orc? #=> true
          #
          def orc?
            @gapi.source_format == "ORC"
          end

          ##
          # Whether the data format is "PARQUET".
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #   external_data.format #=> "PARQUET"
          #   external_data.parquet? #=> true
          #
          def parquet?
            @gapi.source_format == "PARQUET"
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

          ###
          # Checks if hive partitioning options are set.
          #
          # Not all storage formats support hive partitioning. Requesting hive partitioning on an unsupported format
          # will lead to an error. Currently supported types include: `avro`, `csv`, `json`, `orc` and `parquet`.
          # If your data is stored in ORC or Parquet on Cloud Storage, see [Querying columnar formats on Cloud
          # Storage](https://cloud.google.com/bigquery/pricing#columnar_formats_pricing).
          #
          # @return [Boolean] `true` when hive partitioning options are set, or `false` otherwise.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning?
            !@gapi.hive_partitioning_options.nil?
          end

          ###
          # The mode of hive partitioning to use when reading data. The following modes are supported:
          #
          #   1. `AUTO`: automatically infer partition key name(s) and type(s).
          #   2. `STRINGS`: automatically infer partition key name(s). All types are interpreted as strings.
          #   3. `CUSTOM`: partition key schema is encoded in the source URI prefix.
          #
          # @return [String, nil] The mode of hive partitioning, or `nil` if not set.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_mode
            @gapi.hive_partitioning_options.mode if hive_partitioning?
          end

          ##
          # Sets the mode of hive partitioning to use when reading data. The following modes are supported:
          #
          #   1. `auto`: automatically infer partition key name(s) and type(s).
          #   2. `strings`: automatically infer partition key name(s). All types are interpreted as strings.
          #   3. `custom`: partition key schema is encoded in the source URI prefix.
          #
          # Not all storage formats support hive partitioning. Requesting hive partitioning on an unsupported format
          # will lead to an error. Currently supported types include: `avro`, `csv`, `json`, `orc` and `parquet`.
          # If your data is stored in ORC or Parquet on Cloud Storage, see [Querying columnar formats on Cloud
          # Storage](https://cloud.google.com/bigquery/pricing#columnar_formats_pricing).
          #
          # See {#format}, {#hive_partitioning_require_partition_filter=} and {#hive_partitioning_source_uri_prefix=}.
          #
          # @param [String, Symbol] mode The mode of hive partitioning to use when reading data.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_mode= mode
            @gapi.hive_partitioning_options ||= Google::Apis::BigqueryV2::HivePartitioningOptions.new
            @gapi.hive_partitioning_options.mode = mode.to_s.upcase
          end

          ###
          # Whether queries over the table using this external data source require a partition filter that can be used
          # for partition elimination to be specified. Note that this field should only be true when creating a
          # permanent external table or querying a temporary external table.
          #
          # @return [Boolean] `true` when queries over this table require a partition filter, or `false` otherwise.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_require_partition_filter?
            return false unless hive_partitioning?
            !@gapi.hive_partitioning_options.require_partition_filter.nil?
          end

          ##
          # Sets whether queries over the table using this external data source require a partition filter
          # that can be used for partition elimination to be specified.
          #
          # See {#format}, {#hive_partitioning_mode=} and {#hive_partitioning_source_uri_prefix=}.
          #
          # @param [Boolean] require_partition_filter `true` if a partition filter must be specified, `false` otherwise.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_require_partition_filter= require_partition_filter
            @gapi.hive_partitioning_options ||= Google::Apis::BigqueryV2::HivePartitioningOptions.new
            @gapi.hive_partitioning_options.require_partition_filter = require_partition_filter
          end

          ###
          # The common prefix for all source uris when hive partition detection is requested. The prefix must end
          # immediately before the partition key encoding begins. For example, consider files following this data
          # layout:
          #
          # ```
          # gs://bucket/path_to_table/dt=2019-01-01/country=BR/id=7/file.avro
          # gs://bucket/path_to_table/dt=2018-12-31/country=CA/id=3/file.avro
          # ```
          #
          # When hive partitioning is requested with either `AUTO` or `STRINGS` mode, the common prefix can be either of
          # `gs://bucket/path_to_table` or `gs://bucket/path_to_table/` (trailing slash does not matter).
          #
          # @return [String, nil] The common prefix for all source uris, or `nil` if not set.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_source_uri_prefix
            @gapi.hive_partitioning_options.source_uri_prefix if hive_partitioning?
          end

          ##
          # Sets the common prefix for all source uris when hive partition detection is requested. The prefix must end
          # immediately before the partition key encoding begins. For example, consider files following this data
          # layout:
          #
          # ```
          # gs://bucket/path_to_table/dt=2019-01-01/country=BR/id=7/file.avro
          # gs://bucket/path_to_table/dt=2018-12-31/country=CA/id=3/file.avro
          # ```
          #
          # When hive partitioning is requested with either `AUTO` or `STRINGS` mode, the common prefix can be either of
          # `gs://bucket/path_to_table` or `gs://bucket/path_to_table/` (trailing slash does not matter).
          #
          # See {#format}, {#hive_partitioning_mode=} and {#hive_partitioning_require_partition_filter=}.
          #
          # @param [String] source_uri_prefix The common prefix for all source uris.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
          #   source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
          #   external_data = bigquery.external gcs_uri, format: :parquet do |ext|
          #     ext.hive_partitioning_mode = :auto
          #     ext.hive_partitioning_require_partition_filter = true
          #     ext.hive_partitioning_source_uri_prefix = source_uri_prefix
          #   end
          #
          #   external_data.hive_partitioning? #=> true
          #   external_data.hive_partitioning_mode #=> "AUTO"
          #   external_data.hive_partitioning_require_partition_filter? #=> true
          #   external_data.hive_partitioning_source_uri_prefix #=> source_uri_prefix
          #
          def hive_partitioning_source_uri_prefix= source_uri_prefix
            @gapi.hive_partitioning_options ||= Google::Apis::BigqueryV2::HivePartitioningOptions.new
            @gapi.hive_partitioning_options.source_uri_prefix = source_uri_prefix
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
            raise ArgumentError, "Cannot modify external data source when frozen"
          end
        end
      end
    end
  end
end
