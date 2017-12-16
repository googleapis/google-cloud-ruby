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

require "helper"

describe Google::Cloud::Spanner::Client, :close, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0, max: 4 } }
  let(:pool) { client.instance_variable_get :@pool }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }

  before do
    session.instance_variable_set :@last_updated_at, Time.now
    p = client.instance_variable_get :@pool
    p.all_sessions = [session]
    p.session_queue = [session]
  end

  it "deletes sessions when closed" do
    mock = Minitest::Mock.new
    mock.expect :delete_session, nil, [session_grpc.name, options: default_options]
    session.service.mocked_service = mock

    client.close

    shutdown_pool! pool

    mock.verify
  end

  it "cannot be used after being closed" do
    mock = Minitest::Mock.new
    mock.expect :delete_session, nil, [session_grpc.name, options: default_options]
    session.service.mocked_service = mock

    client.close

    assert_raises Google::Cloud::Spanner::ClientClosedError do
      client.execute "SELECT 1"
    end

    shutdown_pool! pool

    mock.verify
  end
end
