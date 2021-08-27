# Copyright 2017 Google LLC
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


require "google/cloud/spanner/errors"
require "google/cloud/spanner/convert"
require "google/cloud/spanner/results"
require "google/cloud/spanner/commit"

module Google
  module Cloud
    module Spanner
      ##
      # # Transaction
      #
      # A transaction in Cloud Spanner is a set of reads and writes that execute
      # atomically at a single logical point in time across columns, rows, and
      # tables in a database.
      #
      # All changes are accumulated in memory until the block passed to
      # {Client#transaction} completes. Transactions will be automatically
      # retried when possible. See {Client#transaction}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   db = spanner.client "my-instance", "my-database"
      #
      #   db.transaction do |tx|
      #     # Read the second album budget.
      #     second_album_result = tx.read "Albums", ["marketing_budget"],
      #                                   keys: [[2, 2]], limit: 1
      #     second_album_row = second_album_result.rows.first
      #     second_album_budget = second_album_row.values.first
      #
      #     transfer_amount = 200000
      #
      #     if second_album_budget < 300000
      #       # Raising an exception will automatically roll back the
      #       # transaction.
      #       raise "The second album doesn't have enough funds to transfer"
      #     end
      #
      #     # Read the first album's budget.
      #     first_album_result = tx.read "Albums", ["marketing_budget"],
      #                                   keys: [[1, 1]], limit: 1
      #     first_album_row = first_album_result.rows.first
      #     first_album_budget = first_album_row.values.first
      #
      #     # Update the budgets.
      #     second_album_budget -= transfer_amount
      #     first_album_budget += transfer_amount
      #     puts "Setting first album's budget to #{first_album_budget} and " \
      #          "the second album's budget to #{second_album_budget}."
      #
      #     # Update the rows.
      #     rows = [
      #       {singer_id: 1, album_id: 1, marketing_budget: first_album_budget},
      #       {singer_id: 2, album_id: 2, marketing_budget: second_album_budget}
      #     ]
      #     tx.update "Albums", rows
      #   end
      #
      class Transaction
        # @private The Session object.
        attr_accessor :session

        # @private Transaction tag for statistics collection.
        attr_accessor :transaction_tag

        def initialize
          @commit = Commit.new
          @seqno = 0
        end

        ##
        # Identifier of the transaction results were run in.
        # @return [String] The transaction id.
        def transaction_id
          return nil if @grpc.nil?
          @grpc.id
        end

        ##
        # Executes a SQL query.
        #
        # @param [String] sql The SQL query string. See [Query
        #   syntax](https://cloud.google.com/spanner/docs/query-syntax).
        #
        #   The SQL query string can contain parameter placeholders. A parameter
        #   placeholder consists of "@" followed by the parameter name.
        #   Parameter names consist of any combination of letters, numbers, and
        #   underscores.
        # @param [Hash] params SQL parameters for the query string. The
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
        #   | `NUMERIC`   | `BigDecimal`   | |
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
        #   value in `params`. In these cases, the `types` hash must be used to
        #   specify the SQL type for these values.
        #
        #   The keys of the hash should be query string parameter placeholders,
        #   minus the "@". The values of the hash should be Cloud Spanner type
        #   codes from the following list:
        #
        #   * `:BOOL`
        #   * `:BYTES`
        #   * `:DATE`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:INT64`
        #   * `:STRING`
        #   * `:TIMESTAMP`
        #   * `Array` - Lists are specified by providing the type code in an
        #     array. For example, an array of integers are specified as
        #     `[:INT64]`.
        #   * {Fields} - Types for STRUCT values (`Hash`/{Data} objects) are
        #     specified using a {Fields} object.
        #
        #   Types are optional.
        # @param [Hash] query_options A hash of values to specify the custom
        #   query options for executing SQL query. Query options are optional.
        #   The following settings can be provided:
        #
        #   * `:optimizer_version` (String) The version of optimizer to use.
        #     Empty to use database default. "latest" to use the latest
        #     available optimizer version.
        #   * `:optimizer_statistics_package` (String) Statistics package to
        #     use. Empty to use the database default.
        # @param [Hash] request_options Common request options.
        #
        #   * `:priority` (String) The relative priority for requests.
        #     The priority acts as a hint to the Cloud Spanner scheduler
        #     and does not guarantee priority or order of execution.
        #     Valid values are `:PRIORITY_LOW`, `:PRIORITY_MEDIUM`,
        #     `:PRIORITY_HIGH`. If priority not set then default is
        #     `PRIORITY_UNSPECIFIED` is equivalent to `:PRIORITY_HIGH`.
        #   * `:tag` (String) A per-request tag which can be applied to
        #     queries or reads, used for statistics collection. Tag must be a
        #     valid identifier of the form: `[a-zA-Z][a-zA-Z0-9_\-]` between 2
        #     and 64 characters in length.
        # @param [Hash] call_options A hash of values to specify the custom
        #   call options, e.g., timeout, retries, etc. Call options are
        #   optional. The following settings can be provided:
        #
        #   * `:timeout` (Numeric) A numeric value of custom timeout in seconds
        #     that overrides the default setting.
        #   * `:retry_policy` (Hash) A hash of values that overrides the default
        #     setting of retry policy with the following keys:
        #     * `:initial_delay` (`Numeric`) - The initial delay in seconds.
        #     * `:max_delay` (`Numeric`) - The max delay in seconds.
        #     * `:multiplier` (`Numeric`) - The incremental backoff multiplier.
        #     * `:retry_codes` (`Array<String>`) - The error codes that should
        #       trigger a retry.
        #
        # @return [Google::Cloud::Spanner::Results] The results of the query
        #   execution.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.execute_query "SELECT * FROM users"
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Query using query parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.execute_query(
        #       "SELECT * FROM users WHERE active = @active",
        #       params: { active: true }
        #     )
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Query with a SQL STRUCT query parameter as a Hash:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     user_hash = { id: 1, name: "Charlie", active: false }
        #
        #     results = tx.execute_query(
        #       "SELECT * FROM users WHERE " \
        #       "ID = @user_struct.id " \
        #       "AND name = @user_struct.name " \
        #       "AND active = @user_struct.active",
        #       params: { user_struct: user_hash }
        #     )
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Specify the SQL STRUCT type using Fields object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     user_type = tx.fields id: :INT64, name: :STRING, active: :BOOL
        #     user_hash = { id: 1, name: nil, active: false }
        #
        #     results = tx.execute_query(
        #       "SELECT * FROM users WHERE " \
        #       "ID = @user_struct.id " \
        #       "AND name = @user_struct.name " \
        #       "AND active = @user_struct.active",
        #       params: { user_struct: user_hash },
        #       types: { user_struct: user_type }
        #     )
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Or, query with a SQL STRUCT as a typed Data object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     user_type = tx.fields id: :INT64, name: :STRING, active: :BOOL
        #     user_data = user_type.struct id: 1, name: nil, active: false
        #
        #     results = tx.execute_query(
        #       "SELECT * FROM users WHERE " \
        #       "ID = @user_struct.id " \
        #       "AND name = @user_struct.name " \
        #       "AND active = @user_struct.active",
        #       params: { user_struct: user_data }
        #     )
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Query using query options:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.execute_query \
        #       "SELECT * FROM users", query_options: {
        #       optimizer_version: "1",
        #       optimizer_statistics_package: "auto_20191128_14_47_22UTC"
        #     }
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        # @example Query using custom timeout and retry policy:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   timeout = 30.0
        #   retry_policy = {
        #     initial_delay: 0.25,
        #     max_delay:     32.0,
        #     multiplier:    1.3,
        #     retry_codes:   ["UNAVAILABLE"]
        #   }
        #   call_options = { timeout: timeout, retry_policy: retry_policy }
        #
        #   db.transaction do |tx|
        #     results = tx.execute_query \
        #       "SELECT * FROM users", call_options: call_options
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def execute_query sql, params: nil, types: nil, query_options: nil,
                          request_options: nil, call_options: nil
          ensure_session!

          @seqno += 1

          params, types = Convert.to_input_params_and_types params, types
          request_options = build_request_options request_options
          session.execute_query sql, params: params, types: types,
                                     transaction: tx_selector, seqno: @seqno,
                                     query_options: query_options,
                                     request_options: request_options,
                                     call_options: call_options
        end
        alias execute execute_query
        alias query execute_query
        alias execute_sql execute_query

        ##
        # Executes a DML statement.
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
        #   | `NUMERIC`   | `BigDecimal`   | |
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
        #   * `:NUMERIC`
        #   * `:INT64`
        #   * `:STRING`
        #   * `:TIMESTAMP`
        #   * `Array` - Lists are specified by providing the type code in an
        #     array. For example, an array of integers are specified as
        #     `[:INT64]`.
        #   * {Fields} - Nested Structs are specified by providing a Fields
        #     object.
        # @param [Hash] query_options A hash of values to specify the custom
        #   query options for executing SQL query. Query options are optional.
        #   The following settings can be provided:
        #
        #   * `:optimizer_version` (String) The version of optimizer to use.
        #     Empty to use database default. "latest" to use the latest
        #     available optimizer version.
        #   * `:optimizer_statistics_package` (String) Statistics package to
        #     use. Empty to use the database default.
        # @param [Hash] request_options Common request options.
        #
        #   * `:priority` (String) The relative priority for requests.
        #     The priority acts as a hint to the Cloud Spanner scheduler
        #     and does not guarantee priority or order of execution.
        #     Valid values are `:PRIORITY_LOW`, `:PRIORITY_MEDIUM`,
        #     `:PRIORITY_HIGH`. If priority not set then default is
        #     `PRIORITY_UNSPECIFIED` is equivalent to `:PRIORITY_HIGH`.
        #   * `:tag` (String) A per-request tag which can be applied to
        #     queries or reads, used for statistics collection. Tag must be a
        #     valid identifier of the form: `[a-zA-Z][a-zA-Z0-9_\-]` between 2
        #     and 64 characters in length.
        # @param [Hash] call_options A hash of values to specify the custom
        #   call options, e.g., timeout, retries, etc. Call options are
        #   optional. The following settings can be provided:
        #
        #   * `:timeout` (Numeric) A numeric value of custom timeout in seconds
        #     that overrides the default setting.
        #   * `:retry_policy` (Hash) A hash of values that overrides the default
        #     setting of retry policy with the following keys:
        #     * `:initial_delay` (`Numeric`) - The initial delay in seconds.
        #     * `:max_delay` (`Numeric`) - The max delay in seconds.
        #     * `:multiplier` (`Numeric`) - The incremental backoff multiplier.
        #     * `:retry_codes` (`Array<String>`) - The error codes that should
        #       trigger a retry.
        #
        # @return [Integer] The exact number of rows that were modified.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     row_count = tx.execute_update(
        #       "UPDATE users SET name = 'Charlie' WHERE id = 1"
        #     )
        #   end
        #
        # @example Update using SQL parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     row_count = tx.execute_update(
        #       "UPDATE users SET name = @name WHERE id = @id",
        #       params: { id: 1, name: "Charlie" }
        #     )
        #   end
        #
        # @example Update using query options
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     row_count = tx.execute_update(
        #       "UPDATE users SET name = 'Charlie' WHERE id = 1",
        #       query_options: {
        #         optimizer_version: "1",
        #         optimizer_statistics_package: "auto_20191128_14_47_22UTC"
        #       }
        #     )
        #   end
        #
        # @example Update using custom timeout and retry policy:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   timeout = 30.0
        #   retry_policy = {
        #     initial_delay: 0.25,
        #     max_delay:     32.0,
        #     multiplier:    1.3,
        #     retry_codes:   ["UNAVAILABLE"]
        #   }
        #   call_options = { timeout: timeout, retry_policy: retry_policy }
        #
        #   db.transaction do |tx|
        #     row_count = tx.execute_update(
        #       "UPDATE users SET name = 'Charlie' WHERE id = 1",
        #       call_options: call_options
        #     )
        #   end
        #
        def execute_update sql, params: nil, types: nil, query_options: nil,
                           request_options: nil, call_options: nil
          results = execute_query sql, params: params, types: types,
                                  query_options: query_options,
                                  request_options: request_options,
                                  call_options: call_options
          # Stream all PartialResultSet to get ResultSetStats
          results.rows.to_a
          # Raise an error if there is not a row count returned
          if results.row_count.nil?
            raise Google::Cloud::InvalidArgumentError,
                  "DML statement is invalid."
          end
          results.row_count
        end

        ##
        # Executes DML statements in a batch.
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:priority` (String) The relative priority for requests.
        #     The priority acts as a hint to the Cloud Spanner scheduler
        #     and does not guarantee priority or order of execution.
        #     Valid values are `:PRIORITY_LOW`, `:PRIORITY_MEDIUM`,
        #     `:PRIORITY_HIGH`. If priority not set then default is
        #     `PRIORITY_UNSPECIFIED` is equivalent to `:PRIORITY_HIGH`.
        #   * `:tag` (String) A per-request tag which can be applied to
        #     queries or reads, used for statistics collection. Tag must be a
        #     valid identifier of the form: `[a-zA-Z][a-zA-Z0-9_\-]` between 2
        #     and 64 characters in length.
        # @param [Hash] call_options A hash of values to specify the custom
        #   call options, e.g., timeout, retries, etc. Call options are
        #   optional. The following settings can be provided:
        #
        #   * `:timeout` (Numeric) A numeric value of custom timeout in seconds
        #     that overrides the default setting.
        #   * `:retry_policy` (Hash) A hash of values that overrides the default
        #     setting of retry policy with the following keys:
        #     * `:initial_delay` (`Numeric`) - The initial delay in seconds.
        #     * `:max_delay` (`Numeric`) - The max delay in seconds.
        #     * `:multiplier` (`Numeric`) - The incremental backoff multiplier.
        #     * `:retry_codes` (`Array<String>`) - The error codes that should
        #       trigger a retry.
        #
        # @yield [batch_update] a batch update object
        # @yieldparam [Google::Cloud::Spanner::BatchUpdate] batch_update a batch
        #   update object accepting DML statements and optional parameters and
        #   types of the parameters.
        #
        # @raise [Google::Cloud::Spanner::BatchUpdateError] If an error occurred
        #   while executing a statement. The error object contains a cause error
        #   with the service error type and message, and a list with the exact
        #   number of rows that were modified for each successful statement
        #   before the error.
        #
        # @return [Array<Integer>] A list with the exact number of rows that
        #   were modified for each DML statement.
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
        def batch_update request_options: nil, call_options: nil, &block
          ensure_session!
          @seqno += 1

          request_options = build_request_options request_options
          session.batch_update tx_selector, @seqno,
                               request_options: request_options,
                               call_options: call_options, &block
        end

        ##
        # Read rows from a database table, as a simple alternative to
        # {#execute_query}.
        #
        # @param [String] table The name of the table in the database to be
        #   read.
        # @param [Array<String, Symbol>] columns The columns of table to be
        #   returned for each row matching this request.
        # @param [Object, Array<Object>] keys A single, or list of keys or key
        #   ranges to match returned data to. Values should have exactly as many
        #   elements as there are columns in the primary key.
        # @param [String] index The name of an index to use instead of the
        #   table's primary key when interpreting `id` and sorting result rows.
        #   Optional.
        # @param [Integer] limit If greater than zero, no more than this number
        #   of rows will be returned. The default is no limit.
        # @param [Hash] request_options Common request options.
        #
        #   * `:priority` (String) The relative priority for requests.
        #     The priority acts as a hint to the Cloud Spanner scheduler
        #     and does not guarantee priority or order of execution.
        #     Valid values are `:PRIORITY_LOW`, `:PRIORITY_MEDIUM`,
        #     `:PRIORITY_HIGH`. If priority not set then default is
        #     `PRIORITY_UNSPECIFIED` is equivalent to `:PRIORITY_HIGH`.
        #   * `:tag` (String) A per-request tag which can be applied to
        #     queries or reads, used for statistics collection. Tag must be a
        #     valid identifier of the form: `[a-zA-Z][a-zA-Z0-9_\-]` between 2
        #     and 64 characters in length.
        # @param [Hash] call_options A hash of values to specify the custom
        #   call options, e.g., timeout, retries, etc. Call options are
        #   optional. The following settings can be provided:
        #
        #   * `:timeout` (Numeric) A numeric value of custom timeout in seconds
        #     that overrides the default setting.
        #   * `:retry_policy` (Hash) A hash of values that overrides the default
        #     setting of retry policy with the following keys:
        #     * `:initial_delay` (`Numeric`) - The initial delay in seconds.
        #     * `:max_delay` (`Numeric`) - The max delay in seconds.
        #     * `:multiplier` (`Numeric`) - The incremental backoff multiplier.
        #     * `:retry_codes` (`Array<String>`) - The error codes that should
        #       trigger a retry.
        #
        # @return [Google::Cloud::Spanner::Results] The results of the read
        #   operation.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.read "users", [:id, :name]
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def read table, columns, keys: nil, index: nil, limit: nil,
                 request_options: nil, call_options: nil
          ensure_session!

          columns = Array(columns).map(&:to_s)
          keys = Convert.to_key_set keys
          request_options = build_request_options request_options
          session.read table, columns, keys: keys, index: index, limit: limit,
                                       transaction: tx_selector,
                                       request_options: request_options,
                                       call_options: call_options
        end

        ##
        # Inserts or updates rows in a table. If any of the rows already exist,
        # then its column values are overwritten with the ones provided. Any
        # column values not explicitly written are preserved.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#transaction} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `NUMERIC`   | `BigDecimal`   | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.upsert "users", [{ id: 1, name: "Charlie", active: false },
        #                         { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def upsert table, *rows
          ensure_session!
          @commit.upsert table, rows
        end
        alias save upsert

        ##
        # Inserts new rows in a table. If any of the rows already exist, the
        # write or request fails with error {Google::Cloud::AlreadyExistsError}.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#transaction} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `NUMERIC`   | `BigDecimal`   | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.insert "users", [{ id: 1, name: "Charlie", active: false },
        #                         { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def insert table, *rows
          ensure_session!
          @commit.insert table, rows
        end

        ##
        # Updates existing rows in a table. If any of the rows does not already
        # exist, the request fails with error {Google::Cloud::NotFoundError}.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#transaction} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `NUMERIC`   | `BigDecimal`   | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.update "users", [{ id: 1, name: "Charlie", active: false },
        #                         { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def update table, *rows
          ensure_session!
          @commit.update table, rows
        end

        ##
        # Inserts or replaces rows in a table. If any of the rows already exist,
        # it is deleted, and the column values provided are inserted instead.
        # Unlike #upsert, this means any values not explicitly written become
        # `NULL`.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#transaction} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Hash>] rows One or more hash objects with the hash keys
        #   matching the table's columns, and the hash values matching the
        #   table's values.
        #
        #   Ruby types are mapped to Spanner types as follows:
        #
        #   | Spanner     | Ruby           | Notes  |
        #   |-------------|----------------|---|
        #   | `BOOL`      | `true`/`false` | |
        #   | `INT64`     | `Integer`      | |
        #   | `FLOAT64`   | `Float`        | |
        #   | `NUMERIC`   | `BigDecimal`   | |
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.replace "users", [{ id: 1, name: "Charlie", active: false },
        #                          { id: 2, name: "Harvey",  active: true }]
        #   end
        #
        def replace table, *rows
          ensure_session!
          @commit.replace table, rows
        end

        ##
        # Deletes rows from a table. Succeeds whether or not the specified rows
        # were present.
        #
        # All changes are accumulated in memory until the block passed to
        # {Client#transaction} completes.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Object, Array<Object>] keys A single, or list of keys or key
        #   ranges to match returned data to. Values should have exactly as many
        #   elements as there are columns in the primary key.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction { |tx| tx.delete "users", [1, 2, 3] }
        #
        def delete table, keys = []
          ensure_session!
          @commit.delete table, keys
        end

        ##
        # @private
        # Returns the field names and types for a table.
        #
        # @param [String] table The name of the table in the database to
        #   retrieve types for
        #
        # @return [Hash, Array] The types of the returned data. The default is a
        #   Hash. Is a nested Array of Arrays when `pairs` is specified.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     users_types = tx.fields_for "users"
        #     tx.insert "users", [{ id: 1, name: "Charlie", active: false },
        #                         { id: 2, name: "Harvey",  active: true }],
        #               types: users_types
        #   end
        #
        def fields_for table
          execute_query("SELECT * FROM #{table} WHERE 1 = 0").fields
        end

        ##
        # Creates a configuration object ({Fields}) that may be provided to
        # queries or used to create STRUCT objects. (The STRUCT will be
        # represented by the {Data} class.) See {Client#execute} and/or
        # {Fields#struct}.
        #
        # For more information, see [Data Types - Constructing a
        # STRUCT](https://cloud.google.com/spanner/docs/data-types#constructing-a-struct).
        #
        # @param [Array, Hash] types Accepts an array or hash types.
        #
        #   Arrays can contain just the type value, or a sub-array of the
        #   field's name and type value. Hash keys must contain the field name
        #   as a `Symbol` or `String`, or the field position as an `Integer`.
        #   Hash values must contain the type value. If a Hash is used the
        #   fields will be created using the same order as the Hash keys.
        #
        #   Supported type values incude:
        #
        #   * `:BOOL`
        #   * `:BYTES`
        #   * `:DATE`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:INT64`
        #   * `:STRING`
        #   * `:TIMESTAMP`
        #   * `Array` - Lists are specified by providing the type code in an
        #     array. For example, an array of integers are specified as
        #     `[:INT64]`.
        #   * {Fields} - Nested Structs are specified by providing a Fields
        #     object.
        #
        # @return [Fields] The fields of the given types.
        #
        # @example Create a STRUCT value with named fields using Fields object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     named_type = tx.fields(
        #       { id: :INT64, name: :STRING, active: :BOOL }
        #     )
        #     named_data = named_type.struct(
        #       { id: 42, name: nil, active: false }
        #     )
        #   end
        #
        # @example Create a STRUCT value with anonymous field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     anon_type = tx.fields [:INT64, :STRING, :BOOL]
        #     anon_data = anon_type.struct [42, nil, false]
        #   end
        #
        # @example Create a STRUCT value with duplicate field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     dup_type = tx.fields [[:x, :INT64], [:x, :STRING], [:x, :BOOL]]
        #     dup_data = dup_type.struct [42, nil, false]
        #   end
        #
        def fields types
          Fields.new types
        end

        ##
        # Creates a Cloud Spanner Range. This can be used in place of a Ruby
        # Range when needing to exclude the beginning value.
        #
        # @param [Object] beginning The object that defines the beginning of the
        #   range.
        # @param [Object] ending The object that defines the end of the range.
        # @param [Boolean] exclude_begin Determines if the range excludes its
        #   beginning value. Default is `false`.
        # @param [Boolean] exclude_end Determines if the range excludes its
        #   ending value. Default is `false`.
        #
        # @return [Google::Cloud::Spanner::Range] The new Range instance.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     key_range = tx.range 1, 100
        #     results = tx.read "users", [:id, :name], keys: key_range
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def range beginning, ending, exclude_begin: false, exclude_end: false
          Range.new beginning, ending,
                    exclude_begin: exclude_begin,
                    exclude_end: exclude_end
        end

        ##
        # Creates a column value object representing setting a field's value to
        # the timestamp of the commit. (See {Client#commit_timestamp})
        #
        # This placeholder value can only be used for timestamp columns that
        # have set the option "(allow_commit_timestamp=true)" in the schema.
        #
        # @return [ColumnValue] The commit timestamp column value object.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.insert "users", [
        #       { id: 5, name: "Murphy", updated_at: tx.commit_timestamp }
        #     ]
        #   end
        #
        def commit_timestamp
          ColumnValue.commit_timestamp
        end

        ##
        # @private
        # Keeps the transaction current by creating a new transaction.
        def keepalive!
          ensure_session!
          @grpc = session.create_transaction.instance_variable_get :@grpc
        end

        ##
        # @private
        # Permanently deletes the transaction and session.
        def release!
          ensure_session!
          session.release!
        end

        ##
        # @private
        # Determines if the transaction has been idle longer than the given
        # duration.
        def idle_since? duration
          session.idle_since? duration
        end

        ##
        # @private
        # All of the mutations created in the transaction block.
        def mutations
          @commit.mutations
        end

        ##
        # @private Creates a new Transaction instance from a
        # `Google::Cloud::Spanner::V1::Transaction`.
        def self.from_grpc grpc, session
          new.tap do |s|
            s.instance_variable_set :@grpc,    grpc
            s.instance_variable_set :@session, session
          end
        end

        protected

        # The TransactionSelector to be used for queries
        def tx_selector
          return nil if transaction_id.nil?
          V1::TransactionSelector.new id: transaction_id
        end

        ##
        # @private Build request options. If transaction tag is set
        #   then add into request options.
        def build_request_options options
          options = Convert.to_request_options options, tag_type: :request_tag

          if transaction_tag
            options ||= {}
            options[:transaction_tag] = transaction_tag
          end

          options
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_session!
          raise "Must have active connection to service" unless session
        end

        def service
          session.service
        end
      end
    end
  end
end
