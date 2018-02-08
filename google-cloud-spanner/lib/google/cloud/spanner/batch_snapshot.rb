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
require "google/cloud/spanner/batch_transaction_id"
require "google/cloud/spanner/partition"
require "google/cloud/spanner/results"

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
      # observing the same snapshot of the database. A BatchSnapshot
      # can also be shared across multiple processes/machines by passing around
      # its {BatchTransactionId} and then recreating the transaction using
      # {BatchClient#load_batch_snapshot}.
      #
      # Unlike locking read-write transactions, BatchSnapshot will
      # never abort. They can fail if the chosen read timestamp is garbage
      # collected; however any read or query activity within an hour on the
      # transaction avoids garbage collection and most applications do not need
      # to worry about this in practice.
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
        # @private The Service object.
        attr_accessor :service
        # @private The Session name.
        attr_reader :session_path

        # The transaction id string.
        attr_reader :transaction_id

        # The transaction timestamp.
        attr_reader :timestamp

        ##
        # Returns a serializable batch transaction ID object to be re-used
        # across several machines/processes. This ID guarantees the subsequent
        # read/query to be executed at the same timestamp.
        #
        # @return [Google::Cloud::Spanner::BatchTransactionId] The batch
        #   transaction ID object.
        #
        def batch_transaction_id
          BatchTransactionId.new session_path, transaction_id, timestamp
        end

        ##
        # @private Creates a BatchSnapshot object.
        def initialize service, session_path, transaction_id, timestamp
          @service = service
          raise "Must have session path." unless session_path
          @session_path = session_path
          @transaction_id = transaction_id
          @timestamp = timestamp
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
          partition_options = { keys: keys, index: index,
                                partition_size_bytes: partition_size_bytes,
                                max_partitions: max_partitions }
          ensure_service!
          results = service.partition_read session_path, table, columns,
                                           tx_selector, partition_options
          results.partitions.map do |p|
            Partition.from_grpc p, table, keys, columns, index, nil, nil, nil
          end
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
        # @param [Integer] partition_size_bytes The desired data size for each
        #   partition generated. This is only a hint. The actual size of each
        #   partition may be smaller or larger than this size request.
        # @param [Integer] max_partitions The desired maximum number of
        #   partitions to return. For example, this may be set to the number of
        #   workers available. This is only a hint and may provide different
        #   results based on the request.
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
          partition_options = { params: params, types: types,
                                partition_size_bytes: partition_size_bytes,
                                max_partitions: max_partitions }
          ensure_service!
          results = service.partition_query session_path, sql, tx_selector,
                                            partition_options

          results.partitions.map do |p|
            Partition.from_grpc p, nil, nil, nil, nil, sql, params, types
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
        #
        #   results = batch_snapshot.execute_partition partition
        #
        #   batch_snapshot.close
        #
        def execute_partition partition
          ensure_service!
          if partition.sql
            Results.execute service, session_path, partition.sql,
                            params: partition.params,
                            types: partition.param_types,
                            transaction: tx_selector,
                            partition_token: partition.partition_token

          else
            Results.read service, session_path, partition.table,
                         partition.columns,
                         keys: partition.keys,
                         index: partition.index,
                         transaction: tx_selector,
                         partition_token: partition.partition_token
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
          ensure_service!
          service.delete_session session_path
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
        #                         "WHERE active = @active",
        #                         params: { active: true }
        #
        #   results.rows.each do |row|
        #     puts "User #{row[:id]} is #{row[:name]}"
        #   end
        #
        def execute sql, params: nil, types: nil
          ensure_service!
          Results.execute service, session_path, sql,
                          params: params,
                          types: types,
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
          ensure_service!
          Results.read service, session_path, table, columns,
                       keys: keys,
                       index: index,
                       limit: limit,
                       transaction: tx_selector
        end

        ##
        # @private Creates a new BatchSnapshot instance from a
        # Google::Spanner::V1::Transaction.
        def self.from_grpc grpc, service, session_path
          timestamp = Convert.timestamp_to_time grpc.read_timestamp
          new service, session_path, grpc.id, timestamp
        end

        protected

        # The TransactionSelector to be used for queries
        def tx_selector
          Google::Spanner::V1::TransactionSelector.new id: transaction_id
        end

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
