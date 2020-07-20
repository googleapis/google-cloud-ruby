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

describe Google::Cloud::Bigtable::Cluster, :save, :mock_bigtable do
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
  let(:ops_name) { "operations/1234567890" }
  let(:job_grpc) do
    operation_pending_grpc ops_name, "type.googleapis.com/google.bigtable.admin.v2.UpdateClusterMetadata"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.UpdateClusterMetadata",
      Google::Bigtable::Admin::V2::UpdateClusterMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.Cluster",
      cluster_grpc
    )
  end

  it "updates and saves itself" do
    location = "us-east-1b"
    serve_nodes = 3
    cluster.nodes = serve_nodes

    mock = Minitest::Mock.new
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   mock,
                   Google::Bigtable::Admin::V2::Cluster,
                   Google::Bigtable::Admin::V2::UpdateClusterMetadata
                 )
    mock.expect :update_cluster, update_res, [
      cluster_path(instance_id, cluster_id),
      location_path(location),
      serve_nodes
    ]
    mock.expect :get_operation, job_done_grpc, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = cluster.save

    _(job).must_be_kind_of Google::Cloud::Bigtable::Cluster::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.cluster).must_be :nil?

    job.reload!
    cluster = job.cluster

    _(cluster).wont_be :nil?
    _(cluster).must_be_kind_of Google::Cloud::Bigtable::Cluster

    mock.verify
  end
end
