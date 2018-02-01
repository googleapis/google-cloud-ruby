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


require "google/cloud/spanner/errors"
require "google/cloud/spanner/project"
require "google/cloud/spanner/session"
require "google/cloud/spanner/batch_read_only_transaction"

module Google
  module Cloud
    module Spanner
      ##
      # # BatchClient
      #
      # Provides a batch client that can be used to read data from a Cloud
      # Spanner database. An instance of this class is tied to a specific
      # database.
      #
      # BatchClient is useful when one wants to read or query a large amount of
      # data from Cloud Spanner across multiple processes, even across different
      # machines. It allows to create partitions of Cloud Spanner database and
      # then read or query over each partition independently yet at the same
      # snapshot.
      #
      # See {Google::Cloud::Spanner::Project#batch_client}.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   batch_client = spanner.batch_client "my-instance", "my-database"
      #
      #   transaction = batch_client.create_batch_read_only_transaction
      #   batch_transaction_id = transaction.batch_transaction_id
      #
      #   # In a separate process
      #   new_transaction = batch_client.batch_read_only_transaction \
      #     batch_transaction_id
      #
      class BatchClient
        ##
        # @private Creates a new Spanner BatchClient instance.
        def initialize project, instance_id, database_id
          @project = project
          @instance_id = instance_id
          @database_id = database_id
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
        # Returns a {BatchReadOnlyTransaction} context in which multiple reads
        # and/or queries can be performed. All reads/queries will use the same
        # timestamp, and the timestamp can be inspected after this transaction
        # is created successfully. This is a blocking method since it waits to
        # finish the RPCs.
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
        # @return [Google::Cloud::Spanner::BatchReadOnlyTransaction]
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   transaction = batch_client.create_batch_read_only_transaction
        #   batch_transaction_id = transaction.batch_transaction_id
        #
        #   # In a separate process
        #   new_transaction = batch_client.batch_read_only_transaction \
        #     batch_transaction_id
        #
        #
        def create_batch_read_only_transaction strong: nil, timestamp: nil,
                                               read_timestamp: nil,
                                               staleness: nil,
                                               exact_staleness: nil
          # TODO: Verify that all args are appropriate here.
          validate_snapshot_args! strong: strong, timestamp: timestamp,
                                  read_timestamp: read_timestamp,
                                  staleness: staleness,
                                  exact_staleness: exact_staleness

          ensure_service!
          snp_session = session
          snp_grpc = @project.service.create_snapshot \
            snp_session.path, strong: strong,
                              timestamp: (timestamp || read_timestamp),
                              staleness: (staleness || exact_staleness)
          BatchReadOnlyTransaction.from_grpc snp_grpc, snp_session
        end

        ##
        # Returns a {BatchReadOnlyTransaction} context in which multiple reads
        # and/or queries can be performed. All reads/queries will use the same
        # timestamp, and the timestamp can be inspected after this transaction
        # is created successfully.
        #
        # @param [Google::Cloud::Spanner::BatchTransactionId]
        #   batch_transaction_id The unique ID of an existing transaction.
        #   See {BatchReadOnlyTransaction#batch_transaction_id}.
        #
        # @return [Google::Cloud::Spanner::BatchReadOnlyTransaction]
        #
        # @example
        #   require "google/cloud/spanner"
        #
        #   spanner = Google::Cloud::Spanner.new
        #
        #   batch_client = spanner.batch_client "my-instance", "my-database"
        #
        #   transaction = batch_client.create_batch_read_only_transaction
        #   batch_transaction_id = transaction.batch_transaction_id
        #
        #   # In a separate process
        #   new_transaction = batch_client.batch_read_only_transaction \
        #     batch_transaction_id
        #
        #
        def batch_read_only_transaction batch_transaction_id
          ensure_service!
          grpc = @project.service.get_session batch_transaction_id.session_path
          tx_session = Session.from_grpc grpc, @project.service
          BatchReadOnlyTransaction.new \
            tx_session, batch_transaction_id.transaction_id,
            batch_transaction_id.timestamp
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
        # New session for each use.
        def session
          ensure_service!
          grpc = @project.service.create_session \
            Admin::Database::V1::DatabaseAdminClient.database_path(
              project_id, instance_id, database_id
            )
          Session.from_grpc(grpc, @project.service)
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
      end
    end
  end
end
