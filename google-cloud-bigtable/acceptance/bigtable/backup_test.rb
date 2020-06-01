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
  let(:seven_hours) { 60 * 60 * 7 }
  let(:expire_time) { Time.now + seven_hours }
focus
  it "creates a backup" do
    backup = nil
    begin
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
      _(backup.expire_time).must_be_kind_of Time
      _(backup.start_time).must_be_kind_of Time
      _(backup.end_time).must_be_kind_of Time
      _(backup.size_bytes).must_be_kind_of Integer
      _(backup.state).must_equal :READY
      _(backup.creating?).must_equal false
      _(backup.ready?).must_equal true
    ensure
      backup.delete if backup
    end
  end
end
