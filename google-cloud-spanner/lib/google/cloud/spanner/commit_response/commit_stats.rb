# Copyright 2020 Google LLC
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

module Google
  module Cloud
    module Spanner
      class CommitResponse
        ##
        # # CommitStats
        #
        # Statistical information of a transaction commit.
        #
        class CommitStats
          ##
          # @private Creates a new CommitStats instance.
          def initialize grpc
            @grpc = grpc
          end

          # The total number of the mutations for the transaction.
          # @return [Integer]
          def mutation_count
            @grpc.mutation_count
          end

          # Length of time in seconds the commit was delayed due to
          # overloaded servers.
          # @return [Integer]
          def overload_delay
            Convert.duration_to_number @grpc.overload_delay
          end

          ##
          # @private
          # Creates a new Commit stats instance from a
          # `Google::Cloud::Spanner::V1::CommitResponse::CommitStats`.
          def self.from_grpc grpc
            new grpc
          end
        end
      end
    end
  end
end
