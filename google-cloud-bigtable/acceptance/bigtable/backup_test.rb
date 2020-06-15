# frozen_string_literal: true

# Copyright 2018 Google LLC
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
# See the License for the specific language governing backup and
# limitations under the License.


require "bigtable_helper"

describe Google::Cloud::Bigtable::Table, :bigtable do
  let(:instance) { bigtable_instance }
  let(:cluster) { instance.clusters.first }
  let(:table) { bigtable_read_table }
  let(:backup_id) { "my-backup-id-#{Time.now.to_i}" }
  let(:now) { Time.now }
  let(:expire_time) { now + 60 * 60 * 7 }
  let(:expire_time_2) { now + 60 * 60 * 8 }
  let(:restore_table_id) { "test-table-#{random_str}" }

  it "creates a backup" do
    backup = nil
    restore_table = nil
    begin
      # create
      job = cluster.create_backup table, backup_id, expire_time
      _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
      job.wait_until_done!
      _(job.error).must_be :nil?
      backup = job.backup
      _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup.backup_id).must_equal backup_id
      source_table = backup.source_table
      _(source_table).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table.path).must_equal table.path
      source_table_full = backup.source_table perform_lookup: true
      _(source_table_full).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table_full.path).must_equal table.path
      _(backup.expire_time).must_equal expire_time
      _(backup.start_time).must_be_kind_of Time
      _(backup.end_time).must_be_kind_of Time
      _(backup.size_bytes).must_be_kind_of Integer
      _(backup.state).must_equal :READY
      _(backup.creating?).must_equal false
      _(backup.ready?).must_equal true

      # get
      backup = cluster.backup backup_id
      _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup.backup_id).must_equal backup_id

      # update
      backup.expire_time = expire_time_2
      backup.save
      _(backup.expire_time).must_equal expire_time_2

      # reload
      backup.expire_time = expire_time
      _(backup.expire_time).must_equal expire_time # not persisted with #save
      backup.reload!
      _(backup.expire_time).must_equal expire_time_2

      # list
      backups = cluster.backups
      _(backups).must_be_kind_of Google::Cloud::Bigtable::Backup::List
      _(backups).wont_be :empty?
      list_backup = backups.find { |b| b.backup_id == backup_id }
      _(list_backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(list_backup.expire_time).must_equal expire_time_2

      # restore

      # Wait 2 minutes so that the RestoreTable API will trigger an optimize restored table operation.
      sleep(120)
      restore_job = backup.restore restore_table_id
      _(restore_job).must_be_kind_of Google::Cloud::Bigtable::Table::RestoreJob
      restore_job.wait_until_done!
      _(restore_job.error).must_be :nil?
      restore_table = restore_job.table
      _(restore_table).must_be_kind_of Google::Cloud::Bigtable::Table
      _(restore_table.name).must_equal restore_table_id

      # optimize
      _(restore_job.optimize_table_operation_name).wont_be :nil?
      _(restore_job.optimize_table_operation_name).must_be_kind_of String
      _(restore_job.optimize_table_operation_name).must_include restore_table_id
    ensure
      # delete
      backup.delete if backup
      # delete
      restore_table.delete if restore_table
    end
  end
end
