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

describe Google::Cloud::Bigtable::Snapshot, :create_table, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:snapshot_id) { "test-snapshot" }
  let(:table_id) { "new-table" }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
    )
  }
  let(:table) {
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  }
  let(:snapshot_grpc) {
     Google::Bigtable::Admin::V2::Snapshot.new(
      name: snapshot_path(instance_id, cluster_id, snapshot_id),
      source_table: Google::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, "source-table"),
      ),
      data_size_bytes: 1024,
      state: :READY,
      description: "Test table snapshot",
      create_time: Google::Protobuf::Timestamp.new(seconds: Time.now.to_i)
    )
  }
  let(:snapshot) {
    Google::Cloud::Bigtable::Snapshot.from_grpc(snapshot_grpc, bigtable.service)
  }
  let(:ops_name) {
    "operations/1234567890"
  }
  let(:job_data) {
    {
      name: ops_name,
      metadata: {
        type_url: "type.googleapis.com/google.bigtable.admin.v2.CreateTableFromSnapshotMetadata",
        value: ""
      }
    }
  }
  let(:job_grpc) { Google::Longrunning::Operation.new(job_data) }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.CreateTableFromSnapshotMetadata",
        value: Google::Bigtable::Admin::V2::CreateTableFromSnapshotMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.Table",
        value: table_grpc.to_proto
      )
    )
  end

  it "create table from snapshot" do
    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Table,
      Google::Bigtable::Admin::V2::CreateTableFromSnapshotMetadata
    )

    mock.expect :create_table_from_snapshot, create_res, [
      instance_path(instance_id),
      table_id,
      snapshot_path(instance_id, cluster_id, snapshot_id),
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_tables = mock

    job = snapshot.create_table(table_id)

    job.must_be_kind_of Google::Cloud::Bigtable::Table::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.table.must_be :nil?

    job.reload!
    table = job.table

    table.wont_be :nil?
    table.must_be_kind_of Google::Cloud::Bigtable::Table

    mock.verify
  end
end
