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

describe Google::Cloud::Spanner::Client, :close, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) {
    Google::Cloud::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id)
  }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) {
    { metadata: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  }
  let(:batch_create_sessions_grpc) {
    Google::Cloud::Spanner::V1::BatchCreateSessionsResponse.new session: [session_grpc]
  }
  let :results_hash do
    {
      metadata: {
        row_type: {
          fields: [
            { type: { code: :INT64 } }
          ]
        }
      },
      values: [
        { string_value: "1" }
      ]
    }
  end
  let(:results_grpc) { Google::Cloud::Spanner::V1::PartialResultSet.new results_hash }
  let(:results_enum) { Array(results_grpc).to_enum }

  it "reset client sessions and able to query database" do
    mock = Minitest::Mock.new
    mock.expect :batch_create_sessions, batch_create_sessions_grpc, [
      { database: database_path(instance_id, database_id), session_count: 1, session_template: nil },
      default_options
    ]
    mock.expect :delete_session, nil, [{ name: session_grpc.name }, default_options]
    mock.expect :batch_create_sessions, batch_create_sessions_grpc, [
      { database: database_path(instance_id, database_id), session_count: 1, session_template: nil },
      default_options
    ]
    spanner.service.mocked_service = mock
    expect_execute_streaming_sql results_enum, session.path, "SELECT 1", options: default_options

    client = spanner.client instance_id, database_id, pool: { min: 1, max: 1 }
    _(client.reset).must_equal true
    _(client.execute_query("SELECT 1").rows.first.values).must_equal [1]

    pool = client.instance_variable_get :@pool
    shutdown_pool! pool

    mock.verify
  end
end
