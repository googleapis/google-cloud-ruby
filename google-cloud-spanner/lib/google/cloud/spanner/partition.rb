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


module Google
  module Cloud
    module Spanner
      ##
      # # Partition
      #
      # Defines the segments of data to be read in a batch read/query context. A
      # Partition instance can be serialized and used across several different
      # machines or processes.
      #
      # See {BatchSnapshot#partition_read}, {BatchSnapshot#partition_query}, and
      # {BatchSnapshot#execute_partition}.
      #
      # @attr [String] partition_token
      # @attr [String] table The name of the table in the database to be read or
      #   queried.
      # @attr [Object, Array<Object>, nil] keys A single, or list of keys or key
      #   ranges to match returned data to. Values should have exactly as many
      #   elements as there are columns in the primary key.
      # @attr [Array<String, Symbol>] columns The columns of table to be
      #   returned for each row.
      # @attr [String] index The name of an index to use instead of the table's
      #   primary key when interpreting `id` and sorting result rows. Optional.
      # @attr [String] sql The SQL query string. See [Query
      #   syntax](https://cloud.google.com/spanner/docs/query-syntax).
      #
      #   The SQL query string can contain parameter placeholders. A parameter
      #   placeholder consists of "@" followed by the parameter name.
      #   Parameter names consist of any combination of letters, numbers, and
      #   underscores.
      # @attr [Hash] params SQL parameters for the query string. The
      #   parameter placeholders, minus the "@", are the the hash keys, and
      #   the literal values are the hash values. If the query string contains
      #   something like "WHERE id > @msg_id", then the params must contain
      #   something like `:msg_id => 1`.
      # @attr [Hash] param_types Types of the SQL parameters in `params`. It is
      #   not always possible for Cloud Spanner to infer the right SQL type from
      #   a value in `params`. In these cases, the `types` hash can be used to
      #   specify the exact SQL type for some or all of the SQL query
      #   parameters.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   batch_client = spanner.batch_client "my-instance", "my-database"
      #
      #   batch_snapshot = batch_client.batch_snapshot
      #   partitions = batch_snapshot.partition_read "users", [:id, :name]
      #
      #   partition = partitions.first
      #
      #   results = batch_snapshot.execute_partition partition
      #
      class Partition
        attr_reader :partition_token, :table, :keys, :columns, :index,
                    :sql, :params, :param_types

        ##
        # @private Creates a Partition object.
        def initialize partition_token, table, keys, columns, index,
                       sql, params, param_types
          @partition_token = partition_token
          @table = table
          @keys = keys
          @columns = columns
          @index = index
          @sql = sql
          @params = params
          @param_types = param_types
        end

        ##
        # @private New Partition from a Google::Rpc::Partition object.
        def self.from_grpc grpc, table, keys, columns, index,
                           sql, params, param_types
          new grpc.partition_token, table, keys, columns, index,
              sql, params, param_types
        end
      end
    end
  end
end
