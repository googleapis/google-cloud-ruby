# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Pool, :ensure_valid!, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:pool) { client.instance_variable_get :@pool }
  let :results_hash do
    {
      metadata: {
        rowType: {
          fields: [
            { type: { code: "INT64" } }
          ]
        }
      },
      values: [
        { stringValue: "1" }
      ]
    }
  end
  let(:results_json) { results_hash.to_json }
  let(:results_grpc) { Google::Spanner::V1::PartialResultSet.decode_json results_json }
  let(:results_enum) { Array(results_grpc).to_enum }

  after do
    # Close the client and release the keepalive thread
    client.instance_variable_get(:@pool).all_sessions = []
    client.close
  end

  it "calls keepalive on the sessions that need it" do
    # update the session so it was last updated an hour ago
    session.instance_variable_set :@last_updated_at, Time.now - 60*60
    sleep 0.25 # sleep enough that the thread ensure_valid finishes
    # set the session in the pool
    pool.all_sessions = [session]
    pool.session_queue = [session]

    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    pool.send :ensure_valid!

    mock.verify
  end

  it "doesn't calls keepalive on sessions that don't need it" do
    # update the session so it was last updated now
    session.instance_variable_set :@last_updated_at, Time.now
    sleep 0.25 # sleep enough that the thread ensure_valid finishes
    # set the session in the pool
    pool.all_sessions = [session]
    pool.session_queue = [session]

    mock = Minitest::Mock.new
    session.service.mocked_service = mock

    pool.send :ensure_valid!

    mock.verify
  end
end
