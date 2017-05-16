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

describe Google::Cloud::Spanner::Pool, :keepalive, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:pool) do
    p = client.instance_variable_get :@pool
    p.all_sessions = [session]
    p.session_queue = [session]
    p
  end
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

  it "calls keepalive on all sessions" do
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    pool.keepalive!

    mock.verify
  end

  it "calls keepalive on all sessions and sleeps" do
    skip "This keeps failing on CI. Not sure why..."
    mock = Minitest::Mock.new
    mock.expect :execute_streaming_sql, results_enum, [session.path, "SELECT 1", transaction: nil, params: nil, param_types: nil, resume_token: nil, options: default_options]
    session.service.mocked_service = mock

    # stub out the sleep method so the test doesn't actually block
    mock.expect :sleep, nil, [1500]
    pool.define_singleton_method :sleep do |count|
      # call the mock to satisfy the expectation
      mock.sleep count
    end

    pool.keepalive_and_sleep!

    mock.verify
  end
end
