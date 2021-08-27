# Copyright 2016 Google LLC
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


require "google/cloud/spanner/data"
require "google/cloud/spanner/results"
require "google/cloud/spanner/commit"
require "google/cloud/spanner/commit_response"
require "google/cloud/spanner/batch_update"

module Google
  module Cloud
    module Spanner
      ##
      # @private
      #
      # # Session
      #
      # A session can be used to perform transactions that read and/or modify
      # data in a Cloud Spanner database. Sessions are meant to be reused for
      # many consecutive transactions.
      #
      # Sessions can only execute one transaction at a time. To execute multiple
      # concurrent read-write/write-only transactions, create multiple sessions.
      # Note that standalone reads and queries use a transaction internally, and
      # count toward the one transaction limit.
      #
      # Cloud Spanner limits the number of sessions that can exist at any given
      # time; thus, it is a good idea to delete idle and/or unneeded sessions.
      # Aside from explicit deletes, Cloud Spanner can delete sessions for which
      # no operations are sent for more than an hour.
      #
      class Session
        ##
        # @private The `Google::Cloud::Spanner::V1::Session` object
        attr_accessor :grpc

        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private The hash of query options.
        attr_accessor :query_options

        # @private Creates a new Session instance.
        def initialize grpc, service, query_options: nil
          @grpc = grpc
          @service = service
          @query_options = query_options
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          @grpc.name.split("/")[5]
        end

        # The unique identifier for the session.
        # @return [String]
        def session_id
          @grpc.name.split("/")[7]
        end

        ##
        # The full path for the session resource. Values are of the form
        # `projects/<project_id>/instances/<instance_id>/databases/<database_id>/sessions/<session_id>`.
        # @return [String]
        def path
          @grpc.name
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
        # @param [Google::Cloud::Spanner::V1::TransactionSelector] transaction The
        #   transaction selector value to send. Only used for single-use
        #   transactions.
        # @param [Integer] seqno A per-transaction sequence number used to
        #   identify this request.
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
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.execute_query "SELECT * FROM users"
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query using query parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.execute_query(
        #     "SELECT * FROM users WHERE active = @active",
        #     params: { active: true }
        #   )
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query with a SQL STRUCT query parameter as a Hash:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   user_hash = { id: 1, name: "Charlie", active: false }
        #
        #   results = db.execute_query(
        #     "SELECT * FROM users WHERE " \
        #     "ID = @user_struct.id " \
        #     "AND name = @user_struct.name " \
        #     "AND active = @user_struct.active",
        #     params: { user_struct: user_hash }
        #   )
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Specify the SQL STRUCT type using Fields object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   user_type = db.fields id: :INT64, name: :STRING, active: :BOOL
        #   user_hash = { id: 1, name: nil, active: false }
        #
        #   results = db.execute_query(
        #     "SELECT * FROM users WHERE " \
        #     "ID = @user_struct.id " \
        #     "AND name = @user_struct.name " \
        #     "AND active = @user_struct.active",
        #     params: { user_struct: user_hash },
        #     types: { user_struct: user_type }
        #   )
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Or, query with a SQL STRUCT as a typed Data object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   user_type = db.fields id: :INT64, name: :STRING, active: :BOOL
        #   user_data = user_type.struct id: 1, name: nil, active: false
        #
        #   results = db.execute_query(
        #     "SELECT * FROM users WHERE " \
        #     "ID = @user_struct.id " \
        #     "AND name = @user_struct.name " \
        #     "AND active = @user_struct.active",
        #     params: { user_struct: user_struct }
        #   )
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query using query options:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.execute_query \
        #     "SELECT * FROM users", query_options: {
        #       optimizer_version: "1",
        #       optimizer_statistics_package: "auto_20191128_14_47_22UTC"
        #     }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query using custom timeout and retry policy:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
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
        #   results = db.execute_query \
        #     "SELECT * FROM users", call_options: call_options
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def execute_query sql, params: nil, types: nil, transaction: nil,
                          partition_token: nil, seqno: nil, query_options: nil,
                          request_options: nil, call_options: nil
          ensure_service!
          if query_options.nil?
            query_options = @query_options
          else
            query_options = @query_options.merge query_options unless @query_options.nil?
          end
          results = Results.execute_query service, path, sql,
                                          params: params,
                                          types: types,
                                          transaction: transaction,
                                          partition_token: partition_token,
                                          seqno: seqno,
                                          query_options: query_options,
                                          request_options: request_options,
                                          call_options: call_options
          @last_updated_at = Time.now
          results
        end

        ##
        # Executes DML statements in a batch.
        #
        # @param [Google::Cloud::Spanner::V1::TransactionSelector] transaction The
        #   transaction selector value to send. Only used for single-use
        #   transactions.
        # @param [Integer] seqno A per-transaction sequence number used to
        #   identify this request.
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        def batch_update transaction, seqno, request_options: nil,
                         call_options: nil
          ensure_service!

          raise ArgumentError, "block is required" unless block_given?
          batch = BatchUpdate.new

          yield batch

          results = service.execute_batch_dml path, transaction,
                                              batch.statements, seqno,
                                              request_options: request_options,
                                              call_options: call_options
          @last_updated_at = Time.now
          results
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
        # @param [Google::Cloud::Spanner::V1::TransactionSelector] transaction The
        #   transaction selector value to send. Only used for single-use
        #   transactions.
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.read "users", [:id, :name]
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def read table, columns, keys: nil, index: nil, limit: nil,
                 transaction: nil, partition_token: nil, request_options: nil,
                 call_options: nil
          ensure_service!

          results = Results.read service, path, table, columns,
                                 keys: keys, index: index, limit: limit,
                                 transaction: transaction,
                                 partition_token: partition_token,
                                 request_options: request_options,
                                 call_options: call_options
          @last_updated_at = Time.now
          results
        end

        def partition_query sql, transaction, params: nil, types: nil,
                            partition_size_bytes: nil, max_partitions: nil,
                            call_options: nil
          ensure_service!

          results = service.partition_query \
            path, sql, transaction, params: params, types: types,
                                    partition_size_bytes: partition_size_bytes,
                                    max_partitions: max_partitions,
                                    call_options: call_options

          @last_updated_at = Time.now

          results
        end

        def partition_read table, columns, transaction, keys: nil,
                           index: nil, partition_size_bytes: nil,
                           max_partitions: nil, call_options: nil
          ensure_service!

          results = service.partition_read \
            path, table, columns, transaction,
            keys: keys, index: index,
            partition_size_bytes: partition_size_bytes,
            max_partitions: max_partitions,
            call_options: call_options

          @last_updated_at = Time.now

          results
        end

        ##
        # Creates changes to be applied to rows in the database.
        #
        # @param [String] transaction_id The identifier of previously-started
        #   transaction to be used instead of starting a new transaction.
        #   Optional.
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`
        #
        # transaction. Default it is `false`.
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @yield [commit] The block for mutating the data.
        # @yieldparam [Google::Cloud::Spanner::Commit] commit The Commit object.
        #
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.commit do |c|
        #     c.update "users", [{ id: 1, name: "Charlie", active: false }]
        #     c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        #   end
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   commit_options = { return_commit_stats: true }
        #   commit_resp = db.commit commit_options: commit_options do |c|
        #     c.update "users", [{ id: 1, name: "Charlie", active: false }]
        #     c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        #   end
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def commit transaction_id: nil, commit_options: nil,
                   request_options: nil, call_options: nil
          ensure_service!
          commit = Commit.new
          yield commit
          commit_resp = service.commit path, commit.mutations,
                                       transaction_id: transaction_id,
                                       commit_options: commit_options,
                                       request_options: request_options,
                                       call_options: call_options
          @last_updated_at = Time.now
          resp = CommitResponse.from_grpc commit_resp
          commit_options ? resp : resp.timestamp
        end

        ##
        # Inserts or updates rows in a table. If any of the rows already exist,
        # then its column values are overwritten with the ones provided. Any
        # column values not explicitly written are preserved.
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
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.upsert "users", [{ id: 1, name: "Charlie", active: false },
        #                       { id: 2, name: "Harvey",  active: true }]
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   records = [{ id: 1, name: "Charlie", active: false },
        #             { id: 2, name: "Harvey",  active: true }]
        #   commit_options = { return_commit_stats: true }
        #   commit_resp = db.upsert "users", records, commit_options: commit_options
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def upsert table, *rows, transaction_id: nil, commit_options: nil,
                   request_options: nil, call_options: nil
          opts = {
            transaction_id: transaction_id,
            commit_options: commit_options,
            request_options: request_options,
            call_options: call_options
          }
          commit(**opts) do |c|
            c.upsert table, rows
          end
        end
        alias save upsert

        ##
        # Inserts new rows in a table. If any of the rows already exist, the
        # write or request fails with error `ALREADY_EXISTS`.
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
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.insert "users", [{ id: 1, name: "Charlie", active: false },
        #                       { id: 2, name: "Harvey",  active: true }]
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   records = [{ id: 1, name: "Charlie", active: false },
        #              { id: 2, name: "Harvey",  active: true }]
        #   commit_options = { return_commit_stats: true }
        #   commit_resp = db.insert "users", records, commit_options: commit_options
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def insert table, *rows, transaction_id: nil, commit_options: nil,
                   request_options: nil, call_options: nil
          opts = {
            transaction_id: transaction_id,
            commit_options: commit_options,
            request_options: request_options,
            call_options: call_options
          }
          commit(**opts) do |c|
            c.insert table, rows
          end
        end

        ##
        # Updates existing rows in a table. If any of the rows does not already
        # exist, the request fails with error `NOT_FOUND`.
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
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.update "users", [{ id: 1, name: "Charlie", active: false },
        #                       { id: 2, name: "Harvey",  active: true }]
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   records = [{ id: 1, name: "Charlie", active: false },
        #              { id: 2, name: "Harvey",  active: true }]
        #   commit_options = { return_commit_stats: true  }
        #   commit_resp = db.update "users", records, commit_options: commit_options
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def update table, *rows, transaction_id: nil, commit_options: nil,
                   request_options: nil, call_options: nil
          opts = {
            transaction_id: transaction_id,
            commit_options: commit_options,
            request_options: request_options,
            call_options: call_options
          }
          commit(**opts) do |c|
            c.update table, rows
          end
        end

        ##
        # Inserts or replaces rows in a table. If any of the rows already exist,
        # it is deleted, and the column values provided are inserted instead.
        # Unlike #upsert, this means any values not explicitly written become
        # `NULL`.
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
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`.
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.replace "users", [{ id: 1, name: "Charlie", active: false },
        #                        { id: 2, name: "Harvey",  active: true }]
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   records = [{ id: 1, name: "Charlie", active: false },
        #              { id: 2, name: "Harvey",  active: true }]
        #   commit_options = { return_commit_stats: true  }
        #   commit_resp = db.replace "users", records, commit_options: commit_options
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def replace table, *rows, transaction_id: nil, commit_options: nil,
                    request_options: nil, call_options: nil
          opts = {
            transaction_id: transaction_id,
            commit_options: commit_options,
            request_options: request_options,
            call_options: call_options
          }
          commit(**opts) do |c|
            c.replace table, rows
          end
        end

        ##
        # Deletes rows from a table. Succeeds whether or not the specified rows
        # were present.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Object, Array<Object>] keys A single, or list of keys or key
        #   ranges to match returned data to. Values should have exactly as many
        #   elements as there are columns in the primary key.
        # @param [Hash] commit_options A hash of commit options.
        #   e.g., return_commit_stats. Commit options are optional.
        #   The following options can be provided:
        #
        #   * `:return_commit_stats` (Boolean) A boolean value. If `true`,
        #     then statistics related to the transaction will be included in
        #     {CommitResponse}. Default value is `false`
        #
        # @param [Hash] request_options Common request options.
        #
        #   * `:request_tag` (String) A per-request tag which can be applied
        #     to queries or reads, used for statistics collection. Both
        #     request_tag and transaction_tag can be specified for a read or
        #     query that belongs to a transaction. This field is ignored for
        #     requests where it's not applicable (e.g. CommitRequest).
        #     `request_tag` must be a valid identifier of the form:
        #     `[a-zA-Z][a-zA-Z0-9_\-]` between 2 and 64 characters in length.
        #   * `:transaction_tag` (String) A tag used for statistics collection
        #     about this transaction. Both request_tag and transaction_tag can
        #     be specified for a read or query that belongs to a transaction.
        #     The value of transaction_tag should be the same for all requests
        #     belonging to the same transaction. If this request doesn't belong
        #     to any transaction, transaction_tag will be ignored.
        #     `transaction_tag` must be a valid identifier of the format:
        #     [a-zA-Z][a-zA-Z0-9_\-]{0,49}
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
        # @return [Time, CommitResponse] The timestamp at which the operation
        #   committed. If commit options are set it returns {CommitResponse}.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.delete "users", [1, 2, 3]
        #
        # @example Get commit stats
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   commit_options = { return_commit_stats: true }
        #   commit_resp = db.delete "users", [1,2,3], commit_options: commit_options
        #
        #   puts commit_resp.timestamp
        #   puts commit_resp.stats.mutation_count
        #
        def delete table, keys = [], transaction_id: nil, commit_options: nil,
                   request_options: nil, call_options: nil
          opts = {
            transaction_id: transaction_id,
            commit_options: commit_options,
            request_options: request_options,
            call_options: call_options
          }
          commit(**opts) do |c|
            c.delete table, keys
          end
        end

        ##
        # Rolls back the transaction, releasing any locks it holds.
        def rollback transaction_id
          service.rollback path, transaction_id
          @last_updated_at = Time.now
          true
        end

        ##
        # @private
        # Creates a new transaction object every time.
        def create_transaction
          tx_grpc = service.begin_transaction path
          Transaction.from_grpc tx_grpc, self
        end

        ##
        # Reloads the session resource. Useful for determining if the session is
        # still valid on the Spanner API.
        def reload!
          ensure_service!
          @grpc = service.get_session path
          @last_updated_at = Time.now
          self
        rescue Google::Cloud::NotFoundError
          labels = @grpc.labels.to_h unless @grpc.labels.to_h.empty?
          @grpc = service.create_session \
            V1::Spanner::Paths.database_path(
              project: project_id, instance: instance_id, database: database_id
            ),
            labels: labels
          @last_updated_at = Time.now
          self
        end

        ##
        # @private
        # Keeps the session alive by executing `"SELECT 1"`.
        def keepalive!
          ensure_service!
          execute_query "SELECT 1"
          true
        rescue Google::Cloud::NotFoundError
          labels = @grpc.labels.to_h unless @grpc.labels.to_h.empty?
          @grpc = service.create_session \
            V1::Spanner::Paths.database_path(
              project: project_id, instance: instance_id, database: database_id
            ),
            labels: labels
          false
        end

        ##
        # Permanently deletes the session.
        def release!
          ensure_service!
          service.delete_session path
        end

        ##
        # @private
        # Determines if the session has been idle longer than the given
        # duration.
        def idle_since? duration
          return true if @last_updated_at.nil?
          Time.now > @last_updated_at + duration
        end

        ##
        # @private Creates a new Session instance from a
        # `Google::Cloud::Spanner::V1::Session`.
        def self.from_grpc grpc, service, query_options: nil
          new grpc, service, query_options: query_options
        end

        ##
        # @private
        def session
          self
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
