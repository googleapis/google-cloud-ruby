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


require "google/cloud/errors"

module Google
  module Cloud
    module Spanner
      ##
      # # Rollback
      #
      # Used to rollback a transaction without passing on the exception. See
      # {Client#transaction}.
      #
      # @example
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
      class Rollback < Google::Cloud::Error
      end

      ##
      # # DuplicateNameError
      #
      # Data accessed by name (typically by calling
      # {Google::Cloud::Spanner::Data#[]} with a key or calling
      # {Google::Cloud::Spanner::Data#to_h}) has more than one occurrence of the
      # same name. Such data should be accessed by position rather than by name.
      #
      class DuplicateNameError < Google::Cloud::Error
      end

      ##
      # # SessionLimitError
      #
      # More sessions have been allocated than configured for.
      class SessionLimitError < Google::Cloud::Error
      end

      ##
      # # ClientClosedError
      #
      # The client is closed and can no longer be used.
      class ClientClosedError < Google::Cloud::Error
      end

      ##
      # # BatchUpdateError
      #
      # Includes the cause and the partial result set of row counts from a
      # failed batch DML operation. Contains a cause error that provides service
      # error type and message, and a list with the exact number of rows that
      # were modified for each successful statement before the error.
      #
      # See {Google::Cloud::Spanner::Transaction#batch_update}.
      #
      # @attr_reader [Array<Integer>] row_counts A list with the exact number of
      #   rows that were modified for each successful statement.
      class BatchUpdateError < Google::Cloud::Error
        attr_reader :row_counts

        ##
        # @private New Status from a Google::Rpc::Status object.
        def self.from_grpc grpc
          row_counts = grpc.result_sets.map do |rs|
            rs.stats.row_count_exact
          end
          new.tap do |result|
            result.instance_variable_set :@row_counts, row_counts
          end
        end
      end
    end
  end
end
