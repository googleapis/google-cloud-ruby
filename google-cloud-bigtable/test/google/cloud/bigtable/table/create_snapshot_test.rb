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
# See the License for the specific language governing permissions and
# limitations under the License.


require "helper"

describe Google::Cloud::Bigtable::Table, :create_snapshot, :mock_bigtable do
  let(:snapshot_id) { "new-snapshot" }
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_id) { "test-cluster" }
  let(:description) { "Test snapshot" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  }
  let(:table) {
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  }
  let(:snapshot_grpc){
    Google::Bigtable::Admin::V2::Snapshot.new(
      name: snapshot_path(instance_id, cluster_id, snapshot_id),
      source_table: table_grpc,
      data_size_bytes: 1024,
      state: :READY,
      description: description,
      create_time: Google::Protobuf::Timestamp.new(seconds: Time.now.to_i)
    )
  }
  let(:ops_name) { "operations/1234567890" }
  let(:job_data) {
    {
      name: ops_name,
      metadata: {
        type_url: "type.googleapis.com/google.bigtable.admin.v2.SnapshotTableMetadata",
        value: ""
      }
    }
  }
  let(:job_grpc) { Google::Longrunning::Operation.new(job_data) }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.SnapshotTableMetadata",
        value: Google::Bigtable::Admin::V2::CreateInstanceMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.Snapshot",
        value: snapshot_grpc.to_proto
      )
    )
  end

  it "create snapshot of table" do
    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Snapshot,
      Google::Bigtable::Admin::V2::SnapshotTableMetadata
    )

    mock.expect :snapshot_table, create_res, [
      table_path(instance_id, table_id),
      cluster_path(instance_id, cluster_id),
      snapshot_id,
      description,
      ttl: nil
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_tables = mock

    job = table.create_snapshot(snapshot_id, cluster_id, description: description)

    job.must_be_kind_of Google::Cloud::Bigtable::Snapshot::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.snapshot.must_be :nil?

    job.reload!
    snapshot = job.snapshot

    snapshot.wont_be :nil?
    snapshot.must_be_kind_of Google::Cloud::Bigtable::Snapshot

    mock.verify
  end

  it "create snapshot of table with ttl" do
    ttl_sec = 1800
    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Snapshot,
      Google::Bigtable::Admin::V2::SnapshotTableMetadata
    )

    mock.expect :snapshot_table, create_res, [
      table_path(instance_id, table_id),
      cluster_path(instance_id, cluster_id),
      snapshot_id,
      description,
      ttl: Google::Protobuf::Duration.new(seconds: ttl_sec)
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_tables = mock

    job = table.create_snapshot(
      snapshot_id, cluster_id, description: description, ttl: ttl_sec
    )

    job.must_be_kind_of Google::Cloud::Bigtable::Snapshot::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.snapshot.must_be :nil?

    job.reload!
    snapshot = job.snapshot

    snapshot.wont_be :nil?
    snapshot.must_be_kind_of Google::Cloud::Bigtable::Snapshot

    mock.verify
  end
end
