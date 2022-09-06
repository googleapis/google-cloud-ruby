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
  let(:expire_time) { Time.now + 36_000 }

  it "creates, get, updates, restore and delete a database backup" do
    skip if emulator_enabled?

    backup_id = "#{$spanner_database_id}-crud"
    database = spanner.database instance_id, database_id
    _(database).wont_be :nil?
    version_time = database.earliest_version_time

    encryption_config = { encryption_type: :GOOGLE_DEFAULT_ENCRYPTION }

    # Create
    job = database.create_backup backup_id,
                                 expire_time,
                                 version_time: version_time,
                                 encryption_config: encryption_config

    _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job
    _(job).wont_be :done?
    job.wait_until_done!

    _(job).must_be :done?
    _(job.error).must_be :nil?

    backup = job.backup
    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    _(backup.backup_id).must_equal backup_id
    _(backup.database_id).must_equal database_id
    _(backup.instance_id).must_equal instance_id
    _(backup.project_id).must_equal spanner.project
    _(backup.expire_time.to_i).must_equal expire_time.to_i
    _(backup.version_time.to_i).must_equal version_time.to_i
    _(backup.create_time).must_be_kind_of Time
    _(backup.size_in_bytes).must_be :>=, 0
    _(backup.encryption_info).must_be_kind_of Google::Cloud::Spanner::Admin::Database::V1::EncryptionInfo
    _(backup.encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION

    # Get
    instance = spanner.instance instance_id
    backup = instance.backup backup_id

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    _(backup.backup_id).must_equal backup_id
    _(backup.database_id).must_equal database_id
    _(backup.instance_id).must_equal instance_id
    _(backup.project_id).must_equal spanner.project
    _(backup.expire_time.to_i).must_equal expire_time.to_i
    _(backup.version_time.to_i).must_equal version_time.to_i
    _(backup.create_time).must_be_kind_of Time
    _(backup.size_in_bytes).must_be :>=, 0

    # Update
    backup.expire_time = expire_time + 3600
    backup = instance.backup backup_id
    _(backup.expire_time.to_i).must_equal((expire_time + 3600).to_i)

    _ do
      backup.expire_time = Time.now - 36_000
    end.must_raise Google::Cloud::InvalidArgumentError
    _(backup.expire_time.to_i).must_equal((expire_time + 3600).to_i)

    # Restore
    restore_database_id = "restore-#{database_id}"
    backup = instance.backup backup_id
    job = backup.restore restore_database_id, encryption_config: encryption_config
    _(job).wont_be :done?

    job.wait_until_done!

    _(job).must_be :done?
    _(job).wont_be :error?

    database = job.database
    _(database).must_be_kind_of Google::Cloud::Spanner::Database
    _(database.database_id).must_equal restore_database_id
    _(database.instance_id).must_equal instance_id
    _(database.project_id).must_equal spanner.project

    restore_info = database.restore_info
    _(restore_info).must_be_kind_of Google::Cloud::Spanner::Database::RestoreInfo
    _(restore_info.source_type).must_equal :BACKUP
    _(restore_info).must_be :source_backup?

    backup_info = restore_info.backup_info
    _(backup_info).must_be_kind_of Google::Cloud::Spanner::Database::BackupInfo
    _(backup_info.project_id).must_equal spanner.project
    _(backup_info.instance_id).must_equal instance_id
    _(backup_info.backup_id).must_equal backup_id
    _(backup_info.source_database_project_id).must_equal spanner.project
    _(backup_info.source_database_instance_id).must_equal instance_id
    _(backup_info.source_database_id).must_equal database_id
    _(backup_info.create_time).must_be_kind_of Time
    _(backup_info.version_time.to_i).must_equal version_time.to_i

    # Delete
    backup.delete
    _(instance.backup(backup_id)).must_be :nil?
  end

  it "cancel create backup operation" do
    skip if emulator_enabled?

    backup_id = "#{$spanner_database_id}-cancel"
    database = spanner.database instance_id, database_id

    job = database.create_backup backup_id, expire_time
    _(job).wont_be :done?

    job.cancel

    job.reload!
    _(job).must_be :done?
    _(job.error).wont_be :nil?
    _(job.error.code).must_equal 1
    _(job.error.description).must_equal "CANCELLED"
  end

  it "fails to create a backup with a version time too far in the past" do
    skip if emulator_enabled?

    backup_id = "#{$spanner_database_id}-version-time-fail"
    database = spanner.database instance_id, database_id
    thirty_days_ago = Time.now - (30 * 24 * 60 * 60)

    assert_raises Google::Cloud::InvalidArgumentError do
      database.create_backup backup_id, expire_time, version_time: thirty_days_ago
    end
  end

  it "fails to create a backup with a version time in the future" do
    skip if emulator_enabled?

    backup_id = "#{$spanner_database_id}-version-time-fail"
    database = spanner.database instance_id, database_id
    tomorrow = Time.now + (24 * 60 * 60)

    assert_raises Google::Cloud::InvalidArgumentError do
      database.create_backup backup_id, expire_time, version_time: tomorrow
    end
  end

  it "lists and gets database backups" do
    skip if emulator_enabled?

    backup_id = "#{$spanner_database_id}-list"
    database = spanner.database instance_id, database_id
    _(database).wont_be :nil?

    job = database.create_backup backup_id, expire_time
    job.wait_until_done!
    created_backup = job.backup

    instance = spanner.instance instance_id

    # List all
    all_backups = instance.backups.all.to_a
    _(all_backups).wont_be :empty?
    all_backups.each do |backup|
      _(backup).must_be_kind_of Google::Cloud::Spanner::Backup
    end

    # Filter by backup name
    backups = instance.backups(filter: "name:#{backup_id}").to_a
    _(backups.length).must_equal 1
    _(backups.first.backup_id).must_equal backup_id

    # Filter by database name
    backups = instance.backups(filter: "database:#{database_id}").to_a
    _(backups).wont_be :empty?
    _(backups.first.database_id).must_equal database_id

    created_backup.delete
  end
end
