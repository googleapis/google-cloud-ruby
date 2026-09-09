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
        # # ParquetSource
        #
        # {External::ParquetSource} is a subclass of {External::DataSource} and
        # represents a Parquet external data source that can be queried
        # from directly, even though the data is not stored in BigQuery. Instead
        # of loading or streaming the data, this object references the external
        # data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   parquet_url = "gs://bucket/path/to/data.parquet"
        #   parquet_table = bigquery.external parquet_url do |parquet|
        #     parquet.enable_list_inference = 1
        #   end
        #
        #   data = bigquery.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: parquet_table }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        class ParquetSource < External::DataSource
          ##
          # @private Create an empty ParquetSource object.
          def initialize
            super
            @gapi.parquet_options = Google::Apis::BigqueryV2::ParquetOptions.new
          end

          ##
          # Indicates whether to use schema inference specifically for Parquet `LIST` logical type.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   parquet_url = "gs://bucket/path/to/data.parquet"
          #   parquet_table = bigquery.external parquet_url do |parquet|
          #     parquet.enable_list_inference = true
          #   end
          #
          #   parquet_table.enable_list_inference #=> true
          #
          def enable_list_inference
            @gapi.parquet_options.enable_list_inference
          end

          ##
          # Sets whether to use schema inference specifically for Parquet `LIST` logical type.
          #
          # @param [Boolean] new_enable_list_inference The new `enable_list_inference` value.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   parquet_url = "gs://bucket/path/to/data.parquet"
          #   parquet_table = bigquery.external parquet_url do |parquet|
          #     parquet.enable_list_inference = true
          #   end
          #
          #   parquet_table.enable_list_inference #=> true
          #
          def enable_list_inference= new_enable_list_inference
            frozen_check!
            @gapi.parquet_options.enable_list_inference = new_enable_list_inference
          end

          ##
          # Indicates whether to infer Parquet `ENUM` logical type as `STRING` instead of `BYTES` by default.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   parquet_url = "gs://bucket/path/to/data.parquet"
          #   parquet_table = bigquery.external parquet_url do |parquet|
          #     parquet.enum_as_string = true
          #   end
          #
          #   parquet_table.enum_as_string #=> true
          #
          def enum_as_string
            @gapi.parquet_options.enum_as_string
          end

          ##
          # Sets whether to infer Parquet `ENUM` logical type as `STRING` instead of `BYTES` by default.
          #
          # @param [Boolean] new_enum_as_string The new `enum_as_string` value.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   parquet_url = "gs://bucket/path/to/data.parquet"
          #   parquet_table = bigquery.external parquet_url do |parquet|
          #     parquet.enum_as_string = true
          #   end
          #
          #   parquet_table.enum_as_string #=> true
          #
          def enum_as_string= new_enum_as_string
            frozen_check!
            @gapi.parquet_options.enum_as_string = new_enum_as_string
          end
        end
      end
    end
  end
end
