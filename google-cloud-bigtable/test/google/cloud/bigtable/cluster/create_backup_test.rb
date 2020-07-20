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
# See the License for the specific language governing permissions and
# limitations under the License.


require "helper"

describe Google::Cloud::Bigtable::Cluster, :create_backup, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let :cluster_grpc do
    Google::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: 3,
      location: location_path("us-east-1b"),
      default_storage_type: :SSD,
      state: :READY
    )
  end
  let(:cluster) { Google::Cloud::Bigtable::Cluster.from_grpc cluster_grpc, bigtable.service }
  let(:ops_name) { "operations/1234567890" }
  let(:job_grpc) do
    operation_pending_grpc ops_name, "type.googleapis.com/google.bigtable.admin.v2.CreateBackupMetadata"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.CreateBackupMetadata",
      Google::Bigtable::Admin::V2::CreateBackupMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.Backup",
      backup_grpc
    )
  end
  let(:backup_id) { "test-backup" }
  let(:source_table_id) { "test-table-source" }
  let :source_table_grpc do
    Google::Bigtable::Admin::V2::Table.new table_hash(name: table_path(instance_id, source_table_id))
  end
  let(:source_table) { Google::Cloud::Bigtable::Table.from_grpc source_table_grpc, bigtable.service }
  let(:expire_time) { Time.now.round(0) + 60 * 60 * 7 }
  let :backup_grpc do
    Google::Bigtable::Admin::V2::Backup.new source_table: table_path(instance_id, source_table_id),
                                            expire_time:  expire_time
  end

  it "creates a backup with table as string ID" do
    mock = Minitest::Mock.new
    mock.expect :create_backup, operation_grpc(mock), [cluster_path(instance_id, cluster_id), backup_id, backup_grpc]
    mock.expect :get_operation, job_done_grpc, [ops_name, Hash]
    bigtable.service.mocked_tables = mock

    job = cluster.create_backup source_table_id, backup_id, expire_time

    _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.backup).must_be :nil?

    job.reload!
    backup = job.backup

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup

    mock.verify
  end

  it "creates a backup with table object" do
    mock = Minitest::Mock.new
    mock.expect :create_backup, operation_grpc(mock), [cluster_path(instance_id, cluster_id), backup_id, backup_grpc]
    mock.expect :get_operation, job_done_grpc, [ops_name, Hash]
    bigtable.service.mocked_tables = mock

    job = cluster.create_backup source_table, backup_id, expire_time

    _(job).must_be_kind_of Google::Cloud::Bigtable::Backup::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.backup).must_be :nil?

    job.reload!
    backup = job.backup

    _(backup).wont_be :nil?
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup

    mock.verify
  end

  def operation_grpc mock
    Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Backup,
      Google::Bigtable::Admin::V2::CreateBackupMetadata
    )
  end
end
