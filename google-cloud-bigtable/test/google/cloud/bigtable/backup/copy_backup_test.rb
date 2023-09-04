# frozen_string_literal: true

# Copyright 2022 Google LLC
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

describe Google::Cloud::Bigtable::Backup, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:backup_id) { "test-backup" }
  let(:source_table_id) { "test-table-source" }
  let(:now) { Time.now.round 0 }
  let(:expire_time) { now + 60 * 60 * 7 }
  let(:start_time) { now + 60 }
  let(:end_time) { now + 120 }
  let(:size_bytes) { 123456 }
  let(:state) { :READY }
  let(:source_backup) {"projects/#{bigtable.service.project_id}/instances/#{instance_id}/clusters/#{cluster_id}/backups/#{backup_id}" }
  let(:copy_backup_id) { "test-backup-2" }
  let :backup_copy do
    backup_grpc instance_id,
                cluster_id,
                copy_backup_id,
                source_table_id,
                expire_time,
                start_time: start_time,
                end_time: end_time,
                size_bytes: size_bytes,
                state: state,
                source_backup: source_backup
  end
  let :backup_res do
    backup_grpc instance_id,
                cluster_id,
                backup_id,
                source_table_id,
                expire_time,
                start_time: start_time,
                end_time: end_time,
                size_bytes: size_bytes,
                state: state
  end
  let(:backup) { Google::Cloud::Bigtable::Backup.from_grpc backup_res, bigtable.service }
  let(:ops_name) { "operations/1234567890" }
  let(:job_grpc) do
    operation_pending_grpc ops_name, "type.googleapis.com/google.bigtable.admin.v2.CopyBackupMetadata"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.CopyBackupMetadata",
      Google::Cloud::Bigtable::Admin::V2::CopyBackupMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.Backup",
      backup_copy
    )
  end

  it "creates a copy of the backup from the backup class" do
    mock = Minitest::Mock.new
    mock.expect :copy_backup, operation_grpc(job_grpc, mock),
                parent: "projects/#{bigtable.service.project_id}/instances/#{instance_id}/clusters/#{cluster_id}",
                backup_id: copy_backup_id,
                source_backup: source_backup,
                expire_time: expire_time
    mock.expect :get_operation, operation_grpc(job_done_grpc, mock), [{name: ops_name}, Gapic::CallOptions]
    bigtable.service.mocked_tables = mock
    job = backup.copy dest_project_id: bigtable.service.project_id,
                      dest_instance_id: instance_id,
                      dest_cluster_id: cluster_id,
                      new_backup_id: copy_backup_id,
                      expire_time: expire_time
    _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?

    job.reload!
    backup = job.backup

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
    _(backup.source_backup).must_equal source_backup
    _(backup.backup_id).must_equal copy_backup_id

    mock.verify
  end

  it "creates a copy of the backup from the project class" do
    mock = Minitest::Mock.new
    mock.expect :copy_backup, operation_grpc(job_grpc, mock),
                parent: "projects/#{bigtable.service.project_id}/instances/#{instance_id}/clusters/#{cluster_id}",
                backup_id: copy_backup_id,
                source_backup: source_backup,
                expire_time: expire_time
    mock.expect :get_operation, operation_grpc(job_done_grpc, mock), [{name: ops_name}, Gapic::CallOptions]
    bigtable.service.mocked_tables = mock

    job = bigtable.copy_backup dest_project_id: bigtable.service.project_id,
                               dest_instance_id: instance_id,
                               dest_cluster_id: cluster_id,
                               new_backup_id: copy_backup_id,
                               source_instance_id: instance_id,
                               source_cluster_id: cluster_id,
                               source_backup_id: backup_id,
                               expire_time: expire_time
    _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?

    job.reload!
    backup = job.backup

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
    _(backup.source_backup).must_equal source_backup
    _(backup.backup_id).must_equal copy_backup_id

    mock.verify
  end

  def operation_grpc longrunning_grpc, mock
    Gapic::Operation.new(
      longrunning_grpc,
      mock,
      result_type: Google::Cloud::Bigtable::Admin::V2::Backup,
      metadata_type: Google::Cloud::Bigtable::Admin::V2::CopyBackupMetadata
    )
  end
end
