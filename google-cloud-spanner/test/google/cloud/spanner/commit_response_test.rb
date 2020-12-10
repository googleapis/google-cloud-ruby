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


require "helper"

describe Google::Cloud::Spanner::CommitResponse, :mock_spanner do
  let(:commit_stats_grpc) {
    Google::Cloud::Spanner::V1::CommitResponse::CommitStats.new(
      mutation_count: 5
    )
  }
  let(:commit_response_grpc) {
    Google::Cloud::Spanner::V1::CommitResponse.new(
      commit_timestamp: Time.now,
      commit_stats: commit_stats_grpc
    )
  }
  let(:commit_response) {
    Google::Cloud::Spanner::CommitResponse.from_grpc commit_response_grpc
  }

  it "knows the identifiers" do
    _(commit_response).must_be_kind_of Google::Cloud::Spanner::CommitResponse
    _(commit_response.timestamp).must_be_kind_of Time

    _(commit_response.stats).must_be_kind_of Google::Cloud::Spanner::CommitResponse::CommitStats
    _(commit_response.stats.mutation_count).must_equal 5
  end
end
