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
      # Input/output argument of a function or a stored procedure.
      class Argument
        # Optional. Defaults to FIXED_TYPE.
        # Corresponds to the JSON property `argumentKind`
        # @return [String]
        attr_accessor :argument_kind
        # FIXED_TYPE  The argument is a variable with fully specified type, which can be a struct or an array, but not a table.
        # ANY_TYPE  The argument is any type, including struct or array, but not a table. To be added: FIXED_TABLE, ANY_TABLE

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

        def initialize **args
          update!(**args)
        end
      end
    end
  end
end
