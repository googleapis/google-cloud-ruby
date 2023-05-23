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
        # # AvroSource
        #
        # {External::AvroSource} is a subclass of {External::DataSource} and
        # represents a Avro external data source that can be queried
        # from directly, even though the data is not stored in BigQuery. Instead
        # of loading or streaming the data, this object references the external
        # data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   avro_url = "gs://bucket/path/to/*.avro"
        #   avro_table = bigquery.external avro_url do |avro|
        #     avro.use_avro_logical_types = 1
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
        class AvroSource < External::DataSource
          ##
          # @private Create an empty AvroSource object.
          def initialize
            super
            @gapi.avro_options = Google::Apis::BigqueryV2::AvroOptions.new
          end

          ##
          # Indicates whether to interpret logical types as the corresponding BigQuery data type (for example,
          # `TIMESTAMP`), instead of using the raw type (for example, `INTEGER`).
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   avro_url = "gs://bucket/path/to/*.avro"
          #   avro_table = bigquery.external avro_url do |avro|
          #     avro.use_avro_logical_types = true
          #   end
          #
          #   avro_table.use_avro_logical_types #=> true
          #
          def use_avro_logical_types
            @gapi.avro_options.use_avro_logical_types
          end

          ##
          # Sets whether to interpret logical types as the corresponding BigQuery data type (for example, `TIMESTAMP`),
          # instead of using the raw type (for example, `INTEGER`).
          #
          # @param [Boolean] new_use_avro_logical_types The new `use_avro_logical_types` value.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #
          #   avro_url = "gs://bucket/path/to/*.avro"
          #   avro_table = bigquery.external avro_url do |avro|
          #     avro.use_avro_logical_types = true
          #   end
          #
          #   avro_table.use_avro_logical_types #=> true
          #
          def use_avro_logical_types= new_use_avro_logical_types
            frozen_check!
            @gapi.avro_options.use_avro_logical_types = new_use_avro_logical_types
          end
        end
      end
    end
  end
end
