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

          # ##
          # # @private New Google::Apis::BigqueryV2::StandardSqlField object.
          # def to_gapi
          #   Google::Apis::BigqueryV2::StandardSqlField.from_json @gapi_json.to_json
          # end

          ##
          # @private New StandardSql::Field from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |f|
              f.instance_variable_set :@gapi_json, gapi_json
            end
          end

          # ##
          # # @private New StandardSql::Field from a Google::Apis::BigqueryV2::StandardSqlField object.
          # def self.from_gapi gapi
          #   gapi_json = JSON.parse gapi.to_json, symbolize_names: true
          #   from_gapi_json gapi_json
          # end
        end

        ##
        # The type of a field or a column.
        class DataType
          ##
          # Create an empty StandardSql::DataType object.
          #
          # @param type_kind [String]
          #   Required.
          # @param array_element_type [DataType, Hash]
          #   The type of a variable, e.g., a function argument, if type_kind = "ARRAY".
          # @param struct_type [StructType, Hash]
          #   The fields of this struct, in order, if type_kind = "STRUCT".
          def initialize **kwargs
            # Convert struct_type to a gapi object if it is a veneer object (has #to_gapi defined)
            kwargs[:array_element_type] = kwargs[:array_element_type].to_gapi if kwargs[:array_element_type].respond_to? :to_gapi
            kwargs[:struct_type] = kwargs[:struct_type].to_gapi if kwargs[:struct_type].respond_to? :to_gapi

            gapi = Google::Apis::BigqueryV2::StandardSqlDataType.new(**kwargs)
            @gapi_json = JSON.parse gapi.to_json, symbolize_names: true
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
          # @private New Google::Apis::BigqueryV2::StandardSqlDataType object.
          def to_gapi
            Google::Apis::BigqueryV2::StandardSqlDataType.from_json @gapi_json.to_json
          end

          ##
          # @private New StandardSql::DataType from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |dt|
              dt.instance_variable_set :@gapi_json, gapi_json
            end
          end

          ##
          # @private New StandardSql::DataType from a Google::Apis::BigqueryV2::StandardSqlDataType object.
          def self.from_gapi gapi
            gapi_json = JSON.parse gapi.to_json, symbolize_names: true
            from_gapi_json gapi_json
          end

          # ##
          # # @private New primitive object representing this DataType.
          # def to_primitive
          #   if array?
          #     [array_element_type.to_primitive]
          #   elsif struct?
          #     struct_type.to_primitive
          #   else
          #     type_kind.to_sym
          #   end
          # end
          #
          # ##
          # # @private New StandardSql::DataType from a primitive object.
          # def self.from_primitive primitive
          #   if Array === primitive
          #     gapi = Google::Apis::BigqueryV2::StandardSqlDataType.new(
          #       type_kind: "ARRAY".freeze,
          #       array_element_type: from_primitive(primitive.first)
          #     )
          #     from_gapi gapi
          #   elsif Hash === primitive
          #     # This is more complicated because we have to deal with missing names and sort them by their numeric values.
          #
          #     keys = primitive.keys
          #     int_keys = keys.select { |key| key.is_a? Integer }
          #     named_keys = keys - int_keys
          #
          #     Array.new(keys.count) do |index|
          #       # name = int_keys.contain?(index) ? index : named_keys.shift
          #       # raise ArgumentError, "missing struct field for index #{index}" if name.nil?
          #
          #       if int_keys.contain? index
          #         Google::Apis::BigqueryV2::StandardSqlField.new(
          #           type: DataType.from_primitive(primitive[index])
          #         )
          #       else
          #         name = named_keys.shift
          #         raise ArgumentError, "missing struct field for index #{index}" if name.nil?
          #         value = primitive[name]
          #
          #         Google::Apis::BigqueryV2::StandardSqlField.new(
          #           name: String(name),
          #           type: DataType.from_primitive(primitive[name])
          #         )
          #       end
          #       raise ArgumentError, "missing struct field for index #{index}" if name.nil?
          #
          #       name = int_keys.contain?(index) ? index : named_keys.shift
          #       raise ArgumentError, "missing struct field for index #{index}" if name.nil?
          #
          #     end
          #     fields = primitive.to_a do |name, value|
          #     if name.is_a?(Integer)
          #       Google::Apis::BigqueryV2::StandardSqlField.new(
          #         type: DataType.from_primitive(value)
          #       )
          #     else
          #       Google::Apis::BigqueryV2::StandardSqlField.new(
          #         name: String(name),
          #         type: DataType.from_primitive(value)
          #       )
          #     end
          #
          #
          #     gapi = Google::Apis::BigqueryV2::StandardSqlDataType.new(
          #       type_kind: "ARRAY".freeze,
          #       array_element_type: from_primitive(primitive.first)
          #     )
          #     from_gapi gapi
          #
          #     Google::Apis::BigqueryV2::QueryParameterType.new(
          #       type: "STRUCT".freeze,
          #       struct_types: type.map do |key, val|
          #         Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
          #           name: String(key),
          #           type: to_query_param_type(val)
          #         )
          #       end
          #     )
          #   else
          #     gapi = Google::Apis::BigqueryV2::StandardSqlDataType.new(
          #       type_kind: String(primitive).freeze
          #     )
          #     from_gapi gapi
          #   end
          # end
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
          # @private New Google::Apis::BigqueryV2::StandardSqlStructType object.
          def to_gapi
            Google::Apis::BigqueryV2::StandardSqlStructType.from_json @gapi_json.to_json
          end

          ##
          # @private New StandardSql::StructType from a JSON object.
          def self.from_gapi_json gapi_json
            new.tap do |st|
              st.instance_variable_set :@gapi_json, gapi_json
            end
          end

          # ##
          # # @private New StandardSql::Field from a Google::Apis::BigqueryV2::StandardSqlStructType object.
          # def self.from_gapi gapi
          #   gapi_json = JSON.parse gapi.to_json, symbolize_names: true
          #   from_gapi_json gapi_json
          # end

          ##
          # @private New Google::Apis::BigqueryV2::StandardSqlDataType object.
          def to_primitive
            field_pairs = fields.map_with_index do |field, index|
              name = field.name&.to_sym || index
              [name, field.type.to_primitive]
            end
            Hash[field_pairs]
          end
        end
      end
    end
  end
end
