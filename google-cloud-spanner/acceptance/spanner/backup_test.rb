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


require "spanner_helper"

describe "Spanner Database Backup", :spanner do
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { $spanner_database_id }
  let(:expire_time) { Time.now + 36000 }

  it "creates, get, updates, restore and delete a database backup" do
    backup_id = "#{$spanner_database_id}-crud"
    database = spanner.database instance_id, database_id
    database.wont_be :nil?

    # Create
    job = database.create_backup backup_id, expire_time

    job.must_be_kind_of Google::Cloud::Spanner::Backup::Job
    job.wont_be :done?
    job.wait_until_done!

    job.must_be :done?
    job.error.must_be :nil?

    backup = job.backup
    backup.wont_be :nil?
    backup.must_be_kind_of Google::Cloud::Spanner::Backup
    backup.backup_id.must_equal backup_id
    backup.database_id.must_equal database_id
    backup.instance_id.must_equal instance_id
    backup.project_id.must_equal spanner.project
    backup.expire_time.to_i.must_equal expire_time.to_i
    backup.create_time.must_be_kind_of Time
    backup.size_in_bytes.must_be :>, 0

    # Get
    instance = spanner.instance instance_id
    backup = instance.backup backup_id

    backup.wont_be :nil?
    backup.must_be_kind_of Google::Cloud::Spanner::Backup
    backup.backup_id.must_equal backup_id
    backup.database_id.must_equal database_id
    backup.instance_id.must_equal instance_id
    backup.project_id.must_equal spanner.project
    backup.expire_time.to_i.must_equal expire_time.to_i
    backup.create_time.must_be_kind_of Time
    backup.size_in_bytes.must_be :>, 0

    # Update
    backup.expire_time = expire_time + 3600
    backup = instance.backup backup_id
    backup.expire_time.to_i.must_equal((expire_time + 3600).to_i)

    proc {
      backup.expire_time = Time.now - 36000
    }.must_raise Google::Cloud::Error
    backup.expire_time.to_i.must_equal((expire_time + 3600 ).to_i)

    # Restore
    restore_database_id = "restore-#{database_id}"
    backup = instance.backup backup_id
    job = backup.restore restore_database_id
    job.wont_be :done?

    job.wait_until_done!

    job.must_be :done?
    job.wont_be :error?

    database = job.database
    database.must_be_kind_of Google::Cloud::Spanner::Database
    database.database_id.must_equal restore_database_id
    database.instance_id.must_equal instance_id
    database.project_id.must_equal spanner.project

    restore_info = database.restore_info
    restore_info.must_be_kind_of Google::Cloud::Spanner::Database::RestoreInfo
    restore_info.source_type.must_equal :BACKUP
    restore_info.must_be :source_backup?

    backup_info = restore_info.backup_info
    backup_info.must_be_kind_of Google::Cloud::Spanner::Database::BackupInfo
    backup_info.project_id.must_equal spanner.project
    backup_info.instance_id.must_equal instance_id
    backup_info.backup_id.must_equal backup_id
    backup_info.source_database_project_id.must_equal spanner.project
    backup_info.source_database_instance_id.must_equal instance_id
    backup_info.source_database_id.must_equal database_id
    backup_info.create_time.must_be_kind_of Time

    # Delete
    backup.delete
    instance.backup(backup_id).must_be :nil?
  end

  it "cancel create backup operation" do
    backup_id = "#{$spanner_database_id}-cancel"
    database = spanner.database instance_id, database_id

    job = database.create_backup backup_id, expire_time
    job.wont_be :done?

    job.cancel

    job.reload!
    job.must_be :done?
    job.error.wont_be :nil?
    job.error.code.must_equal 1
    job.error.description.must_equal "CANCELLED"
  end

  it "lists and gets database backups" do
    backup_id = "#{$spanner_database_id}-list"
    database = spanner.database instance_id, database_id
    database.wont_be :nil?

    job = database.create_backup backup_id, expire_time
    job.wait_until_done!
    backup = job.backup

    instance = spanner.instance instance_id

    # List all
    all_backups = instance.backups.all.to_a
    all_backups.wont_be :empty?
    all_backups.each do |backup|
      backup.must_be_kind_of Google::Cloud::Spanner::Backup
    end

    # Filter by backup name
    backups = instance.backups(filter: "name:#{backup_id}").to_a
    backups.length.must_equal 1
    backups.first.backup_id.must_equal backup_id

    # Filter by database name
    backups = instance.backups(filter: "database:#{database_id}").to_a
    backups.wont_be :empty?
    backups.first.database_id.must_equal database_id

    backup.delete
  end
end
