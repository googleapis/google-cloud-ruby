# Copyright 2017 Google LLC
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

describe Google::Cloud::Spanner::Client, :admin, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:default_options) { Google::Gax::CallOptions.new kwargs: { "google-cloud-resource-prefix" => database_path(instance_id, database_id) } }
  let(:client) { spanner.client instance_id, database_id, pool: { min: 0 } }

  after do
    shutdown_client! client
  end

  it "knows its project_id" do
    client.project_id.must_equal project
  end

  it "holds a reference to project" do
    client.project.must_equal spanner
  end

  it "knows its instance_id" do
    client.instance_id.must_equal instance_id
  end

  it "retrieves the instance" do
    get_res = Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_hash(name: instance_id).to_json
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [instance_path(instance_id)]
    spanner.service.mocked_instances = mock

    instance = spanner.instance instance_id

    mock.verify

    instance.project_id.must_equal project
    instance.instance_id.must_equal instance_id
    instance.path.must_equal instance_path(instance_id)
  end

  it "knows its database_id" do
    client.database_id.must_equal database_id
  end

  it "retrieves the database" do
    get_res = Google::Spanner::Admin::Database::V1::Database.decode_json database_hash(instance_id: instance_id, database_id: database_id).to_json
    mock = Minitest::Mock.new
    mock.expect :get_database, get_res, [database_path(instance_id, database_id)]
    spanner.service.mocked_databases = mock

    database = client.database

    mock.verify

    database.project_id.must_equal project
    database.instance_id.must_equal instance_id
    database.database_id.must_equal database_id
    database.path.must_equal database_path(instance_id, database_id)
  end
end
