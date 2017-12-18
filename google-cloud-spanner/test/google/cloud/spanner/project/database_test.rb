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

describe Google::Cloud::Spanner::Project, :database, :mock_spanner do
  let(:instance_id) { "my-instance-id" }

  it "gets an database" do
    database_id = "found-database"

    get_res = Google::Spanner::Admin::Database::V1::Database.decode_json database_hash(instance_id: instance_id, database_id: database_id).to_json
    mock = Minitest::Mock.new
    mock.expect :get_database, get_res, [database_path(instance_id, database_id)]
    spanner.service.mocked_databases = mock

    database = spanner.database instance_id, database_id

    mock.verify

    database.project_id.must_equal project
    database.instance_id.must_equal instance_id
    database.database_id.must_equal database_id

    database.path.must_equal database_path(instance_id, database_id)

    database.state.must_equal :READY
    database.must_be :ready?
    database.wont_be :creating?
  end

  it "returns nil when getting an non-existent database" do
    not_found_database_id = "not-found-database"

    stub = Object.new
    def stub.get_database *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    spanner.service.mocked_databases = stub

    database = spanner.database instance_id, not_found_database_id
    database.must_be :nil?
  end
end
