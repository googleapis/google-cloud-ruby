# Copyright 2019 Google LLC
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
      ##
      # BigQuery standard SQL is compliant with the SQL 2011 standard and has
      # extensions that support querying nested and repeated data.
      module StandardSql
        ##
        # A field or a column.
        class Field
          ##
          # @private Create an empty StandardSql::Field object.
          def initialize
            @gapi_json = nil
          end

          ##
          # The name of the field. (Can be absent for struct fields.)
          #
          # @return [String, nil]
          #
          def name
            return nil if @gapi_json[:name] == "".freeze

            @gapi_json[:name]
          end

          ##
          # The type of the field.
          #
          # @return [DataType]
          #
          def type
            DataType.from_gapi_json @gapi_json[:type]
          end

          ##
          # @private New StandardSql::Field from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |f|
              f.instance_variable_set :@gapi_json, gapi_json
            end
          end
        end

        ##
        # The type of a field or a column.
        class DataType
          ##
          # @private Create an empty StandardSql::DataType object.
          def initialize
            @gapi_json = nil
          end

          ##
          # The top level type of this field.
          #
          # Can be any standard SQL data type (e.g., "INT64", "DATE", "ARRAY").
          #
          # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types
          #   Standard SQL Data Types
          #
          # @return [String]
          #
          def type_kind
            @gapi_json[:typeKind]
          end

          ##
          # The type of a fields when DataType is an Array. (See #array?)
          #
          # @return [DataType, nil]
          #
          def array_element_type
            return if @gapi_json[:arrayElementType].nil?

            DataType.from_gapi_json @gapi_json[:arrayElementType]
          end

          ##
          # The fields of the struct. (See #struct?)
          #
          # @return [StructType, nil]
          #
          def struct_type
            return if @gapi_json[:structType].nil?

            StructType.from_gapi_json @gapi_json[:structType]
          end

          ##
          # Checks if the {#type_kind} of the field is `INT64`.
          #
          # @return [Boolean] `true` when `INT64`, `false` otherwise.
          #
          # @!group Helpers
          #
          def int?
            type_kind == "INT64".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `FLOAT64`.
          #
          # @return [Boolean] `true` when `FLOAT64`, `false` otherwise.
          #
          # @!group Helpers
          #
          def float?
            type_kind == "FLOAT64".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `NUMERIC`.
          #
          # @return [Boolean] `true` when `NUMERIC`, `false` otherwise.
          #
          # @!group Helpers
          #
          def numeric?
            type_kind == "NUMERIC".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `BOOL`.
          #
          # @return [Boolean] `true` when `BOOL`, `false` otherwise.
          #
          # @!group Helpers
          #
          def boolean?
            type_kind == "BOOL".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `STRING`.
          #
          # @return [Boolean] `true` when `STRING`, `false` otherwise.
          #
          # @!group Helpers
          #
          def string?
            type_kind == "STRING".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `BYTES`.
          #
          # @return [Boolean] `true` when `BYTES`, `false` otherwise.
          #
          # @!group Helpers
          #
          def bytes?
            type_kind == "BYTES".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `DATE`.
          #
          # @return [Boolean] `true` when `DATE`, `false` otherwise.
          #
          # @!group Helpers
          #
          def date?
            type_kind == "DATE".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `DATETIME`.
          #
          # @return [Boolean] `true` when `DATETIME`, `false` otherwise.
          #
          # @!group Helpers
          #
          def datetime?
            type_kind == "DATETIME".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `GEOGRAPHY`.
          #
          # @return [Boolean] `true` when `GEOGRAPHY`, `false` otherwise.
          #
          # @!group Helpers
          #
          def geography?
            type_kind == "GEOGRAPHY".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `TIME`.
          #
          # @return [Boolean] `true` when `TIME`, `false` otherwise.
          #
          # @!group Helpers
          #
          def time?
            type_kind == "TIME".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `TIMESTAMP`.
          #
          # @return [Boolean] `true` when `TIMESTAMP`, `false` otherwise.
          #
          # @!group Helpers
          #
          def timestamp?
            type_kind == "TIMESTAMP".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `ARRAY`.
          #
          # @return [Boolean] `true` when `ARRAY`, `false` otherwise.
          #
          # @!group Helpers
          #
          def array?
            type_kind == "ARRAY".freeze
          end

          ##
          # Checks if the {#type_kind} of the field is `STRUCT`.
          #
          # @return [Boolean] `true` when `STRUCT`, `false` otherwise.
          #
          # @!group Helpers
          #
          def struct?
            type_kind == "STRUCT".freeze
          end

          ##
          # @private New StandardSql::DataType from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |dt|
              dt.instance_variable_set :@gapi_json, gapi_json
            end
          end
        end

        ##
        # The type of a `STRUCT` field or a column.
        class StructType
          ##
          # @private Create an empty StandardSql::DataType object.
          def initialize
            @gapi_json = nil
          end

          ##
          # The top level type of this field.
          #
          # Can be any standard SQL data type (e.g., "INT64", "DATE", "ARRAY").
          #
          # @return [Array<Field>]
          #
          def fields
            Array(@gapi_json[:fields]).map do |field_gapi_json|
              Field.from_gapi_json field_gapi_json
            end
          end

          ##
          # @private New StandardSql::StructType from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |st|
              st.instance_variable_set :@gapi_json, gapi_json
            end
          end
        end
      end
    end
  end
end
