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

describe Google::Cloud::Bigtable::Cluster, :mock_bigtable do
  it "knows the identifiers" do
    instance_id = "test-instance"
    cluster_id = "test-cluster"
    location = "us-east-1b"
    nodes = 3

    cluster_grpc = Google::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: nodes,
      location: location_path(location),
      default_storage_type: :SSD,
      state: :READY
    )
    cluster = Google::Cloud::Bigtable::Cluster.from_grpc(cluster_grpc, bigtable.service)

    cluster.must_be_kind_of Google::Cloud::Bigtable::Cluster
    cluster.project_id.must_equal project_id
    cluster.instance_id.must_equal instance_id
    cluster.cluster_id.must_equal cluster_id
    cluster.path.must_equal cluster_path(instance_id, cluster_id)
    cluster.nodes.must_equal nodes
    cluster.location.must_equal location
    cluster.location_path.must_equal location_path(location)
    cluster.state.must_equal :READY
    cluster.must_be :ready?
    cluster.wont_be :creating?
    cluster.wont_be :resizing?
    cluster.wont_be :disabled?
  end
end
