# frozen_string_literal: true

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
# See the License for the specific language governing backup and
# limitations under the License.


require "bigtable_helper"

describe Google::Cloud::Bigtable::Table, :bigtable do
  let(:instance) { bigtable_instance }
  let(:instance_2) { bigtable_instance_2 }
  let(:cluster) { instance.clusters.first }
  let(:table) { bigtable_read_table }
  let(:copy_backup_id_1) { "test-backup-#{random_str}" }
  let(:copy_backup_id_2) { "test-backup-#{random_str}" }
  let(:backup_id) { "test-backup-#{Time.now.to_i}-#{random_str}" }
  let(:now) { Time.now.round 0 }
  let(:expire_time) { now + 60 * 60 * 720 }
  let(:expire_time_2) { now + 60 * 60 * 8 }
  let(:restore_table_id) { "test-table-#{Time.now.to_i}-#{random_str}" }
  let(:restore_table_id_2) { "test-table-#{Time.now.to_i}-#{random_str}" }
  let(:service_account) { bigtable.service.credentials.client.issuer }
  let(:roles) { ["bigtable.backups.delete", "bigtable.backups.get"] }
  let(:role) { "roles/bigtable.user" }
  let(:member) { "serviceAccount:#{service_account}" }
  let(:source_backup) { "projects/#{bigtable.project_id}/instances/#{instance.instance_id}/clusters/#{cluster.cluster_id}/backups/#{backup_id}" }

  it "creates a backup" do
    backup = nil
    restore_table = nil
    restore_table_2 = nil
    begin
      # create
      job = cluster.create_backup table, backup_id, expire_time
      _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
      job.wait_until_done!
      _(job.error).must_be :nil?

      backup = job.backup
      _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup.backup_id).must_equal backup_id
      _(backup.expire_time).must_equal expire_time
      _(backup.start_time).must_be_kind_of Time
      _(backup.end_time).must_be_kind_of Time
      _(backup.size_bytes).must_be_kind_of Integer
      _(backup.state).must_equal :READY
      _(backup.creating?).must_equal false
      _(backup.ready?).must_equal true
      encryption_info = backup.encryption_info
      _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
      _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
      _(encryption_info.encryption_status).must_be :nil?
      _(encryption_info.kms_key_version).must_be :nil?

      source_table = backup.source_table
      _(source_table).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table.path).must_equal table.path

      source_table_full = backup.source_table perform_lookup: true
      _(source_table_full).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table_full.path).must_equal table.path

      # get
      backup = cluster.backup backup_id
      _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup.backup_id).must_equal backup_id
      _(backup.expire_time).must_equal expire_time

      # update
      backup.expire_time = expire_time_2
      backup.save
      _(backup.expire_time).must_equal expire_time_2

      # reload
      backup.expire_time = expire_time
      _(backup.expire_time).must_equal expire_time # not yet persisted with #save
      backup.reload!
      _(backup.expire_time).must_equal expire_time_2

      # test permissions
      permissions = backup.test_iam_permissions roles
      _(permissions).must_be_kind_of Array
      _(permissions).must_equal roles

      # get policy
      policy = backup.policy
      _(policy).must_be_kind_of Google::Cloud::Bigtable::Policy
      _(policy.roles).must_be :empty?

      # update policy
      policy.add(role, member)
      updated_policy = backup.update_policy policy
      _(updated_policy.roles.size).must_equal 1
      _(updated_policy.role(role)).wont_be :nil?
      role_member = backup.policy.role(role).select { |m| m == member }
      _(role_member.size).must_equal 1

      # list
      backups = cluster.backups
      _(backups).must_be_kind_of Google::Cloud::Bigtable::Backup::List
      _(backups).wont_be :empty?
      list_backup = backups.all.find { |b| b.backup_id == backup_id }
      _(list_backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(list_backup.expire_time).must_equal expire_time_2

      # restore
      # Wait 2 minutes so that the RestoreTable API will trigger an optimize restored table operation.
      # https://github.com/googleapis/java-bigtable/blob/33ffd938c06352108ccf7c1e5c970cce27771c72/google-cloud-bigtable/src/test/java/com/google/cloud/bigtable/admin/v2/it/BigtableBackupIT.java#L307-L309
      sleep(120)

      restore_job = backup.restore restore_table_id
      _(restore_job).must_be_kind_of Google::Cloud::Bigtable::Table::RestoreJob
      restore_job.wait_until_done!
      _(restore_job.error).must_be :nil?
      restore_table = restore_job.table
      _(restore_table).must_be_kind_of Google::Cloud::Bigtable::Table
      _(restore_table.name).must_equal restore_table_id
      _(restore_table.instance_id).must_equal instance.instance_id

      # optimize
      _(restore_job.optimize_table_operation_name).wont_be :nil?
      _(restore_job.optimize_table_operation_name).must_be_kind_of String
      _(restore_job.optimize_table_operation_name).must_include restore_table_id

      # restore to another instance
      restore_job = backup.restore restore_table_id_2, instance: instance_2
      _(restore_job).must_be_kind_of Google::Cloud::Bigtable::Table::RestoreJob
      restore_job.wait_until_done!
      _(restore_job.error).must_be :nil?
      restore_table_2 = restore_job.table
      _(restore_table_2).must_be_kind_of Google::Cloud::Bigtable::Table
      _(restore_table_2.name).must_equal restore_table_id_2
      _(restore_table_2.instance_id).must_equal instance_2.instance_id
    ensure
      # delete
      backup.delete if backup
      restore_table.delete if restore_table
      restore_table_2.delete if restore_table_2
    end
  end

  it "creates a copy of the backup using backup class" do
    backup = nil
    backup_1 = nil
    backup_2 = nil
    begin
      # create
      job = cluster.create_backup table, backup_id, expire_time
      _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
      job.wait_until_done!
      _(job.error).must_be :nil?

      backup = job.backup
      _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup.backup_id).must_equal backup_id
      _(backup.expire_time).must_equal expire_time
      _(backup.start_time).must_be_kind_of Time
      _(backup.end_time).must_be_kind_of Time
      _(backup.size_bytes).must_be_kind_of Integer
      _(backup.state).must_equal :READY
      _(backup.creating?).must_equal false
      _(backup.ready?).must_equal true
      encryption_info = backup.encryption_info
      _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
      _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
      _(encryption_info.encryption_status).must_be :nil?
      _(encryption_info.kms_key_version).must_be :nil?

      source_table = backup.source_table
      _(source_table).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table.path).must_equal table.path

      source_table_full = backup.source_table perform_lookup: true
      _(source_table_full).must_be_kind_of Google::Cloud::Bigtable::Table
      _(source_table_full.path).must_equal table.path

      # copy the backup using backup class
      job = backup.copy dest_project_id: bigtable.project_id,
                        dest_instance_id: instance.instance_id,
                        dest_cluster_id: cluster.cluster_id,
                        new_backup_id: copy_backup_id_1,
                        expire_time: expire_time
      _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
      job.wait_until_done!
      _(job.error).must_be :nil?

      backup_1 = job.backup
      _(backup_1).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup_1.backup_id).must_equal copy_backup_id_1
      _(backup_1.expire_time).must_equal expire_time
      _(backup_1.source_backup).must_equal source_backup

      # copy the backup using client class
      job = bigtable.copy_backup dest_project_id: cluster.project_id,
                                 dest_instance_id: cluster.instance_id,
                                 dest_cluster_id: cluster.cluster_id,
                                 new_backup_id: copy_backup_id_2,
                                 source_instance_id: instance.instance_id,
                                 source_cluster_id: cluster.cluster_id,
                                 source_backup_id: backup_id,
                                 expire_time: expire_time
      _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
      job.wait_until_done!
      _(job.error).must_be :nil?

      backup_2 = job.backup
      _(backup_2).must_be_kind_of Google::Cloud::Bigtable::Backup
      _(backup_2.backup_id).must_equal copy_backup_id_2
      _(backup_2.expire_time).must_equal expire_time
      _(backup_2.source_backup).must_equal source_backup

    ensure
      # delete
      backup.delete if backup
      backup_1.delete if backup_1
      backup_2.delete if backup_2
    end

  end
end
