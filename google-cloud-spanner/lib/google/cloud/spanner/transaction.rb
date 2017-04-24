# Copyright 2017 Google Inc. All rights reserved.
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
      #       puts "User #{row[:id]} is #{row[:name]}""
      #     end
      #   end
      #
      class Transaction
        # @private The gRPC Service object.
        attr_accessor :service

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
        #   something like `:msg_id -> 1`.
        # @param [Boolean] streaming When `true`, all result are returned as a
        #   stream. There is no limit on the size of the returned result set.
        #   However, no individual row in the result set can exceed 100 MiB, and
        #   no column value can exceed 10 MiB.
        #
        #  When `false`, all result are returned in a single reply. This method
        #  cannot be used to return a result set larger than 10 MiB; if the
        #  query yields more data than that, the query fails with an error.
        #
        # @return [Google::Cloud::Spanner::Results]
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
        #       puts "User #{row[:id]} is #{row[:name]}""
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
        #       puts "User #{row[:id]} is #{row[:name]}""
        #     end
        #   end
        #
        # @example Query without streaming results:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.execute "SELECT * FROM users WHERE id = @user_id",
        #                          params: { user_id: 1 },
        #                          streaming: false
        #
        #     user_row = results.rows.first
        #     puts "User #{user_row[:id]} is #{user_row[:name]}"
        #   end
        #
        def execute sql, params: nil, streaming: true
          ensure_service!
          if streaming
            Results.from_enum service.streaming_execute_sql \
              session_name, sql, transaction: tx_selector, params: params
          else
            Results.from_grpc service.execute_sql \
              session_name, sql, transaction: tx_selector, params: params
          end
        end
        alias_method :query, :execute

        ##
        # Read rows from a database table, as a simple alternative to
        # {#execute}.
        #
        # @param [String] table The name of the table in the database to be
        #   read.
        # @param [Array<String>] columns The columns of table to be returned for
        #   each row matching this request.
        # @param [Object, Array<Object>] id A single, or list of keys to match
        #   returned data to. Values should have exactly as many elements as
        #   there are columns in the primary key.
        # @param [Integer] limit If greater than zero, no more than this number
        #   of rows will be returned. The default is no limit.
        # @param [Boolean] streaming When `true`, all result are returned as a
        #   stream. There is no limit on the size of the returned result set.
        #   However, no individual row in the result set can exceed 100 MiB, and
        #   no column value can exceed 10 MiB.
        #
        # @return [Google::Cloud::Spanner::Results]
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.read "users", ["id, "name"]
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}""
        #     end
        #   end
        #
        # @example Read without streaming results:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     results = tx.read "users", ["id, "name"], streaming: false
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}""
        #     end
        #   end
        #
        def read table, columns, id: nil, limit: nil, streaming: true
          ensure_service!
          if streaming
            Results.from_enum service.streaming_read_table \
              session_name, table, columns, id: id, transaction: tx_selector,
                                            limit: limit
          else
            Results.from_grpc service.read_table \
              session_name, table, columns, id: id, transaction: tx_selector,
                                            limit: limit
          end
        end

        # Creates changes to be applied to rows in the database.
        #
        # @yield [commit] The block for updating the data.
        # @yieldparam [Google::Cloud::Spanner::Commit] commit The Commit object.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction do |tx|
        #     tx.commit do |c|
        #       c.update "users", [{ id: 1, name: "Charlie", active: false }]
        #       c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
        #     end
        #   end
        #
        def commit
          ensure_service!
          commit = Commit.new
          yield commit
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
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
          ensure_service!
          commit = Commit.new
          commit.upsert table, rows
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
        end
        alias_method :save, :upsert

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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
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
          ensure_service!
          commit = Commit.new
          commit.insert table, rows
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
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
          ensure_service!
          commit = Commit.new
          commit.update table, rows
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
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
        #   | `STRING`    | `String`       | |
        #   | `DATE`      | `Date`         | |
        #   | `TIMESTAMP` | `Time`, `DateTime` | |
        #   | `BYTES`     | `File`, `IO`, `StringIO`, or similar | |
        #   | `ARRAY`     | `Array` | Nested arrays are not supported. |
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
          ensure_service!
          commit = Commit.new
          commit.replace table, rows
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
        end

        ##
        # Deletes rows from a table. Succeeds whether or not the specified rows
        # were present.
        #
        # @param [String] table The name of the table in the database to be
        #   modified.
        # @param [Array<Object>] id One or more primary keys of the rows within
        #   table to delete.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.transaction { |tx| tx.delete "users", [1, 2, 3] }
        #
        def delete table, *id
          ensure_service!
          commit = Commit.new
          commit.delete table, id
          service.commit session_name, commit.mutations,
                         transaction_id: transaction_id
        end

        ##
        # @private Creates a new Transaction instance from a
        # Google::Spanner::V1::Transaction.
        def self.from_grpc grpc, session
          new.tap do |s|
            s.instance_variable_set :@transaction_grpc, grpc
            s.instance_variable_set :@session_grpc,     session.grpc
            s.instance_variable_set :@service,          session.service
          end
        end

        protected

        ##
        # The full path for the session resource.
        def session_name
          @session_grpc.name
        end

        def transaction_id
          return nil if @transaction_grpc.nil?
          @transaction_grpc.id
        end

        # The TransactionSelector to be used for queries
        def tx_selector
          return nil if transaction_id.nil?
          Google::Spanner::V1::TransactionSelector.new id: transaction_id
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
