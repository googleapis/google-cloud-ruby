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

describe Google::Cloud::Spanner::Client, :threads, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }

  it "creates a thread pool with the number of threads specified" do
    mock = Minitest::Mock.new
    # mock.expect :delete_session, nil, [session_grpc.name, options: default_options]
    session.service.mocked_service = mock

    client = spanner.client instance_id, database_id, pool: { min: 0, max: 4, threads: 13 }
    pool = client.instance_variable_get :@pool
    threads = pool.instance_variable_get :@threads
    thread_pool = pool.instance_variable_get :@thread_pool

    threads.must_equal 13
    thread_pool.max_length.must_equal 13

    client.close

    shutdown_client! client

    mock.verify
  end
end
