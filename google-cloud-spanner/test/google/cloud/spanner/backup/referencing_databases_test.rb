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

describe Google::Cloud::Spanner::Backup, :referencing_databases, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:referencing_database_id) { "referencing-db1" }
  let(:backup_grpc) {
    Google::Cloud::Spanner::Admin::Database::V1::Backup.new \
      backup_hash(
        instance_id: instance_id,
        database_id: database_id,
        backup_id: backup_id,
        referencing_databases: [referencing_database_id]
      )
  }
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "get referencing databases" do
    get_res = Google::Cloud::Spanner::Admin::Database::V1::Database.new database_hash(instance_id: instance_id, database_id: referencing_database_id)
    mock = Minitest::Mock.new
    mock.expect :get_database, get_res, [name: database_path(instance_id, referencing_database_id)]
    spanner.service.mocked_databases = mock

    referencing_databases = backup.referencing_databases
    mock.verify

    _(referencing_databases).must_be_kind_of Array
    _(referencing_databases.length).must_equal 1

    referencing_database = referencing_databases[0]
    _(referencing_database.instance_id).must_equal instance_id
    _(referencing_database.database_id).must_equal referencing_database_id
  end
end
