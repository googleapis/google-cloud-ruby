# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/spanner/errors"
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

        def initialize
          @commit = Commit.new
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
        # Arguments can be passed using `params`, Ruby types are mapped to
        # Spanner types as follows:
        #
        # | Spanner     | Ruby           | Notes  |
        # |-------------|----------------|---|
        # | `BOOL`      | `true`/`false` | |
        # | `INT64`     | `Integer`      | |
        # | `FLOAT64`   | `Float`        | |
        # | `STRING`    | `String`       | |
        # | `DATE`      | `Date`         | |
        # | `TIMESTAMP` | `Time`, `DateTime` | |
        # | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        # | `ARRAY`     | `Array` | Nested arrays are not supported. |
        #
        # See [Data
        # types](https://cloud.google.com/spanner/docs/data-definition-language#data_types).
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
        #
        #   Arrays are specified by providing the type code in an array. For
        #   example, an array of integers are specified as `[:INT64]`.
        #
        #   Structs are not yet supported in query parameters.
        #
        #   Types are optional.
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
        #     results = tx.execute "SELECT * FROM users"
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
        #     results = tx.execute "SELECT * FROM users WHERE active = @active",
        #                          params: { active: true }
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def execute sql, params: nil, types: nil
          ensure_session!
          session.execute sql, params: params, types: types,
                               transaction: tx_selector
        end
        alias_method :query, :execute

        ##
        # Read rows from a database table, as a simple alternative to
        # {#execute}.
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
        def read table, columns, keys: nil, index: nil, limit: nil
          ensure_session!
          session.read table, columns, keys: keys, index: index, limit: limit,
                                       transaction: tx_selector
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
        alias_method :save, :upsert

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
          execute("SELECT * FROM #{table} WHERE 1 = 0").fields
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
        # Google::Spanner::V1::Transaction.
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
          Google::Spanner::V1::TransactionSelector.new id: transaction_id
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_session!
          fail "Must have active connection to service" unless session
        end

        def service
          session.service
        end
      end
    end
  end
end
