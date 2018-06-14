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

describe Google::Cloud::Bigtable::Snapshot, :mock_bigtable do
  let(:snapshot_id) { "test-snapshot" }
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_id) { "test-cluster" }
  let(:description) { "Test snapshot" }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(
      name: table_path(instance_id, table_id),
      granularity: :MILLIS
    )
  }

  it "knows the identifiers" do
    create_timestamp = Time.now.to_i
    delete_timestamp = create_timestamp + 10
    data_size = 1024

    snapshot_grpc = Google::Bigtable::Admin::V2::Snapshot.new(
      name: snapshot_path(instance_id, cluster_id, snapshot_id),
      source_table: table_grpc,
      data_size_bytes: data_size,
      state: :READY,
      description: description,
      create_time: Google::Protobuf::Timestamp.new(seconds: create_timestamp),
      delete_time: Google::Protobuf::Timestamp.new(seconds: delete_timestamp)
    )

    snapshot = Google::Cloud::Bigtable::Snapshot.from_grpc(snapshot_grpc, bigtable.service)

    snapshot.must_be_kind_of Google::Cloud::Bigtable::Snapshot
    snapshot.project_id.must_equal project_id
    snapshot.instance_id.must_equal instance_id
    snapshot.cluster_id.must_equal cluster_id
    snapshot.name.must_equal snapshot_id
    snapshot.path.must_equal snapshot_path(instance_id, cluster_id, snapshot_id)
    snapshot.description.must_equal description
    snapshot.create_time.must_equal Time.at(create_timestamp)
    snapshot.delete_time.must_equal Time.at(delete_timestamp)
    snapshot.data_size.must_equal data_size
    snapshot.source_table.wont_be :nil?
    snapshot.source_table.name.must_equal table_id
    snapshot.state.must_equal :READY
    snapshot.must_be :ready?
    snapshot.wont_be :creating?
  end
end
