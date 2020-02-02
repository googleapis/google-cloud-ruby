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
      # Input/output argument of a function or a stored procedure.
      class Argument
        ##
        # Create an immutable Argument object.
        #
        # @overload initialize(data_type, kind, mode, name)
        #   @param [StandardSql::DataType, String] data_type Required.
        #   @param [String] argument_kind
        #   @param [String] mode
        #   @param [String] name
        #
        def initialize **kwargs
          kwargs[:data_type] = StandardSql::DataType.gapi_from_string_or_data_type kwargs[:data_type]
          @gapi = Google::Apis::BigqueryV2::Argument.new(**kwargs)
        end

        ##
        # The type of a variable, e.g., a function argument.
        # Examples:
        # INT64: `type_kind="INT64"`
        # ARRAY<STRING>: `type_kind="ARRAY", array_element_type="STRING"`
        # STRUCT<x STRING, y ARRAY<DATE>>:
        # `type_kind="STRUCT",
        # struct_type=`fields=[
        # `name="x", type=`type_kind="STRING"``,
        # `name="y", type=`type_kind="ARRAY", array_element_type="DATE"``
        # ]``
        #
        # @return [StandardSql::DataType]
        #
        def data_type
          StandardSql::DataType.from_gapi @gapi.data_type
        end

        ##
        # Optional. Defaults to FIXED_TYPE.
        # FIXED_TYPE  The argument is a variable with fully specified type, which can be a struct or an array, but not
        # a table.
        # ANY_TYPE  The argument is any type, including struct or array, but not a table. To be added: FIXED_TABLE,
        # ANY_TABLE
        #
        # @return [String]
        #
        def argument_kind
          @gapi.argument_kind
        end

        ##
        # Optional. Specifies whether the argument is input or output.
        # Can be set for procedures only.
        #
        # @return [String]
        #
        def mode
          @gapi.mode
        end

        ##
        # IN  The argument is input-only.
        # OUT  The argument is output-only.
        # INOUT  The argument is both an input and an output.
        #
        # Optional. The name of this argument. Can be absent for function return
        # argument.
        #
        # @return [String]
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
