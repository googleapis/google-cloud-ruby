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
# See the License for the specific language governing permissions and
# limitations under the License.


require "helper"

describe Google::Cloud::Bigtable::Cluster, :snapshot, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:cluster_grpc){
    Google::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: 3,
      location: location_path("us-east-1b"),
      default_storage_type: :SSD,
      state: :READY
    )
  }
  let(:cluster) {
    Google::Cloud::Bigtable::Cluster.from_grpc(cluster_grpc, bigtable.service)
  }
  let(:table_id) { "test-table" }
  let(:table_grpc){
    Google::Bigtable::Admin::V2::Table.new(name: table_path(instance_id, table_id))
  }
  let(:table) {
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  }

  it "gets a snapshot" do
    snapshot_id = "found-snapshot"
    description = "Test snapshot"
    data_size = 1024
    create_timestamp = Time.now.to_i

    get_res = Google::Bigtable::Admin::V2::Snapshot.new(
      name: snapshot_path(instance_id, cluster_id, snapshot_id),
      source_table: table_grpc,
      data_size_bytes: data_size,
      state: :READY,
      description: description,
      create_time: Google::Protobuf::Timestamp.new(seconds: create_timestamp)
    )

    mock = Minitest::Mock.new
    mock.expect :get_snapshot, get_res, [snapshot_path(instance_id, cluster_id, snapshot_id)]
    bigtable.service.mocked_tables = mock
    snapshot = cluster.snapshot(snapshot_id)

    mock.verify

    snapshot.must_be_kind_of Google::Cloud::Bigtable::Snapshot
    snapshot.project_id.must_equal project_id
    snapshot.instance_id.must_equal instance_id
    snapshot.cluster_id.must_equal cluster_id
    snapshot.name.must_equal snapshot_id
    snapshot.path.must_equal snapshot_path(instance_id, cluster_id, snapshot_id)
    snapshot.description.must_equal description
    snapshot.create_time.must_equal Time.at(create_timestamp)
    snapshot.data_size.must_equal data_size
    snapshot.source_table.must_be_kind_of Google::Cloud::Bigtable::Table
    snapshot.source_table.name.must_equal table_id

    snapshot.state.must_equal :READY
    snapshot.must_be :ready?
    snapshot.wont_be :creating?
  end

  it "returns nil when getting an non-existent snapshot" do
    not_found_snapshot_id = "not-found-snapshot"

    stub = Object.new
    def stub.get_snapshot *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end

    bigtable.service.mocked_tables = stub

    snapshot = cluster.snapshot(not_found_snapshot_id)
    snapshot.must_be :nil?
  end
end
