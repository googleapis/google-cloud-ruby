# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Project, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) {
    Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id)
  }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:batch_create_sessions_grpc) {
    Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new session: [session_grpc]
  }

  it "knows the project identifier" do
    _(spanner).must_be_kind_of Google::Cloud::Spanner::Project
    _(spanner.project_id).must_equal project
  end

  it "creates client with database role" do
    mock = Minitest::Mock.new
    request_session = Google::Cloud::Spanner::V1::Session.new labels: nil, creator_role: "test_role"
    mock.expect :batch_create_sessions, batch_create_sessions_grpc, [Hash,::Gapic::CallOptions]
    spanner.service.mocked_service = mock

    client = spanner.client instance_id, database_id, pool: { min: 1, max: 1 }, database_role: "test-role"
    _(client.database_role).must_equal "test-role"
  end
end
