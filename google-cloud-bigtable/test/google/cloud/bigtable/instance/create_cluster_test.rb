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

describe Google::Cloud::Bigtable::Instance, :create_cluster, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "new-cluster" }
  let(:location_id) { "us-east-1b" }
  let(:cluster_grpc){
    Google::Cloud::Bigtable::Admin::V2::Cluster.new(
      cluster_hash(
        name: cluster_id,
        nodes: 3,
        location: location_id,
        storage_type: :SSD,
        state: :READY
      )
    )
  }
  let(:ops_name) {
    "operations/projects/#{project_id}/instances/#{instance_id}/clusters/#{cluster_id}/locations/us-east-1b/operations/1234567890"
  }
  let(:job_grpc) do
    operation_pending_grpc ops_name, "type.googleapis.com/google.bigtable.admin.v2.CreateClusterMetadata"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.CreateClusterMetadata",
      Google::Cloud::Bigtable::Admin::V2::CreateClusterMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.Cluster",
      cluster_grpc
    )
  end

  it "creates a cluster" do
    mock = Minitest::Mock.new
    cluster = Google::Cloud::Bigtable::Admin::V2::Cluster.new(
      serve_nodes: 3, location: location_path(location_id), default_storage_type: :SSD
    )

    mock.expect :create_cluster, operation_grpc(job_grpc, mock), [
      parent: instance_path(instance_id),
      cluster_id: cluster_id,
      cluster: cluster
    ]
    mock.expect :get_operation, operation_grpc(job_done_grpc, mock), [{name: ops_name}, Gapic::CallOptions]
    bigtable.service.mocked_instances = mock

    instance_grpc = Google::Cloud::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
    instance = Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
    job = instance.create_cluster(cluster_id, location_id, nodes: 3, storage_type: :SSD)

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

  def operation_grpc longrunning_grpc, mock
    Gapic::Operation.new(
      longrunning_grpc,
      mock,
      result_type: Google::Cloud::Bigtable::Admin::V2::Cluster,
      metadata_type: Google::Cloud::Bigtable::Admin::V2::CreateClusterMetadata
    )
  end
end
