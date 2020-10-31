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


require "google/cloud/spanner/commit_response/commit_stats"

module Google
  module Cloud
    module Spanner
      ##
      # CommitResponse is a timestamp at which the transaction committed
      # with additional attributes of commit stats.
      #
      # @example
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   timestamp = db.commit do |c|
      #     c.update "users", [{ id: 1, name: "Charlie", active: false }]
      #     c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      #   end
      #
      #   puts timestamp
      #
      # @example With commit stats.
      #   require "google/cloud/spanner"
      #
      #   spanner = Google::Cloud::Spanner.new
      #
      #   db = spanner.client "my-instance", "my-database"
      #
      #   commit_options = { return_commit_stats: true }
      #   commit_resp = db.commit commit_options: commit_options do |c|
      #     c.update "users", [{ id: 1, name: "Charlie", active: false }]
      #     c.insert "users", [{ id: 2, name: "Harvey",  active: true }]
      #   end
      #
      #   puts commit_resp.timestamp
      #   puts commit_resp.stats.mutation_count
      #   puts commit_resp.stats.overload_delay
      #
      class CommitResponse
        ##
        # @private Creates a new CommitResponse instance.
        def initialize grpc
          @grpc = grpc
        end

        ##
        # The timestamp at which the transaction committed.
        # @return [Time]
        def timestamp
          Convert.timestamp_to_time @grpc.commit_timestamp
        end

        ##
        # Additional statistics about a commit.
        # @return [CommitStats, nil] Commit stats or nil if not stats not
        #   present.
        def stats
          CommitStats.from_grpc @grpc.commit_stats if @grpc.commit_stats
        end

        ##
        # @private
        # Creates a new Commit responsee instance from a
        # `Google::Cloud::Spanner::V1::CommitResponse`.
        def self.from_grpc grpc
          new grpc
        end
      end
    end
  end
end
