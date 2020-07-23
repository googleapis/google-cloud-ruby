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

describe "Spanner Database Backup Operations", :spanner do
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { $spanner_database_id }
  let(:backup_id) { "#{$spanner_database_id}-ops" }
  let(:expire_time) { Time.now + 36000 }

  it "list backup operations" do
    skip if emulator_enabled?

    instance = spanner.instance instance_id
    _(instance).wont_be :nil?

    database = instance.database database_id
    _(database).wont_be :nil?

    job = database.create_backup backup_id, expire_time
    job.wait_until_done!

    # All
    jobs = instance.backup_operations.all.to_a
    _(jobs).wont_be :empty?

    jobs.each do |job|
      _(job).must_be_kind_of Google::Cloud::Spanner::Backup::Job

      unless job.error?
        _(job.backup).must_be_kind_of Google::Cloud::Spanner::Backup
      end

      _(job.progress_percent).must_be :>=, 0
      _(job.start_time).must_be_kind_of Time
    end

    job = jobs.first
    _(job.reload!).must_be_kind_of Google::Cloud::Spanner::Backup::Job

    # Filter completed jobs
    filter = "done:true"
    jobs = instance.backup_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job).must_be :done?
    end

    # Filter by database name
    filter = "metadata.database:#{database_id}"
    jobs = instance.backup_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job.backup.database_id).must_equal database_id unless job.error?
    end

    # Filter by metdata type
    filter = "metadata.@type:CreateBackupMetadata"
    jobs = instance.backup_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job.grpc.metadata).must_be_kind_of Google::Cloud::Spanner::Admin::Database::V1::CreateBackupMetadata
    end

    # Filter by job start time
    time = (Time.now - 360000)
    filter = "metadata.progress.start_time > \"#{time.iso8601}\""
    jobs = instance.backup_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job.start_time).must_be :>, time
    end

    # Filer - AND
    time = (Time.now - 360000)
    filter = [
      "metadata.database:#{database_id}",
      "metadata.progress.start_time > \"#{time.iso8601}\""
    ].map{|f| "(#{f})"}.join(" AND ")

    jobs = instance.backup_operations(filter: filter).all.to_a
    _(jobs).wont_be :empty?
    jobs.each do |job|
      _(job.backup.database_id).must_equal database_id unless job.error?
      _(job.start_time).must_be :>, time
    end
  end
end
