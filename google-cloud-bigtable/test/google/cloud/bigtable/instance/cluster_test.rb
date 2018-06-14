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

describe Google::Cloud::Bigtable::Project, :table, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:location_id) { "us-east-1b" }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }

  it "gets an cluster" do
    cluster_id = "found-cluster"

    get_res = Google::Bigtable::Admin::V2::Cluster.new(
      cluster_hash(
        name: cluster_path(instance_id, cluster_id),
        nodes: 3,
        location: location_id,
        storage_type: :SSD,
        state: :READY
      )
    )

    mock = Minitest::Mock.new
    mock.expect :get_cluster, get_res, [cluster_path(instance_id, cluster_id)]
    bigtable.service.mocked_instances = mock
    cluster = instance.cluster(cluster_id)

    mock.verify

    cluster.project_id.must_equal project_id
    cluster.instance_id.must_equal instance_id
    cluster.cluster_id.must_equal cluster_id
    cluster.path.must_equal cluster_path(instance_id, cluster_id)
    cluster.state.must_equal :READY
    cluster.ready?.must_equal true
    cluster.storage_type.must_equal :SSD
    cluster.nodes.must_equal 3
  end

  it "returns nil when getting an non-existent cluster" do
    not_found_cluster_id = "not-found-cluster"

    stub = Object.new
    def stub.get_cluster *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end

    bigtable.service.mocked_instances = stub

    cluster = instance.cluster(not_found_cluster_id)
    cluster.must_be :nil?
  end
end
