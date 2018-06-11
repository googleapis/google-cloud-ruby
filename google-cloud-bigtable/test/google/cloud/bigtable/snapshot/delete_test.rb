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

describe Google::Cloud::Bigtable::Snapshot, :delete, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:snapshot_id) { "test-snapshot" }
  let(:snapshot_grpc) {
     Google::Bigtable::Admin::V2::Snapshot.new(
      name: snapshot_path(instance_id, cluster_id, snapshot_id),
      source_table: Google::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, "table-1"),
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

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_snapshot, true, [snapshot_grpc.name]
    bigtable.service.mocked_tables = mock

    result = snapshot.delete
    result.must_equal true
    mock.verify
  end
end
