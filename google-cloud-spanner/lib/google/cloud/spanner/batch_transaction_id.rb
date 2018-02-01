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
      # # BatchTransactionId
      #
      # Represents a unique identifier for a {BatchReadOnlyTransaction}. It can
      # be used to re-initialize a BatchReadOnlyTransaction on a different
      # machine or process by calling {BatchClient#batch_read_only_transaction}.
      #
      # @attr [String] session_path The name of the session associated with the
      #   transaction. See {Session#path}.
      # @attr [String] transaction_id The identifier of the transaction.
      # @attr [Time, DateTime] timestamp The timestamp for the transaction. The
      #   transaction executes all reads at the timestamp. Reads at a specific
      #   timestamp are repeatable; the same read at the same timestamp always
      #   returns the same data. If the timestamp is in the future, the read
      #   will block until the specified timestamp, modulo the read's deadline.
      #   Useful for large scale consistent reads such as mapreduces, or for
      #   coordinating many reads against a consistent snapshot of the data.
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
      class BatchTransactionId
        attr_reader :session_path, :transaction_id, :timestamp

        ##
        # @private Creates a BatchTransactionId object.
        def initialize session_path, transaction_id, timestamp
          @session_path = session_path
          @transaction_id = transaction_id
          @timestamp = timestamp
        end
      end
    end
  end
end
