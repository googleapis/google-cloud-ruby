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

describe Google::Cloud::Bigtable::Backup, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:backup_id) { "test-backup" }
  let(:source_table_id) { "test-table-source" }
  let :source_table_grpc do
    Google::Cloud::Bigtable::Admin::V2::Table.new table_hash(name: table_path(instance_id, source_table_id))
  end
  let(:source_table) { Google::Cloud::Bigtable::Table.from_grpc source_table_grpc, bigtable.service }
  let(:target_table_id) { "test-table-target" }
  let :target_table_grpc do
    Google::Cloud::Bigtable::Admin::V2::Table.new table_hash(name: table_path(instance_id, target_table_id))
  end
  let(:now) { Time.now.round 0 }
  let(:expire_time) { now + 60 * 60 * 7 }
  let(:expire_time_2) { now + 60 * 60 * 8 }
  let(:start_time) { now + 60 }
  let(:end_time) { now + 120 }
  let(:size_bytes) { 123456 }
  let(:state) { :READY }
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
    operation_pending_grpc ops_name, "type.googleapis.com/google.bigtable.admin.v2.RestoreTableMetadata"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.RestoreTableMetadata",
      Google::Cloud::Bigtable::Admin::V2::RestoreTableMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.Table",
      target_table_grpc
    )
  end

  it "knows its simple attributes" do
    _(backup).must_be_kind_of Google::Cloud::Bigtable::Backup
    _(backup.project_id).must_equal project_id
    _(backup.instance_id).must_equal instance_id
    _(backup.cluster_id).must_equal cluster_id
    _(backup.backup_id).must_equal backup_id
    _(backup.path).must_equal backup_res.name
    _(backup.expire_time).must_equal expire_time
    _(backup.start_time).must_equal start_time
    _(backup.end_time).must_equal end_time
    _(backup.size_bytes).must_equal size_bytes
    _(backup.state).must_equal state
    _(backup.creating?).must_equal false
    _(backup.ready?).must_equal true
  end

  it "returns its source_table without options as view: :NAME_ONLY" do
    table = backup.source_table

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal source_table_id
    _(table.path).must_equal table_path(instance_id, source_table_id)
  end

  it "returns its source_table with perform_lookup and view options" do
    cluster_states = clusters_state_grpc
    column_families = column_families_grpc
    get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, source_table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )

    mock = Minitest::Mock.new
    mock.expect :get_table, get_res, [name: table_path(instance_id, source_table_id), view: :FULL]
    bigtable.service.mocked_tables = mock
    table = backup.source_table perform_lookup: true, view: :FULL

    mock.verify

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal source_table_id
    _(table.path).must_equal table_path(instance_id, source_table_id)
    _(table.granularity).must_equal :MILLIS
    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
  end

  it "updates its expire_time" do
    mock = Minitest::Mock.new
    update_grpc = backup_res.dup
    update_grpc.expire_time = expire_time_2
    mock.expect :update_backup, update_grpc, [backup: update_grpc, update_mask: Google::Protobuf::FieldMask.new(paths: ["expire_time"])]
    bigtable.service.mocked_tables = mock

    backup.expire_time = expire_time_2
    backup.save

    mock.verify
  end

  it "restores to a target table" do
    mock = Minitest::Mock.new
    update_grpc = backup_res.dup
    update_grpc.expire_time = expire_time_2
    mock.expect :restore_table,
                operation_grpc(job_grpc, mock),
                [
                  parent: instance_path(instance_id),
                  table_id: target_table_id,
                  backup: backup_path(instance_id, cluster_id, backup_id)
                ]
    mock.expect :get_operation, operation_grpc(job_done_grpc, mock), [{name: ops_name}, Gapic::CallOptions]
    bigtable.service.mocked_tables = mock

    job = backup.restore target_table_id

    _(job).must_be_kind_of Google::Cloud::Bigtable::Table::RestoreJob
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.table).must_be :nil?

    job.reload!
    table = job.table

    _(table).wont_be :nil?
    _(table).must_be_kind_of Google::Cloud::Bigtable::Table

    mock.verify
  end

  it "reloads its state" do
    mock = Minitest::Mock.new
    mock.expect :get_backup, backup_res, [name: backup_path(instance_id, cluster_id, backup_id)]
    bigtable.service.mocked_tables = mock

    backup.reload!

    mock.verify
  end

  it "deletes itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_backup, nil, [name: backup_path(instance_id, cluster_id, backup_id)]
    bigtable.service.mocked_tables = mock

    backup.delete

    mock.verify
  end

  def operation_grpc longrunning_grpc, mock
    Gapic::Operation.new(
      longrunning_grpc,
      mock,
      result_type: Google::Cloud::Bigtable::Admin::V2::Table,
      metadata_type: Google::Cloud::Bigtable::Admin::V2::RestoreTableMetadata
    )
  end
end
