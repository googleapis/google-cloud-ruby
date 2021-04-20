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
      # extensions that support querying nested and repeated data. See {Routine} and {Argument}.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   routine = dataset.create_routine "my_routine" do |r|
      #     r.routine_type = "SCALAR_FUNCTION"
      #     r.language = :SQL
      #     r.body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
      #     r.arguments = [
      #       Google::Cloud::Bigquery::Argument.new(
      #         name: "arr",
      #         argument_kind: "FIXED_TYPE",
      #         data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
      #           type_kind: "ARRAY",
      #           array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
      #             type_kind: "STRUCT",
      #             struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
      #               fields: [
      #                 Google::Cloud::Bigquery::StandardSql::Field.new(
      #                   name: "name",
      #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
      #                 ),
      #                 Google::Cloud::Bigquery::StandardSql::Field.new(
      #                   name: "val",
      #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
      #                 )
      #               ]
      #             )
      #           )
      #         )
      #       )
      #     ]
      #   end
      #
      module StandardSql
        ##
        # A field or a column. See {Routine} and {Argument}.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.create_routine "my_routine" do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = :SQL
        #     r.body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(
        #         name: "arr",
        #         argument_kind: "FIXED_TYPE",
        #         data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #           type_kind: "ARRAY",
        #           array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #             type_kind: "STRUCT",
        #             struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
        #               fields: [
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "name",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
        #                 ),
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "val",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
        #                 )
        #               ]
        #             )
        #           )
        #         )
        #       )
        #     ]
        #   end
        #
        class Field
          ##
          # Creates a new, immutable StandardSql::Field object.
          #
          # @overload initialize(name, type)
          #   @param [String] name The name of the field. Optional. Can be absent for struct fields.
          #   @param [StandardSql::DataType, String] type The type of the field. Optional. Absent if not explicitly
          #     specified (e.g., `CREATE FUNCTION` statement can omit the return type; in this case the output parameter
          #     does not have this "type" field).
          #
          def initialize **kwargs
            # Convert client object kwargs to a gapi object
            kwargs[:type] = DataType.gapi_from_string_or_data_type kwargs[:type] if kwargs[:type]
            @gapi = Google::Apis::BigqueryV2::StandardSqlField.new(**kwargs)
          end

          ##
          # The name of the field. Optional. Can be absent for struct fields.
          #
          # @return [String, nil]
          #
          def name
            return if @gapi.name == "".freeze
            @gapi.name
          end

          ##
          # The type of the field. Optional. Absent if not explicitly specified (e.g., `CREATE FUNCTION` statement can
          # omit the return type; in this case the output parameter does not have this "type" field).
          #
          # @return [DataType, nil] The type of the field.
          #
          def type
            DataType.from_gapi @gapi.type if @gapi.type
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
        # The type of a variable, e.g., a function argument. See {Routine} and {Argument}.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.create_routine "my_routine" do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = :SQL
        #     r.body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(
        #         name: "arr",
        #         argument_kind: "FIXED_TYPE",
        #         data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #           type_kind: "ARRAY",
        #           array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #             type_kind: "STRUCT",
        #             struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
        #               fields: [
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "name",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
        #                 ),
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "val",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
        #                 )
        #               ]
        #             )
        #           )
        #         )
        #       )
        #     ]
        #   end
        #
        # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types Standard SQL Data Types
        #
        class DataType
          ##
          # Creates a new, immutable StandardSql::DataType object.
          #
          # @overload initialize(type_kind, array_element_type, struct_type)
          #   @param [String] type_kind The top level type of this field. Required. Can be [any standard SQL data
          #     type](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types) (e.g., `INT64`, `DATE`,
          #     `ARRAY`).
          #   @param [DataType, String] array_element_type The type of the array's elements, if {#type_kind} is `ARRAY`.
          #     See {#array?}. Optional.
          #   @param [StructType] struct_type The fields of the struct, in order, if {#type_kind} is `STRUCT`. See
          #     {#struct?}. Optional.
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
          # The top level type of this field. Required. Can be any standard SQL data type (e.g., `INT64`, `DATE`,
          # `ARRAY`).
          #
          # @see https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types Standard SQL Data Types
          #
          # @return [String] The upper case type.
          #
          def type_kind
            @gapi.type_kind
          end

          ##
          # The type of the array's elements, if {#type_kind} is `ARRAY`. See {#array?}. Optional.
          #
          # @return [DataType, nil]
          #
          def array_element_type
            return if @gapi.array_element_type.nil?
            DataType.from_gapi @gapi.array_element_type
          end

          ##
          # The fields of the struct, in order, if {#type_kind} is `STRUCT`. See {#struct?}. Optional.
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
          # Checks if the {#type_kind} of the field is `BIGNUMERIC`.
          #
          # @return [Boolean] `true` when `BIGNUMERIC`, `false` otherwise.
          #
          # @!group Helpers
          #
          def bignumeric?
            type_kind == "BIGNUMERIC".freeze
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
            case data_type
            when StandardSql::DataType
              data_type.to_gapi
            when Hash
              data_type
            when String, Symbol
              Google::Apis::BigqueryV2::StandardSqlDataType.new type_kind: data_type.to_s.upcase
            else
              raise ArgumentError, "Unable to convert #{data_type} to Google::Apis::BigqueryV2::StandardSqlDataType"
            end
          end
        end

        ##
        # The fields of a `STRUCT` type. See {DataType#struct_type}. See {Routine} and {Argument}.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.create_routine "my_routine" do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = :SQL
        #     r.body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(
        #         name: "arr",
        #         argument_kind: "FIXED_TYPE",
        #         data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #           type_kind: "ARRAY",
        #           array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #             type_kind: "STRUCT",
        #             struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
        #               fields: [
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "name",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
        #                 ),
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "val",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
        #                 )
        #               ]
        #             )
        #           )
        #         )
        #       )
        #     ]
        #   end
        #
        class StructType
          ##
          # Creates a new, immutable StandardSql::StructType object.
          #
          # @overload initialize(fields)
          #   @param [Array<Field>] fields The fields of the struct. Required.
          #
          def initialize **kwargs
            # Convert each field client object to gapi object, if fields given (self.from_gapi does not pass kwargs)
            kwargs[:fields] = kwargs[:fields]&.map(&:to_gapi) if kwargs[:fields]
            @gapi = Google::Apis::BigqueryV2::StandardSqlStructType.new(**kwargs)
          end

          ##
          # The fields of the struct.
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
