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
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:location_id) { "us-east-1b" }
  let(:nodes) { 3 }
  let(:cluster_grpc) do
    Google::Cloud::Bigtable::Admin::V2::Cluster.new(
      name: cluster_path(instance_id, cluster_id),
      serve_nodes: nodes,
      location: location_path(location_id),
      default_storage_type: :SSD,
      state: :READY
    )
  end
  let(:cluster) { Google::Cloud::Bigtable::Cluster.from_grpc(cluster_grpc, bigtable.service) }

  it "knows the identifiers" do
    _(cluster).must_be_kind_of Google::Cloud::Bigtable::Cluster
    _(cluster.project_id).must_equal project_id
    _(cluster.instance_id).must_equal instance_id
    _(cluster.cluster_id).must_equal cluster_id
    _(cluster.path).must_equal cluster_path(instance_id, cluster_id)
    _(cluster.nodes).must_equal nodes
    _(cluster.location).must_equal location_id
    _(cluster.location_path).must_equal location_path(location_id)
    _(cluster.state).must_equal :READY
    _(cluster).must_be :ready?
    _(cluster).wont_be :creating?
    _(cluster).wont_be :resizing?
    _(cluster).wont_be :disabled?
  end

  it "reloads its state" do
    mock = Minitest::Mock.new
    mock.expect :get_cluster, cluster_grpc, [name: cluster_path(instance_id, cluster_id)]
    cluster.service.mocked_instances = mock

    cluster.reload!

    mock.verify

    _(cluster.project_id).must_equal project_id
    _(cluster.instance_id).must_equal instance_id
    _(cluster.cluster_id).must_equal cluster_id
    _(cluster.path).must_equal cluster_path(instance_id, cluster_id)
    _(cluster.state).must_equal :READY
    _(cluster.ready?).must_equal true
    _(cluster.storage_type).must_equal :SSD
    _(cluster.nodes).must_equal 3
  end
end
