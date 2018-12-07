# Copyright 2019 Google LLC
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


require "google/cloud/spanner/status"

module Google
  module Cloud
    module Spanner
      ##
      # # BatchUpdateResults
      #
      # Represents the result set from a batch DML operation. Contains a status
      # object that provides an error message if an error occurred, and a list
      # with the exact number of rows that were modified for each successful
      # statement.
      #
      # See {Google::Cloud::Spanner::Transaction#batch_update}.
      #
      # @attr_reader [Array<Integer>] row_counts A list with the exact number of
      #   rows that were modified for each successful statement.
      # @attr_reader [Google::Cloud::Spanner::Status] A status object with the
      #   status code, and the error message if an error occurred.
      #
      class BatchUpdateResults
        attr_reader :row_counts, :status

        ##
        # Checks if the status indicates that error occurred. Use {#status} to
        # access the status object.
        #
        # @return [Boolean] `true` when there is an error, `false` otherwise.
        #
        def failed?
          status.code != 0
        end

        ##
        # @private New Status from a Google::Rpc::Status object.
        def self.from_grpc grpc
          row_counts = grpc.result_sets.map do |rs|
            rs.stats.row_count_exact
          end
          new.tap do |result|
            result.instance_variable_set :@row_counts, row_counts
            result.instance_variable_set :@status,
                                         Status.from_grpc(grpc.status)
          end
        end
      end
    end
  end
end
