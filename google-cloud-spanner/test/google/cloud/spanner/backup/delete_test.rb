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

describe Google::Cloud::Spanner::Backup, :delete, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:backup_grpc) {
    Google::Cloud::Spanner::Admin::Database::V1::Backup.new(
      backup_hash(instance_id: instance_id, database_id: database_id, backup_id: backup_id)
    )
  }
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_backup, nil, [name: backup_grpc.name]
    spanner.service.mocked_databases = mock

    _(backup.delete).must_equal true
    mock.verify
  end
end
