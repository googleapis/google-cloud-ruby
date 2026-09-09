# Copyright 2017 Google LLC
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


require "google/cloud/bigquery/external/data_source"
require "google/cloud/bigquery/external/avro_source"
require "google/cloud/bigquery/external/bigtable_source"
require "google/cloud/bigquery/external/csv_source"
require "google/cloud/bigquery/external/json_source"
require "google/cloud/bigquery/external/parquet_source"
require "google/cloud/bigquery/external/sheets_source"

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
      module External
        ##
        # @private New External from URLs and format
        def self.from_urls urls, format = nil
          external_format = source_format_for urls, format
          raise ArgumentError, "Unable to determine external table format" if external_format.nil?
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
          raise ArgumentError, "Unable to determine external table format" if external_format.nil?
          external_class = table_class_for external_format
          external_class.from_gapi gapi
        end

        ##
        # @private Determine source_format from inputs
        def self.source_format_for urls, format
          val = {
            "avro"                   => "AVRO",
            "bigtable"               => "BIGTABLE",
            "csv"                    => "CSV",
            "backup"                 => "DATASTORE_BACKUP",
            "datastore"              => "DATASTORE_BACKUP",
            "datastore_backup"       => "DATASTORE_BACKUP",
            "sheets"                 => "GOOGLE_SHEETS",
            "google_sheets"          => "GOOGLE_SHEETS",
            "json"                   => "NEWLINE_DELIMITED_JSON",
            "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
            "orc"                    => "ORC",
            "parquet"                => "PARQUET"
          }[format.to_s.downcase]
          return val unless val.nil?
          Array(urls).each do |url|
            return "AVRO" if url.end_with? ".avro"
            return "BIGTABLE" if url.start_with? "https://googleapis.com/bigtable/projects/"
            return "CSV" if url.end_with? ".csv"
            return "DATASTORE_BACKUP" if url.end_with? ".backup_info"
            return "GOOGLE_SHEETS" if url.start_with? "https://docs.google.com/spreadsheets/"
            return "NEWLINE_DELIMITED_JSON" if url.end_with? ".json"
            return "PARQUET" if url.end_with? ".parquet"
          end
          nil
        end

        ##
        # @private Determine table class from source_format
        def self.table_class_for format
          case format
          when "AVRO"                   then External::AvroSource
          when "BIGTABLE"               then External::BigtableSource
          when "CSV"                    then External::CsvSource
          when "GOOGLE_SHEETS"          then External::SheetsSource
          when "NEWLINE_DELIMITED_JSON" then External::JsonSource
          when "PARQUET"                then External::ParquetSource
          else
            # DATASTORE_BACKUP, ORC
            External::DataSource
          end
        end
      end
    end
  end
end
