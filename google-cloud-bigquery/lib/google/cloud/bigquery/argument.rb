# Copyright 2020 Google LLC
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


require "google/cloud/bigquery/standard_sql"

module Google
  module Cloud
    module Bigquery
      ##
      # # Argument
      #
      # Input/output argument of a function or a stored procedure. See {Routine}.
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
      class Argument
        ##
        # Creates a new, immutable Argument object.
        #
        # @overload initialize(data_type, kind, mode, name)
        #   @param [StandardSql::DataType, String] data_type The data type of the argument. Required unless
        #     {#argument_kind} is `ANY_TYPE`.
        #   @param [String] argument_kind The kind of argument. Optional. Defaults to `FIXED_TYPE`.
        #
        #     * `FIXED_TYPE` - The argument is a variable with fully specified type, which can be a struct or an array,
        #       but not a table.
        #     * `ANY_TYPE` - The argument is any type, including struct or array, but not a table.
        #
        #     To be added: `FIXED_TABLE`, `ANY_TABLE`.
        #   @param [String] mode Specifies whether the argument is input or output. Optional. Can be set for procedures
        #     only.
        #
        #     * IN - The argument is input-only.
        #     * OUT - The argument is output-only.
        #     * INOUT - The argument is both an input and an output.
        #   @param [String] name The name of the argument. Optional. Can be absent for a function return argument.
        #
        def initialize **kwargs
          kwargs[:data_type] = StandardSql::DataType.gapi_from_string_or_data_type kwargs[:data_type]
          @gapi = Google::Apis::BigqueryV2::Argument.new(**kwargs)
        end

        ##
        # The data type of the argument. Required unless {#argument_kind} is `ANY_TYPE`.
        #
        # @return [StandardSql::DataType] The data type.
        #
        def data_type
          StandardSql::DataType.from_gapi @gapi.data_type
        end

        ##
        # The kind of argument. Optional. Defaults to `FIXED_TYPE`.
        #
        # * `FIXED_TYPE` - The argument is a variable with fully specified type, which can be a struct or an array, but
        #   not a table.
        # * `ANY_TYPE` - The argument is any type, including struct or array, but not a table.
        #
        # To be added: `FIXED_TABLE`, `ANY_TABLE`.
        #
        # @return [String] The upper case kind of argument.
        #
        def argument_kind
          @gapi.argument_kind
        end

        ##
        # Checks if the value of {#argument_kind} is `FIXED_TYPE`. The default is `true`.
        #
        # @return [Boolean] `true` when `FIXED_TYPE`, `false` otherwise.
        #
        def fixed_type?
          return true if @gapi.argument_kind.nil?
          @gapi.argument_kind == "FIXED_TYPE"
        end

        ##
        # Checks if the value of {#argument_kind} is `ANY_TYPE`. The default is `false`.
        #
        # @return [Boolean] `true` when `ANY_TYPE`, `false` otherwise.
        #
        def any_type?
          @gapi.argument_kind == "ANY_TYPE"
        end

        ##
        # Specifies whether the argument is input or output. Optional. Can be set for procedures only.
        #
        # * IN - The argument is input-only.
        # * OUT - The argument is output-only.
        # * INOUT - The argument is both an input and an output.
        #
        # @return [String] The upper case input/output mode of the argument.
        #
        def mode
          @gapi.mode
        end

        ##
        # Checks if the value of {#mode} is `IN`. Can be set for procedures only. The default is `false`.
        #
        # @return [Boolean] `true` when `IN`, `false` otherwise.
        #
        def in?
          @gapi.mode == "IN"
        end

        ##
        # Checks if the value of {#mode} is `OUT`. Can be set for procedures only. The default is `false`.
        #
        # @return [Boolean] `true` when `OUT`, `false` otherwise.
        #
        def out?
          @gapi.mode == "OUT"
        end

        ##
        # Checks if the value of {#mode} is `INOUT`. Can be set for procedures only. The default is `false`.
        #
        # @return [Boolean] `true` when `INOUT`, `false` otherwise.
        #
        def inout?
          @gapi.mode == "INOUT"
        end

        ##
        #
        # The name of the argument. Optional. Can be absent for a function return argument.
        #
        # @return [String] The name of the argument.
        #
        def name
          @gapi.name
        end

        ##
        # @private
        def to_gapi
          @gapi
        end

        ##
        # @private New Argument from a Google API Client object.
        def self.from_gapi gapi
          new.tap do |a|
            a.instance_variable_set :@gapi, gapi
          end
        end
      end
    end
  end
end
