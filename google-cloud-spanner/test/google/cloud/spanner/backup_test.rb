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

describe Google::Cloud::Spanner::Backup, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:backup_grpc) {
    Google::Spanner::Admin::Database::V1::Backup.new(
      backup_hash(
        instance_id: instance_id,
        database_id: database_id,
        backup_id: backup_id,
        expire_time: Time.now + 36000,
        create_time: Time.now,
        size_bytes: 1024
      )
    )
  }
  let(:backup) { Google::Cloud::Spanner::Backup.from_grpc backup_grpc, spanner.service }

  it "knows the identifiers" do
    backup.must_be_kind_of Google::Cloud::Spanner::Backup
    backup.project_id.must_equal project
    backup.instance_id.must_equal instance_id
    backup.database_id.must_equal database_id
    backup.backup_id.must_equal backup_id

    backup.state.must_equal :READY
    backup.must_be :ready?
    backup.wont_be :creating?

    backup.expire_time.must_be_kind_of Time
    backup.create_time.must_be_kind_of Time
    backup.size_in_bytes.must_be :>, 0
  end
end
