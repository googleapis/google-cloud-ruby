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

describe Google::Cloud::Spanner::Instance, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:backup_id) { "my-backup-id" }
  let(:source_database_id) { "my-backup-source-database-id" }
  let(:restore_info) do
    restore_info_hash source_type: 'BACKUP', backup_info: backup_info_hash(
      instance_id: instance_id,
      backup_id: backup_id,
      create_time: Time.now,
      source_database_id: source_database_id
    )
  end
  let(:database_grpc) do
    Google::Spanner::Admin::Database::V1::Database.new \
      database_hash(instance_id: instance_id, database_id: database_id, restore_info: restore_info)
  end
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }

  it "knows the identifiers" do
    database.must_be_kind_of Google::Cloud::Spanner::Database
    database.project_id.must_equal project
    database.instance_id.must_equal instance_id
    database.database_id.must_equal database_id

    database.state.must_equal :READY
    database.must_be :ready?
    database.wont_be :creating?

    restore_info = database.restore_info
    restore_info.must_be_kind_of Google::Cloud::Spanner::Database::RestoreInfo
    restore_info.source_type.must_equal :BACKUP
    restore_info.must_be :source_backup?

    backup_info = restore_info.backup_info
    backup_info.must_be_kind_of Google::Cloud::Spanner::Database::BackupInfo
    backup_info.project_id.must_equal project
    backup_info.instance_id.must_equal instance_id
    backup_info.backup_id.must_equal backup_id
    backup_info.source_database_project_id.must_equal project
    backup_info.source_database_instance_id.must_equal instance_id
    backup_info.source_database_id.must_equal source_database_id
    backup_info.create_time.must_be_kind_of Time
  end
end
