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


module Google
  module Cloud
    module Bigquery
      module External
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
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
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
