# Copyright 2018 Google LLC
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
require "google/cloud/spanner/session"
require "google/cloud/spanner/partition"
require "google/cloud/spanner/results"
require "json"
require "base64"

module Google
  module Cloud
    module Spanner
      ##
      # # BatchSnapshot
      #
      # Represents a read-only transaction that can be configured to read at
      # timestamps in the past and allows for exporting arbitrarily large
      # amounts of data from Cloud Spanner databases. This is a snapshot which
      # additionally allows to partition a read or query request. The read/query
      # request can then be executed independently over each partition while
      # observing the same snapshot of the database. A BatchSnapshot can also be
      # shared across multiple processes/machines by passing around its
      # serialized value and then recreating the transaction using
      # {BatchClient#dump}.
      #
      # Unlike locking read-write transactions, BatchSnapshot will never abort.
      # They can fail if the chosen read timestamp is garbage collected; however
      # any read or query activity within an hour on the transaction avoids
      # garbage collection and most applications do not need to worry about this
      # in practice.
      #
      # See {BatchClient#batch_snapshot} and {BatchClient#load_batch_snapshot}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   batch_client = spanner.batch_client "my-instance", "my-database"
      #   batch_snapshot = batch_client.batch_snapshot
      #
      #   partitions = batch_snapshot.partition_read "users", [:id, :name]
      #
      #   partition = partitions.first
      #   results = batch_snapshot.execute_partition partition
      #
      #   batch_snapshot.close
      #
      class BatchSnapshot
        # @private The transaction grpc object.
        attr_reader :grpc

        # @private The Session object.
        attr_reader :session

        ##
        # @private Creates a BatchSnapshot object.
        def initialize grpc, session
          @grpc = grpc
          @session = session
        end

        ##
        # Identifier of the batch snapshot transaction.
        # @return [String] The transaction id.
        def transaction_id
          return nil if grpc.nil?
          grpc.id
        end

        ##
        # The read timestamp chosen for batch snapshot.
        # @return [Time] The chosen timestamp.
        def timestamp
          return nil if grpc.nil?
          Convert.timestamp_to_time grpc.read_timestamp
        end

        ##
        # Returns a list of {Partition} objects to execute a batch query against
        # a database.
        #
        # These partitions can be executed across multiple processes, even
        # across different machines. The partition size and count can be
        # configured, although the values given may not necessarily be honored
        # depending on the query and options in the request.
        #
        # The query must have a single [distributed
        # union](https://cloud.google.com/spanner/docs/query-execution-operators#distributed_union)
        # operator at the root of the query plan. Such queries are
        # root-partitionable. If a query cannot be partitioned at the root,
        # Cloud Spanner cannot achieve the parallelism and in this case
        # partition generation will fail.
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
        # @param [Integer] partition_size_bytes The desired data size for each
        #   partition generated. This is only a hint. The actual size of each
        #   partition may be smaller or larger than this size request.
        # @param [Integer] max_partitions The desired maximum number of
        #   partitions to return. For example, this may be set to the number of
        #   workers available. This is only a hint and may provide different
        #   results based on the request.
        #
        # @return [Array<Google::Cloud::Spanner::Partition>] The partitions
        #   created by the query partition.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   sql = "SELECT u.id, u.active FROM users AS u \
        #          WHERE u.id < 2000 AND u.active = false"
        #   partitions = batch_snapshot.partition_query sql
        #
        #   partition = partitions.first
        #   results = batch_snapshot.execute_partition partition
        #
        #   batch_snapshot.close
        #
        def partition_query sql, params: nil, types: nil,
                            partition_size_bytes: nil, max_partitions: nil
          ensure_session!

          params, types = Convert.to_input_params_and_types params, types

          results = session.partition_query \
            sql, tx_selector, params: params, types: types,
                              partition_size_bytes: partition_size_bytes,
                              max_partitions: max_partitions

          results.partitions.map do |grpc|
            # Convert partition protos to execute sql request protos
            execute_grpc = Google::Spanner::V1::ExecuteSqlRequest.new(
              {
                session: session.path,
                sql: sql,
                params: params,
                param_types: types,
                transaction: tx_selector,
                partition_token: grpc.partition_token
              }.delete_if { |_, v| v.nil? }
            )
            Partition.from_execute_grpc execute_grpc
          end
        end

        ##
        # Returns a list of {Partition} objects to read zero or more rows from a
        # database.
        #
        # These partitions can be executed across multiple processes, even
        # across different machines. The partition size and count can be
        # configured, although the values given may not necessarily be honored
        # depending on the query and options in the request.
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
        # @param [Integer] partition_size_bytes The desired data size for each
        #   partition generated. This is only a hint. The actual size of each
        #   partition may be smaller or larger than this size request.
        # @param [Integer] max_partitions The desired maximum number of
        #   partitions to return. For example, this may be set to the number of
        #   workers available. This is only a hint and may provide different
        #   results based on the request.
        #
        # @return [Array<Google::Cloud::Spanner::Partition>] The partitions
        #   created by the read partition.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #   results = batch_snapshot.execute_partition partition
        #
        #   batch_snapshot.close
        #
        def partition_read table, columns, keys: nil, index: nil,
                           partition_size_bytes: nil, max_partitions: nil
          ensure_session!

          columns = Array(columns).map(&:to_s)
          keys = Convert.to_key_set keys

          results = session.partition_read \
            table, columns, tx_selector,
            keys: keys, index: index,
            partition_size_bytes: partition_size_bytes,
            max_partitions: max_partitions

          results.partitions.map do |grpc|
            # Convert partition protos to read request protos
            read_grpc = Google::Spanner::V1::ReadRequest.new(
              {
                session: session.path,
                table: table,
                columns: columns,
                key_set: keys,
                index: index,
                transaction: tx_selector,
                partition_token: grpc.partition_token
              }.delete_if { |_, v| v.nil? }
            )
            Partition.from_read_grpc read_grpc
          end
        end

        ##
        # Execute the partition to return a {ResultSet}. The result returned
        # could be zero or more rows. The row metadata may be absent if no rows
        # are returned.
        #
        # @param [Google::Cloud::Spanner::Partition] partition The partition to
        #   be executed.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #   results = batch_snapshot.execute_partition partition
        #
        #   batch_snapshot.close
        #
        def execute_partition partition
          ensure_session!

          partition = Partition.load partition unless partition.is_a? Partition
          # TODO: raise if partition.empty?

          # TODO: raise if session.path != partition.session
          # TODO: raise if grpc.transaction != partition.transaction

          if partition.execute?
            execute_partition_query partition
          elsif partition.read?
            execute_partition_read partition
          end
        end

        ##
        # Closes the batch snapshot and releases the underlying resources.
        #
        # This should only be called once the batch snapshot is no longer needed
        # anywhere. In particular if this batch snapshot is being used across
        # multiple machines, calling this method on any of the machines will
        # render the batch snapshot invalid everywhere.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #   results = batch_snapshot.execute_partition partition
        #
        #   batch_snapshot.close
        #
        def close
          ensure_session!

          session.release!
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
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   results = batch_snapshot.execute "SELECT * FROM users"
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query using query parameters:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   results = batch_snapshot.execute "SELECT * FROM users " \
        #                                    "WHERE active = @active",
        #                                    params: { active: true }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Query with a SQL STRUCT query parameter as a Hash:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   user_hash = { id: 1, name: "Charlie", active: false }
        #
        #   results = batch_snapshot.execute "SELECT * FROM users WHERE " \
        #                                    "ID = @user_struct.id " \
        #                                    "AND name = @user_struct.name " \
        #                                    "AND active = @user_struct.active",
        #                                    params: { user_struct: user_hash }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Specify the SQL STRUCT type using Fields object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   user_type = batch_client.fields(
        #     { id: :INT64, name: :STRING, active: :BOOL }
        #   )
        #   user_hash = { id: 1, name: nil, active: false }
        #
        #   results = batch_snapshot.execute "SELECT * FROM users WHERE " \
        #                                    "ID = @user_struct.id " \
        #                                    "AND name = @user_struct.name " \
        #                                    "AND active = @user_struct.active",
        #                                    params: { user_struct: user_hash },
        #                                    types: { user_struct: user_type }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        # @example Or, query with a SQL STRUCT as a typed Data object:
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   user_type = batch_client.fields(
        #     { id: :INT64, name: :STRING, active: :BOOL }
        #   )
        #   user_data = user_type.struct id: 1, name: nil, active: false
        #
        #   results = batch_snapshot.execute "SELECT * FROM users WHERE " \
        #                                    "ID = @user_struct.id " \
        #                                    "AND name = @user_struct.name " \
        #                                    "AND active = @user_struct.active",
        #                                    params: { user_struct: user_data }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
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
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   results = batch_snapshot.read "users", [:id, :name]
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
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
        # @private
        # Converts the the batch snapshot object to a Hash ready for
        # serialization.
        #
        # @return [Hash] A hash containing a representation of the batch
        #   snapshot object.
        #
        def to_h
          {
            session: Base64.strict_encode64(@session.grpc.to_proto),
            transaction: Base64.strict_encode64(@grpc.to_proto)
          }
        end

        ##
        # Serializes the batch snapshot object so it can be recreated on another
        # process. See {BatchClient#load_batch_snapshot}.
        #
        # @return [String] The serialized representation of the batch snapshot.
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   batch_snapshot = batch_client.batch_snapshot
        #
        #   partitions = batch_snapshot.partition_read "users", [:id, :name]
        #
        #   partition = partitions.first
        #
        #   serialized_snapshot = batch_snapshot.dump
        #   serialized_partition = partition.dump
        #
        #   # In a separate process
        #   new_batch_snapshot = batch_client.load_batch_snapshot \
        #     serialized_snapshot
        #
        #   new_partition = batch_client.load_partition \
        #     serialized_partition
        #
        #   results = new_batch_snapshot.execute_partition \
        #     new_partition
        #
        def dump
          JSON.dump to_h
        end
        alias serialize dump

        ##
        # @private Loads the serialized batch snapshot. See
        # {BatchClient#load_batch_snapshot}.
        def self.load data, service: nil
          data = JSON.parse data, symbolize_names: true unless data.is_a? Hash

          session_grpc = Google::Spanner::V1::Session.decode \
            Base64.decode64(data[:session])
          transaction_grpc = Google::Spanner::V1::Transaction.decode \
            Base64.decode64(data[:transaction])

          from_grpc transaction_grpc, Session.from_grpc(session_grpc, service)
        end

        ##
        # @private Creates a new BatchSnapshot instance from a
        # Google::Spanner::V1::Transaction.
        def self.from_grpc grpc, session
          new grpc, session
        end

        protected

        # The TransactionSelector to be used for queries
        def tx_selector
          Google::Spanner::V1::TransactionSelector.new id: transaction_id
        end

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_session!
          raise "Must have active connection to service" unless session
        end

        def execute_partition_query partition
          session.execute partition.execute.sql,
                          params: partition.execute.params,
                          types: partition.execute.param_types.to_h,
                          transaction: partition.execute.transaction,
                          partition_token: partition.execute.partition_token
        end

        def execute_partition_read partition
          session.read partition.read.table,
                       partition.read.columns.to_a,
                       keys: partition.read.key_set,
                       index: partition.read.index,
                       transaction: partition.read.transaction,
                       partition_token: partition.read.partition_token
        end
      end
    end
  end
end
