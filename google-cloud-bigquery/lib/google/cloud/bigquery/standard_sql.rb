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
          # Creates a new, immutable StandardSql::Field object.
          def initialize **kwargs
            # Convert client object kwargs to a gapi object
            kwargs[:type] = DataType.gapi_from_string_or_data_type kwargs[:type]
            @gapi = Google::Apis::BigqueryV2::StandardSqlField.new(**kwargs)
          end

          ##
          # The name of the field. (Can be absent for struct fields.)
          #
          # @return [String, nil]
          #
          def name
            return if @gapi.name == "".freeze
            @gapi.name
          end

          ##
          # The type of the field.
          #
          # @return [DataType]
          #
          def type
            DataType.from_gapi @gapi.type
          end

          ##
          # @private New Google::Apis::BigqueryV2::StandardSqlField object.
          def to_gapi
            @gapi
          end

          ##
          # @private New StandardSql::Field from a Google::Apis::BigqueryV2::StandardSqlField object.
          def self.from_gapi gapi
            new.tap do |f|
              f.instance_variable_set :@gapi, gapi
            end
          end
        end

        ##
        # The type of a field or a column.
        class DataType
          ##
          # Creates a new, immutable StandardSql::DataType object.
          #
          # @overload initialize(type_kind, array_element_type, struct_type)
          #   @param [String] type_kind Required.
          #   @param [DataType, Hash] array_element_type The type of a variable, e.g., a function argument, if
          #      type_kind = "ARRAY".
          #   @param [StructType, Hash] struct_type The fields of this struct, in order, if type_kind = "STRUCT".
          #
          def initialize **kwargs
            # Convert client object kwargs to a gapi object
            if kwargs[:array_element_type]
              kwargs[:array_element_type] = self.class.gapi_from_string_or_data_type kwargs[:array_element_type]
            end
            kwargs[:struct_type] = kwargs[:struct_type].to_gapi if kwargs[:struct_type]

            @gapi = Google::Apis::BigqueryV2::StandardSqlDataType.new(**kwargs)
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
            @gapi.type_kind
          end

          ##
          # The type of a fields when DataType is an Array. (See #array?)
          #
          # @return [DataType, nil]
          #
          def array_element_type
            return if @gapi.array_element_type.nil?
            DataType.from_gapi @gapi.array_element_type
          end

          ##
          # The fields of the struct. (See #struct?)
          #
          # @return [StructType, nil]
          #
          def struct_type
            return if @gapi.struct_type.nil?
            StructType.from_gapi @gapi.struct_type
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
          # @private New Google::Apis::BigqueryV2::StandardSqlDataType object.
          def to_gapi
            @gapi
          end

          ##
          # @private New StandardSql::DataType from a Google::Apis::BigqueryV2::StandardSqlDataType object.
          def self.from_gapi gapi
            new.tap do |f|
              f.instance_variable_set :@gapi, gapi
            end
          end

          ##
          # @private New Google::Apis::BigqueryV2::StandardSqlDataType from a String or StandardSql::DataType object.
          def self.gapi_from_string_or_data_type data_type
            return if data_type.nil?
            if data_type.is_a? StandardSql::DataType
              data_type.to_gapi
            elsif data_type.is_a? Hash
              data_type
            elsif data_type.is_a?(String) || data_type.is_a?(Symbol)
              Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: data_type.to_s.upcase
            else
              raise ArgumentError, "Unable to convert #{data_type} to Google::Apis::BigqueryV2::StandardSqlDataType"
            end
          end
        end

        ##
        # The type of a `STRUCT` field or a column.
        class StructType
          ##
          # Creates a new, immutable StandardSql::StructType object.
          #
          def initialize **kwargs
            # Convert each field client object to gapi object, if fields given (self.from_gapi does not pass kwargs)
            kwargs[:fields] = kwargs[:fields]&.map(&:to_gapi) if kwargs[:fields]
            @gapi = Google::Apis::BigqueryV2::StandardSqlStructType.new(**kwargs)
          end

          ##
          # The top level type of this field.
          #
          # Can be any standard SQL data type (e.g., "INT64", "DATE", "ARRAY").
          #
          # @return [Array<Field>] A frozen array of fields.
          #
          def fields
            Array(@gapi.fields).map do |field_gapi|
              Field.from_gapi field_gapi
            end.freeze
          end

          ##
          # @private New Google::Apis::BigqueryV2::StandardSqlStructType object.
          def to_gapi
            @gapi
          end

          ##
          # @private New StandardSql::StructType from a Google::Apis::BigqueryV2::StandardSqlStructType object.
          def self.from_gapi gapi
            new.tap do |f|
              f.instance_variable_set :@gapi, gapi
            end
          end
        end
      end
    end
  end
end
