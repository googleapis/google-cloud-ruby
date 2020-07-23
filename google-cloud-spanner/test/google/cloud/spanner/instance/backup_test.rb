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

describe Google::Cloud::Spanner::Instance, :backup, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }

  it "gets a database backup" do
    backup_id = "found-backup"

    get_res = Google::Cloud::Spanner::Admin::Database::V1::Backup.new \
      backup_hash(instance_id: instance_id, database_id: database_id, backup_id: backup_id)
    mock = Minitest::Mock.new
    mock.expect :get_backup, get_res, [name: backup_path(instance_id, backup_id)]
    instance.service.mocked_databases = mock

    backup = instance.backup backup_id

    mock.verify

    _(backup.project_id).must_equal project
    _(backup.instance_id).must_equal instance_id
    _(backup.database_id).must_equal database_id
    _(backup.backup_id).must_equal backup_id

    _(backup.path).must_equal backup_path(instance_id, backup_id)

    _(backup.state).must_equal :READY
    _(backup).must_be :ready?
    _(backup).wont_be :creating?
  end

  it "returns nil when getting a non-existent backup" do
    not_found_backup_id = "not-found-backup"

    stub = Object.new
    def stub.get_backup *args
      gax_error = Google::Cloud::NotFoundError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end
    instance.service.mocked_databases = stub

    backup = instance.backup not_found_backup_id
    _(backup).must_be :nil?
  end
end
