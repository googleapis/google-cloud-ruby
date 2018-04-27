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


require "google/cloud/spanner/convert"
require "google/cloud/spanner/results"

module Google
  module Cloud
    module Spanner
      ##
      # # Snapshot
      #
      # A snapshot in Cloud Spanner is a set of reads that execute atomically at
      # a single logical point in time across columns, rows, and tables in a
      # database.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #   db = spanner.client "my-instance", "my-database"
      #
      #   db.snapshot do |snp|
      #     results = snp.execute "SELECT * FROM users"
      #
      #     results.rows.each do |row|
      #       puts "User #{row[:id]} is #{row[:name]}"
      #     end
      #   end
      #
      class Snapshot
        # @private The Session object.
        attr_accessor :session

        ##
        # Identifier of the transaction results were run in.
        # @return [String] The transaction id.
        def transaction_id
          return nil if @grpc.nil?
          @grpc.id
        end

        ##
        # The read timestamp chosen for snapshots.
        # @return [Time] The chosen timestamp.
        def timestamp
          return nil if @grpc.nil?
          Convert.timestamp_to_time @grpc.read_timestamp
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
        # @return [Google::Cloud::Spanner::Results] The results of the query
        #   execution.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.snapshot do |snp|
        #     results = snp.execute "SELECT * FROM users"
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
        #   db.snapshot do |snp|
        #     results = snp.execute "SELECT * FROM users " \
        #                           "WHERE active = @active",
        #                           params: { active: true }
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
        #   db.snapshot do |snp|
        #      user_hash = { id: 1, name: "Charlie", active: false }
        #
        #     results = snp.execute "SELECT * FROM users WHERE " \
        #                           "ID = @user_struct.id " \
        #                           "AND name = @user_struct.name " \
        #                           "AND active = @user_struct.active",
        #                           params: { user_struct: user_hash }
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
        #   db.snapshot do |snp|
        #      user_type = snp.fields id: :INT64, name: :STRING, active: :BOOL
        #      user_hash = { id: 1, name: nil, active: false }
        #
        #     results = snp.execute "SELECT * FROM users WHERE " \
        #                           "ID = @user_struct.id " \
        #                           "AND name = @user_struct.name " \
        #                           "AND active = @user_struct.active",
        #                           params: { user_struct: user_hash },
        #                           types: { user_struct: user_type }
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
        #   db.snapshot do |snp|
        #      user_type = snp.fields id: :INT64, name: :STRING, active: :BOOL
        #   user_data = user_type.struct id: 1, name: nil, active: false
        #
        #     results = snp.execute "SELECT * FROM users WHERE " \
        #                           "ID = @user_struct.id " \
        #                           "AND name = @user_struct.name " \
        #                           "AND active = @user_struct.active",
        #                           params: { user_struct: user_data }
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def execute sql, params: nil, types: nil
          ensure_session!

          params, types = Convert.to_input_params_and_types params, types

          session.execute sql, params: params, types: types,
                               transaction: tx_selector
        end
        alias query execute

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
        #   db.snapshot do |snp|
        #     results = snp.read "users", [:id, :name]
        #
        #     results.rows.each do |row|
        #       puts "User #{row[:id]} is #{row[:name]}"
        #     end
        #   end
        #
        def read table, columns, keys: nil, index: nil, limit: nil
          ensure_session!

          columns = Array(columns).map(&:to_s)
          keys = Convert.to_key_set keys

          session.read table, columns, keys: keys, index: index, limit: limit,
                                       transaction: tx_selector
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
        # See [Data Types - Constructing a
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
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.snapshot do |snp|
        #     named_type = snp.fields(
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
        #   db.snapshot do |snp|
        #     anon_type = snp.fields [:INT64, :STRING, :BOOL]
        #     anon_data = anon_type.struct [42, nil, false]
        #   end
        #
        # @example Create a STRUCT value with duplicate field names:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   db = spanner.client "my-instance", "my-database"
        #
        #   db.snapshot do |snp|
        #     dup_type = snp.fields [[:x, :INT64], [:x, :STRING], [:x, :BOOL]]
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
        #   db.snapshot do |snp|
        #     key_range = db.range 1, 100
        #     results = snp.read "users", [:id, :name], keys: key_range
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
        # @private Creates a new Snapshot instance from a
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
          raise "Must have active connection to service" unless session
        end
      end
    end
  end
end
