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


require "google/cloud/bigquery/standard_sql"

module Google
  module Cloud
    module Bigquery
      # Input/output argument of a function or a stored procedure.
      class Argument
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
        # Corresponds to the JSON property `dataType`
        # @return [Google::Apis::BigqueryV2::StandardSqlDataType]
        attr_accessor :data_type

        # Optional. Defaults to FIXED_TYPE.
        # Corresponds to the JSON property `argumentKind`
        # @return [String]
        attr_accessor :kind
        # FIXED_TYPE  The argument is a variable with fully specified type, which can be a struct or an array, but not a table.
        # ANY_TYPE  The argument is any type, including struct or array, but not a table. To be added: FIXED_TABLE, ANY_TABLE

        # Optional. Specifies whether the argument is input or output.
        # Can be set for procedures only.
        # Corresponds to the JSON property `mode`
        # @return [String]
        attr_accessor :mode
        # IN  The argument is input-only.
        # OUT  The argument is output-only.
        # INOUT  The argument is both an input and an output.

        # Optional. The name of this argument. Can be absent for function return
        # argument.
        # Corresponds to the JSON property `name`
        # @return [String]
        attr_accessor :name

        def initialize data_type, kind: nil, mode: nil, name: nil
          @data_type = if data_type.kind_of? StandardSql::DataType
                        data_type
                      elsif data_type.respond_to? :to_s
                        StandardSql::DataType.new(type_kind: data_type.to_s.upcase)

                      end
          @kind = kind
          @mode = mode
          @name = name
        end

        def to_gapi
          Google::Apis::BigqueryV2::Argument.new(
            name: @name,
            argument_kind: @kind,
            mode: @mode,
            data_type: @data_type.to_gapi
          )
        end

        ##
        # @private New Routine from a Google API Client object.
        def self.from_gapi gapi
          new(
            StandardSql::DataType.from_gapi(gapi.data_type),
            kind: gapi.argument_kind,
            mode: gapi.mode,
            name: gapi.name
          )
        end
      end
    end
  end
end
