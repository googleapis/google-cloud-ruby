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
require "google/cloud/spanner/project"
require "google/cloud/spanner/data"
require "google/cloud/spanner/pool"
require "google/cloud/spanner/session"
require "google/cloud/spanner/transaction"
require "google/cloud/spanner/snapshot"
require "google/cloud/spanner/range"
require "google/cloud/spanner/column_value"
require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Client
      #
      # A client is used to read and/or modify data in a Cloud Spanner database.
      #
      # See {Google::Cloud::Spanner::Project#client}.
      #
      # @example
      #   require "google/cloud"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
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
      class Client
        ##
        # @private Creates a new Spanner Client instance.
        def initialize project, instance_id, database_id, session_labels: nil,
                       pool_opts: {}
          @project = project
          @instance_id = instance_id
          @database_id = database_id
          @session_labels = session_labels
          @pool = Pool.new self, pool_opts
        end

        # The unique identifier for the project.
        # @return [String]
        def project_id
          @project.service.project
        end

        # The unique identifier for the instance.
        # @return [String]
        def instance_id
          @instance_id
        end

        # The unique identifier for the database.
        # @return [String]
        def database_id
          @database_id
        end

        # The Spanner project connected to.
        # @return [Project]
        def project
          @project
        end

        # The Spanner instance connected to.
        # @return [Instance]
        def instance
          @project.instance instance_id
        end

        # The Spanner database connected to.
        # @return [Database]
        def database
          @project.database instance_id, database_id
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
        # @param [Hash] single_use Perform the read with a single-use snapshot
        #   (read-only transaction). (See
        #   [TransactionOptions](https://cloud.google.com/spanner/docs/reference/rpc/google.spanner.v1#transactionoptions).)
        #   The snapshot can be created by providing exactly one of the
        #   following options in the hash:
        #
        #   * **Strong**
        #     * `:strong` (true, false) Read at a timestamp where all previously
        #       committed transactions are visible.
        #   * **Exact**
        #     * `:timestamp`/`:read_timestamp` (Time, DateTime) Executes all
        #       reads at the given timestamp. Unlike other modes, reads at a
        #       specific timestamp are repeatable; the same read at the same
        #       timestamp always returns the same data. If the timestamp is in
        #       the future, the read will block until the specified timestamp,
        #       modulo the read's deadline.
        #
        #       Useful for large scale consistent reads such as mapreduces, or
        #       for coordinating many reads against a consistent snapshot of the
        #       data.
        #     * `:staleness`/`:exact_staleness` (Numeric) Executes all reads at
        #       a timestamp that is exactly the number of seconds provided old.
        #       The timestamp is chosen soon after the read is started.
        #
        #       Guarantees that all writes that have committed more than the
        #       specified number of seconds ago are visible. Because Cloud
        #       Spanner chooses the exact timestamp, this mode works even if the
        #       client's local clock is substantially skewed from Cloud Spanner
        #       commit timestamps.
        #
        #       Useful for reading at nearby replicas without the distributed
        #       timestamp negotiation overhead of single-use
        #       `bounded_staleness`.
        #   * **Bounded**
        #     * `:bounded_timestamp`/`:min_read_timestamp` (Time, DateTime)
        #       Executes all reads at a timestamp greater than the value
        #       provided.
        #
        #       This is useful for requesting fresher data than some previous
        #       read, or data that is fresh enough to observe the effects of
        #       some previously committed transaction whose timestamp is known.
        #     * `:bounded_staleness`/`:max_staleness` (Numeric) Read data at a
        #       timestamp greater than or equal to the number of seconds
        #       provided. Guarantees that all writes that have committed more
        #       than the specified number of seconds ago are visible. Because
        #       Cloud Spanner chooses the exact timestamp, this mode works even
        #       if the client's local clock is substantially skewed from Cloud
        #       Spanner commit timestamps.
        #
        #       Useful for reading the freshest data available at a nearby
        #       replica, while bounding the possible staleness if the local
        #       replica has fallen behind.
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
        #     params: { user_struct: user_data }
        #   )
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def execute_query sql, params: nil, types: nil, single_use: nil
          validate_single_use_args! single_use
          ensure_service!

          params, types = Convert.to_input_params_and_types params, types

          single_use_tx = single_use_transaction single_use
          results = nil
          @pool.with_session do |session|
            results = session.execute_query \
              sql, params: params, types: types, transaction: single_use_tx
          end
          results
        end
        alias execute execute_query
        alias query execute_query
        alias execute_sql execute_query

        ##
        # Executes a Partitioned DML SQL statement.
        #
        # Partitioned DML is an alternate implementation with looser semantics
        # to enable large-scale changes without running into transaction size
        # limits or (accidentally) locking the entire table in one large
        # transaction. At a high level, it partitions the keyspace and executes
        # the statement on each partition in separate internal transactions.
        #
        # Partitioned DML does not guarantee database-wide atomicity of the
        # statement - it guarantees row-based atomicity, which includes updates
        # to any indices. Additionally, it does not guarantee that it will
        # execute exactly one time against each row - it guarantees "at least
        # once" semantics.
        #
        # Where DML statements must be executed using Transaction (see
        # {Transaction#execute_update}), Paritioned DML statements are executed
        # outside of a read/write transaction.
        #
        # Not all DML statements can be executed in the Partitioned DML mode and
        # the backend will return an error for the statements which are not
        # supported.
        #
        # DML statements must be fully-partitionable. Specifically, the
        # statement must be expressible as the union of many statements which
        # each access only a single row of the table.
        # {Google::Cloud::InvalidArgumentError} is raised if the statement does
        # not qualify.
        #
        # The method will block until the update is complete. Running a DML
        # statement with this method does not offer exactly once semantics, and
        # therefore the DML statement should be idempotent. The DML statement
        # must be fully-partitionable. Specifically, the statement must be
        # expressible as the union of many statements which each access only a
        # single row of the table. This is a Partitioned DML transaction in
        # which a single Partitioned DML statement is executed. Partitioned DML
        # partitions the and runs the DML statement over each partition in
        # parallel using separate, internal transactions that commit
        # independently. Partitioned DML transactions do not need to be
        # committed.
        #
        # Partitioned DML updates are used to execute a single DML statement
        # with a different execution strategy that provides different, and often
        # better, scalability properties for large, table-wide operations than
        # DML in a {Transaction#execute_update} transaction. Smaller scoped
        # statements, such as an OLTP workload, should prefer using
        # {Transaction#execute_update}.
        #
        # That said, Partitioned DML is not a drop-in replacement for standard
        # DML used in {Transaction#execute_update}.
        #
        # * The DML statement must be fully-partitionable. Specifically, the
        #   statement must be expressible as the union of many statements which
        #   each access only a single row of the table.
        # * The statement is not applied atomically to all rows of the table.
        #   Rather, the statement is applied atomically to partitions of the
        #   table, in independent internal transactions. Secondary index rows
        #   are updated atomically with the base table rows.
        # * Partitioned DML does not guarantee exactly-once execution semantics
        #   against a partition. The statement will be applied at least once to
        #   each partition. It is strongly recommended that the DML statement
        #   should be idempotent to avoid unexpected results. For instance, it
        #   is potentially dangerous to run a statement such as `UPDATE table
        #   SET column = column + 1` as it could be run multiple times against
        #   some rows.
        # * The partitions are committed automatically - there is no support for
        #   Commit or Rollback. If the call returns an error, or if the client
        #   issuing the DML statement dies, it is possible that some rows had
        #   the statement executed on them successfully. It is also possible
        #   that statement was never executed against other rows.
        # * If any error is encountered during the execution of the partitioned
        #   DML operation (for instance, a UNIQUE INDEX violation, division by
        #   zero, or a value that cannot be stored due to schema constraints),
        #   then the operation is stopped at that point and an error is
        #   returned. It is possible that at this point, some partitions have
        #   been committed (or even committed multiple times), and other
        #   partitions have not been run at all.
        #
        # Given the above, Partitioned DML is good fit for large, database-wide,
        # operations that are idempotent, such as deleting old rows from a very
        # large table.
        #
        # @param [String] sql The Partitioned DML statement string. See [Query
        #   syntax](https://cloud.google.com/spanner/docs/query-syntax).
        #
        #   The Partitioned DML statement string can contain parameter
        #   placeholders. A parameter placeholder consists of "@" followed by
        #   the parameter name. Parameter names consist of any combination of
        #   letters, numbers, and underscores.
        # @param [Hash] params Parameters for the Partitioned DML statement
        #   string. The parameter placeholders, minus the "@", are the the hash
        #   keys, and the literal values are the hash values. If the query
        #   string contains something like "WHERE id > @msg_id", then the params
        #   must contain something like `:msg_id => 1`.
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
        # @return [Integer] The lower bound number of rows that were modified.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   row_count = db.execute_partition_update \
        #    "UPDATE users SET friends = NULL WHERE active = false"
        #
        # @example Query using query parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   row_count = db.execute_partition_update \
        #    "UPDATE users SET friends = NULL WHERE active = @active",
        #    params: { active: false }
        #
        def execute_partition_update sql, params: nil, types: nil
          ensure_service!

          params, types = Convert.to_input_params_and_types params, types

          results = nil
          @pool.with_session do |session|
            results = session.execute_query \
              sql, params: params, types: types,
                   transaction: pdml_transaction(session)
          end
          # Stream all PartialResultSet to get ResultSetStats
          results.rows.to_a
          # Raise an error if there is not a row count returned
          if results.row_count.nil?
            raise Google::Cloud::InvalidArgumentError,
                  "Partitioned DML statement is invalid."
          end
          results.row_count
        end
        alias execute_pdml execute_partition_update

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
        # @param [Hash] single_use Perform the read with a single-use snapshot
        #   (read-only transaction). (See
        #   [TransactionOptions](https://cloud.google.com/spanner/docs/reference/rpc/google.spanner.v1#transactionoptions).)
        #   The snapshot can be created by providing exactly one of the
        #   following options in the hash:
        #
        #   * **Strong**
        #     * `:strong` (true, false) Read at a timestamp where all previously
        #       committed transactions are visible.
        #   * **Exact**
        #     * `:timestamp`/`:read_timestamp` (Time, DateTime) Executes all
        #       reads at the given timestamp. Unlike other modes, reads at a
        #       specific timestamp are repeatable; the same read at the same
        #       timestamp always returns the same data. If the timestamp is in
        #       the future, the read will block until the specified timestamp,
        #       modulo the read's deadline.
        #
        #       Useful for large scale consistent reads such as mapreduces, or
        #       for coordinating many reads against a consistent snapshot of the
        #       data.
        #     * `:staleness`/`:exact_staleness` (Numeric) Executes all reads at
        #       a timestamp that is exactly the number of seconds provided old.
        #       The timestamp is chosen soon after the read is started.
        #
        #       Guarantees that all writes that have committed more than the
        #       specified number of seconds ago are visible. Because Cloud
        #       Spanner chooses the exact timestamp, this mode works even if the
        #       client's local clock is substantially skewed from Cloud Spanner
        #       commit timestamps.
        #
        #       Useful for reading at nearby replicas without the distributed
        #       timestamp negotiation overhead of single-use
        #       `bounded_staleness`.
        #   * **Bounded**
        #     * `:bounded_timestamp`/`:min_read_timestamp` (Time, DateTime)
        #       Executes all reads at a timestamp greater than the value
        #       provided.
        #
        #       This is useful for requesting fresher data than some previous
        #       read, or data that is fresh enough to observe the effects of
        #       some previously committed transaction whose timestamp is known.
        #     * `:bounded_staleness`/`:max_staleness` (Numeric) Read data at a
        #       timestamp greater than or equal to the number of seconds
        #       provided. Guarantees that all writes that have committed more
        #       than the specified number of seconds ago are visible. Because
        #       Cloud Spanner chooses the exact timestamp, this mode works even
        #       if the client's local clock is substantially skewed from Cloud
        #       Spanner commit timestamps.
        #
        #       Useful for reading the freshest data available at a nearby
        #       replica, while bounding the possible staleness if the local
        #       replica has fallen behind.
        #
        # @return [Google::Cloud::Spanner::Results] The results of the read.
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
        # @example Use the `keys` option to pass keys and/or key ranges to read.
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   results = db.read "users", [:id, :name], keys: 1..5
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def read table, columns, keys: nil, index: nil, limit: nil,
                 single_use: nil
          validate_single_use_args! single_use
          ensure_service!

          columns = Array(columns).map(&:to_s)
          keys = Convert.to_key_set keys

          single_use_tx = single_use_transaction single_use
          results = nil
          @pool.with_session do |session|
            results = session.read \
              table, columns, keys: keys, index: index, limit: limit,
                              transaction: single_use_tx
          end
          results
        end

        ##
        # Inserts or updates rows in a table. If any of the rows already exist,
        # then its column values are overwritten with the ones provided. Any
        # column values not explicitly written are preserved.
        #
        # Changes are made immediately upon calling this method using a
        # single-use transaction. To make multiple changes in the same
        # single-use transaction use {#commit}. To make changes in a transaction
        # that supports reads and automatic retry protection use {#transaction}.
        #
        # **Note:** This method does not feature replay protection present in
        # {Transaction#upsert} (See {#transaction}). This method makes a single
        # RPC, whereas {Transaction#upsert} requires two RPCs (one of which may
        # be performed in advance), and so this method may be appropriate for
        # latency sensitive and/or high throughput blind upserts.
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def upsert table, *rows
          @pool.with_session do |session|
            session.upsert table, rows
          end
        end
        alias save upsert

        ##
        # Inserts new rows in a table. If any of the rows already exist, the
        # write or request fails with {Google::Cloud::AlreadyExistsError}.
        #
        # Changes are made immediately upon calling this method using a
        # single-use transaction. To make multiple changes in the same
        # single-use transaction use {#commit}. To make changes in a transaction
        # that supports reads and automatic retry protection use {#transaction}.
        #
        # **Note:** This method does not feature replay protection present in
        # {Transaction#insert} (See {#transaction}). This method makes a single
        # RPC, whereas {Transaction#insert} requires two RPCs (one of which may
        # be performed in advance), and so this method may be appropriate for
        # latency sensitive and/or high throughput blind inserts.
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def insert table, *rows
          @pool.with_session do |session|
            session.insert table, rows
          end
        end

        ##
        # Updates existing rows in a table. If any of the rows does not already
        # exist, the request fails with {Google::Cloud::NotFoundError}.
        #
        # Changes are made immediately upon calling this method using a
        # single-use transaction. To make multiple changes in the same
        # single-use transaction use {#commit}. To make changes in a transaction
        # that supports reads and automatic retry protection use {#transaction}.
        #
        # **Note:** This method does not feature replay protection present in
        # {Transaction#update} (See {#transaction}). This method makes a single
        # RPC, whereas {Transaction#update} requires two RPCs (one of which may
        # be performed in advance), and so this method may be appropriate for
        # latency sensitive and/or high throughput blind updates.
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def update table, *rows
          @pool.with_session do |session|
            session.update table, rows
          end
        end

        ##
        # Inserts or replaces rows in a table. If any of the rows already exist,
        # it is deleted, and the column values provided are inserted instead.
        # Unlike #upsert, this means any values not explicitly written become
        # `NULL`.
        #
        # Changes are made immediately upon calling this method using a
        # single-use transaction. To make multiple changes in the same
        # single-use transaction use {#commit}. To make changes in a transaction
        # that supports reads and automatic retry protection use {#transaction}.
        #
        # **Note:** This method does not feature replay protection present in
        # {Transaction#replace} (See {#transaction}). This method makes a single
        # RPC, whereas {Transaction#replace} requires two RPCs (one of which may
        # be performed in advance), and so this method may be appropriate for
        # latency sensitive and/or high throughput blind replaces.
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        #   See [Data
        #   types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def replace table, *rows
          @pool.with_session do |session|
            session.replace table, rows
          end
        end

        ##
        # Deletes rows from a table. Succeeds whether or not the specified rows
        # were present.
        #
        # Changes are made immediately upon calling this method using a
        # single-use transaction. To make multiple changes in the same
        # single-use transaction use {#commit}. To make changes in a transaction
        # that supports reads and automatic retry protection use {#transaction}.
        #
        # **Note:** This method does not feature replay protection present in
        # {Transaction#delete} (See {#transaction}). This method makes a single
        # RPC, whereas {Transaction#delete} requires two RPCs (one of which may
        # be performed in advance), and so this method may be appropriate for
        # latency sensitive and/or high throughput blind deletions.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Object, Array<Object>] keys A single, or list of keys or key
        #   ranges to match returned data to. Values should have exactly as many
        #   elements as there are columns in the primary key.
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def delete table, keys = []
          @pool.with_session do |session|
            session.delete table, keys
          end
        end

        ##
        # Creates and commits a transaction for writes that execute atomically
        # at a single logical point in time across columns, rows, and tables in
        # a database.
        #
        # All changes are accumulated in memory until the block completes.
        # Unlike {#transaction}, which can also perform reads, this operation
        # accepts only mutations and makes a single API request.
        #
        # **Note:** This method does not feature replay protection present in
        # {#transaction}. This method makes a single RPC, whereas {#transaction}
        # requires two RPCs (one of which may be performed in advance), and so
        # this method may be appropriate for latency sensitive and/or high
        # throughput blind changes.
        #
        # @yield [commit] The block for mutating the data.
        # @yieldparam [Google::Cloud::Spanner::Commit] commit The Commit object.
        #
        # @return [Time] The timestamp at which the operation committed.
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
        def commit &block
          raise ArgumentError, "Must provide a block" unless block_given?

          @pool.with_session do |session|
            session.commit(&block)
          end
        end

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength

        ##
        # Creates a transaction for reads and writes that execute atomically at
        # a single logical point in time across columns, rows, and tables in a
        # database.
        #
        # The transaction will always commit unless an error is raised. If the
        # error raised is {Rollback} the transaction method will return without
        # passing on the error. All other errors will be passed on.
        #
        # All changes are accumulated in memory until the block completes.
        # Transactions will be automatically retried when possible, until
        # `deadline` is reached. This operation makes separate API requests to
        # begin and commit the transaction.
        #
        # @param [Numeric] deadline The total amount of time in seconds the
        #   transaction has to succeed. The default is `120`.
        #
        # @yield [transaction] The block for reading and writing data.
        # @yieldparam [Google::Cloud::Spanner::Transaction] transaction The
        #   Transaction object.
        #
        # @return [Time] The timestamp at which the transaction committed.
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
        #
        #     tx.update "users", [{ id: 1, name: "Charlie", active: false }]
        #     tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        #   end
        #
        # @example Manually rollback the transaction using {Rollback}:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.update "users", [{ id: 1, name: "Charlie", active: false }]
        #     tx.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        #
        #     if something_wrong?
        #       # Rollback the transaction without passing on the error
        #       # outside of the transaction method.
        #       raise Google::Cloud::Spanner::Rollback
        #     end
        #   end
        #
        def transaction deadline: 120
          ensure_service!
          unless Thread.current[:transaction_id].nil?
            raise "Nested transactions are not allowed"
          end

          deadline = validate_deadline deadline
          backoff = 1.0
          start_time = current_time

          @pool.with_transaction do |tx|
            begin
              Thread.current[:transaction_id] = tx.transaction_id
              yield tx
              commit_resp = @project.service.commit \
                tx.session.path, tx.mutations, transaction_id: tx.transaction_id
              return Convert.timestamp_to_time commit_resp.commit_timestamp
            rescue GRPC::Aborted, Google::Cloud::AbortedError => err
              # Re-raise if deadline has passed
              if current_time - start_time > deadline
                if err.is_a? GRPC::BadStatus
                  err = Google::Cloud::Error.from_error err
                end
                raise err
              end
              # Sleep the amount from RetryDelay, or incremental backoff
              sleep(delay_from_aborted(err) || backoff *= 1.3)
              # Create new transaction on the session and retry the block
              tx = tx.session.create_transaction
              retry
            rescue StandardError => err
              # Rollback transaction when handling unexpected error
              tx.session.rollback tx.transaction_id
              # Return nil if raised with rollback.
              return nil if err.is_a? Rollback
              # Re-raise error.
              raise err
            ensure
              Thread.current[:transaction_id] = nil
            end
          end
        end

        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        ##
        # Creates a snapshot read-only transaction for reads that execute
        # atomically at a single logical point in time across columns, rows, and
        # tables in a database. For transactions that only read, snapshot
        # read-only transactions provide simpler semantics and are almost always
        # faster than read-write transactions.
        #
        # @param [true, false] strong Read at a timestamp where all previously
        #   committed transactions are visible.
        # @param [Time, DateTime] timestamp Executes all reads at the given
        #   timestamp. Unlike other modes, reads at a specific timestamp are
        #   repeatable; the same read at the same timestamp always returns the
        #   same data. If the timestamp is in the future, the read will block
        #   until the specified timestamp, modulo the read's deadline.
        #
        #   Useful for large scale consistent reads such as mapreduces, or for
        #   coordinating many reads against a consistent snapshot of the data.
        #   (See
        #   [TransactionOptions](https://cloud.google.com/spanner/docs/reference/rpc/google.spanner.v1#transactionoptions).)
        # @param [Time, DateTime] read_timestamp Same as `timestamp`.
        # @param [Numeric] staleness Executes all reads at a timestamp that is
        #   `staleness` seconds old. For example, the number 10.1 is translated
        #   to 10 seconds and 100 milliseconds.
        #
        #   Guarantees that all writes that have committed more than the
        #   specified number of seconds ago are visible. Because Cloud Spanner
        #   chooses the exact timestamp, this mode works even if the client's
        #   local clock is substantially skewed from Cloud Spanner commit
        #   timestamps.
        #
        #   Useful for reading at nearby replicas without the distributed
        #   timestamp negotiation overhead of single-use `staleness`. (See
        #   [TransactionOptions](https://cloud.google.com/spanner/docs/reference/rpc/google.spanner.v1#transactionoptions).)
        # @param [Numeric] exact_staleness Same as `staleness`.
        #
        # @yield [snapshot] The block for reading and writing data.
        # @yieldparam [Google::Cloud::Spanner::Snapshot] snapshot The Snapshot
        #   object.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.snapshot do |snp|
        #     results = snp.execute_query "SELECT * FROM users"
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def snapshot strong: nil, timestamp: nil, read_timestamp: nil,
                     staleness: nil, exact_staleness: nil
          validate_snapshot_args! strong: strong, timestamp: timestamp,
                                  read_timestamp: read_timestamp,
                                  staleness: staleness,
                                  exact_staleness: exact_staleness

          ensure_service!
          unless Thread.current[:transaction_id].nil?
            raise "Nested snapshots are not allowed"
          end

          @pool.with_session do |session|
            begin
              snp_grpc = @project.service.create_snapshot \
                session.path, strong: strong,
                              timestamp: (timestamp || read_timestamp),
                              staleness: (staleness || exact_staleness)
              Thread.current[:transaction_id] = snp_grpc.id
              snp = Snapshot.from_grpc(snp_grpc, session)
              yield snp if block_given?
            ensure
              Thread.current[:transaction_id] = nil
            end
          end
          nil
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
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   named_type = db.fields(
        #     { id: :INT64, name: :STRING, active: :BOOL }
        #   )
        #   named_data = named_type.struct(
        #     { id: 42, name: nil, active: false }
        #   )
        #
        # @example Create a STRUCT value with anonymous field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   anon_type = db.fields [:INT64, :STRING, :BOOL]
        #   anon_data = anon_type.struct [42, nil, false]
        #
        # @example Create a STRUCT value with duplicate field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   dup_type = db.fields [[:x, :INT64], [:x, :STRING], [:x, :BOOL]]
        #   dup_data = dup_type.struct [42, nil, false]
        #
        def fields types
          Fields.new types
        end

        ##
        # @private
        # Executes a query to retrieve the field names and types for a table.
        #
        # @param [String] table The name of the table in the database to
        #   retrieve fields for.
        #
        # @return [Fields] The fields of the given table.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   users_types = db.fields_for "users"
        #   db.insert "users", [{ id: 1, name: "Charlie", active: false },
        #                       { id: 2, name: "Harvey",  active: true }],
        #             types: users_types
        #
        def fields_for table
          execute_query("SELECT * FROM #{table} WHERE 1 = 0").fields
        end

        ##
        # Creates a Spanner Range. This can be used in place of a Ruby Range
        # when needing to exclude the beginning value.
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
        #
        #   db = spanner.client "my-instance", "my-database"
        #
        #   key_range = db.range 1, 100
        #   results = db.read "users", [:id, :name], keys: key_range
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def range beginning, ending, exclude_begin: false, exclude_end: false
          Range.new beginning, ending,
                    exclude_begin: exclude_begin,
                    exclude_end: exclude_end
        end

        ##
        # Creates a column value object representing setting a field's value to
        # the timestamp of the commit. (See {ColumnValue.commit_timestamp})
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
        #   # create column value object
        #   commit_timestamp = db.commit_timestamp
        #
        #   db.commit do |c|
        #     c.insert "users", [
        #       { id: 5, name: "Murphy", updated_at: commit_timestamp }
        #     ]
        #   end
        #
        def commit_timestamp
          ColumnValue.commit_timestamp
        end

        ##
        # Closes the client connection and releases resources.
        #
        def close
          @pool.close
        end

        ##
        # @private
        # Creates a new session object every time.
        def create_new_session
          ensure_service!
          grpc = @project.service.create_session \
            Admin::Database::V1::DatabaseAdminClient.database_path(
              project_id, instance_id, database_id
            ),
            labels: @session_labels
          Session.from_grpc(grpc, @project.service)
        end

        # @private
        def to_s
          "(project_id: #{project_id}, instance_id: #{instance_id}, " \
            "database_id: #{database_id})"
        end

        # @private
        def inspect
          "#<#{self.class.name} #{self}>"
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless @project.service
        end

        ##
        # Check for valid snapshot arguments
        def validate_single_use_args! opts
          return true if opts.nil? || opts.empty?
          valid_keys = %i[strong timestamp read_timestamp staleness
                          exact_staleness bounded_timestamp
                          min_read_timestamp bounded_staleness max_staleness]
          if opts.keys.count == 1 && valid_keys.include?(opts.keys.first)
            return true
          end
          raise ArgumentError,
                "Must provide only one of the following single_use values: " \
                "#{valid_keys}"
        end

        ##
        # Create a single-use TransactionSelector
        def single_use_transaction opts
          return nil if opts.nil? || opts.empty?

          exact_timestamp = Convert.time_to_timestamp \
            opts[:timestamp] || opts[:read_timestamp]
          exact_staleness = Convert.number_to_duration \
            opts[:staleness] || opts[:exact_staleness]
          bounded_timestamp = Convert.time_to_timestamp \
            opts[:bounded_timestamp] || opts[:min_read_timestamp]
          bounded_staleness = Convert.number_to_duration \
            opts[:bounded_staleness] || opts[:max_staleness]

          Google::Spanner::V1::TransactionSelector.new(single_use:
            Google::Spanner::V1::TransactionOptions.new(read_only:
              Google::Spanner::V1::TransactionOptions::ReadOnly.new({
                strong: opts[:strong],
                read_timestamp: exact_timestamp,
                exact_staleness: exact_staleness,
                min_read_timestamp: bounded_timestamp,
                max_staleness: bounded_staleness,
                return_read_timestamp: true
              }.delete_if { |_, v| v.nil? })))
        end

        def pdml_transaction session
          pdml_tx_grpc = @project.service.create_pdml session.path
          Google::Spanner::V1::TransactionSelector.new id: pdml_tx_grpc.id
        end

        ##
        # Check for valid snapshot arguments
        def validate_snapshot_args! strong: nil,
                                    timestamp: nil, read_timestamp: nil,
                                    staleness: nil, exact_staleness: nil
          valid_args_count = [strong, timestamp, read_timestamp, staleness,
                              exact_staleness].compact.count
          return true if valid_args_count <= 1
          raise ArgumentError,
                "Can only provide one of the following arguments: " \
                "(strong, timestamp, read_timestamp, staleness, " \
                "exact_staleness)"
        end

        def validate_deadline deadline
          return 120 unless deadline.is_a? Numeric
          return 120 if deadline < 0
          deadline
        end

        ##
        # Defer to this method so we have something to mock for tests
        def current_time
          Time.now
        end

        ##
        # Retrieves the delay value from Google::Cloud::AbortedError or
        # GRPC::Aborted
        def delay_from_aborted err
          return nil if err.nil?
          if err.respond_to?(:metadata) && err.metadata["retryDelay"]
            # a correct metadata will look like this:
            # "{\"retryDelay\":{\"seconds\":60}}"
            seconds = err.metadata["retryDelay"]["seconds"].to_i
            nanos = err.metadata["retryDelay"]["nanos"].to_i
            return seconds if nanos.zero?
            return seconds + (nanos / 1000000000.0)
          end
          # No metadata? Try the inner error
          delay_from_aborted(err.cause)
        rescue StandardError
          # Any error indicates the backoff should be handled elsewhere
          nil
        end
      end
    end
  end
end
