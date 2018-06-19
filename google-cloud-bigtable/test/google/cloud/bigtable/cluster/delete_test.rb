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

describe Google::Cloud::Bigtable::Cluster, :delete, :mock_bigtable do
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

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_cluster, true, [cluster_grpc.name]
    bigtable.service.mocked_instances = mock

    result = cluster.delete
    result.must_equal true
    mock.verify
  end
end
