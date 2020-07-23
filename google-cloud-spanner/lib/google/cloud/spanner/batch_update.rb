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


require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # BatchUpdate
      #
      # Accepts DML statements and optional parameters and types of the
      # parameters for a batch update.
      #
      # See {Google::Cloud::Spanner::Transaction#batch_update}.
      #
      class BatchUpdate
        # @private
        attr_reader :statements

        # @private
        def initialize
          @statements = []
        end

        ##
        # Adds a DML statement to a batch update. See
        # {Transaction#batch_update}.
        #
        # @param [String] sql The DML statement string. See [Query
        #   syntax](https://cloud.google.com/spanner/docs/query-syntax).
        #
        #   The DML statement string can contain parameter placeholders. A
        #   parameter placeholder consists of "@" followed by the parameter
        #   name. Parameter names consist of any combination of letters,
        #   numbers, and underscores.
        # @param [Hash] params Parameters for the DML statement string. The
        #   parameter placeholders, minus the "@", are the the hash keys, and
        #   the literal values are the hash values. If the query string contains
        #   something like "WHERE id > @msg_id", then the params must contain
        #   something like `:msg_id => 1`.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #   | `STRUCT`    | `Hash`, {Data} | |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        #   See [Data Types - Constructing a
        #   STRUCT](https://cloud.google.com/spanner/docs/data-types#constructing-a-struct).
        # @param [Hash] types Types of the SQL parameters in `params`. It is not
        #   always possible for Cloud Spanner to infer the right SQL type from a
        #   value in `params`. In these cases, the `types` hash can be used to
        #   specify the exact SQL type for some or all of the SQL query
        #   parameters.
        #
        #   The keys of the hash should be query string parameter placeholders,
        #   minus the "@". The values of the hash should be Cloud Spanner type
        #   codes from the following list:
        #
        #   * `:BOOL`
        #   * `:BYTES`
        #   * `:DATE`
        #   * `:FLOAT64`
        #   * `:INT64`
        #   * `:STRING`
        #   * `:TIMESTAMP`
        #   * `Array` - Lists are specified by providing the type code in an
        #     array. For example, an array of integers are specified as
        #     `[:INT64]`.
        #   * {Fields} - Nested Structs are specified by providing a Fields
        #     object.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     begin
        #       row_counts = tx.batch_update do |b|
        #         statement_count = b.batch_update(
        #           "UPDATE users SET name = 'Charlie' WHERE id = 1"
        #         )
        #       end
        #       puts row_counts.inspect
        #     rescue Google::Cloud::Spanner::BatchUpdateError => err
        #       puts err.cause.message
        #       puts err.row_counts.inspect
        #     end
        #   end
        #
        # @example Update using SQL parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     begin
        #       row_counts = tx.batch_update do |b|
        #         statement_count = b.batch_update(
        #           "UPDATE users SET name = 'Charlie' WHERE id = 1",
        #           params: { id: 1, name: "Charlie" }
        #         )
        #       end
        #       puts row_counts.inspect
        #     rescue Google::Cloud::Spanner::BatchUpdateError => err
        #       puts err.cause.message
        #       puts err.row_counts.inspect
        #     end
        #   end
        #
        def batch_update sql, params: nil, types: nil
          @statements << Statement.new(sql, params: params, types: types)
          true
        end

        # @private
        class Statement
          attr_reader :sql, :params, :types

          def initialize sql, params: nil, types: nil
            @sql = sql
            @params = params
            @types = types
          end

          def to_grpc
            converted_params, converted_types = \
              Convert.to_input_params_and_types params, types
            # param_types is a grpc map field, can't be nil
            converted_types ||= {}
            V1::ExecuteBatchDmlRequest::Statement.new(
              sql: sql,
              params: converted_params,
              param_types: converted_types
            )
          end
        end
      end
    end
  end
end
