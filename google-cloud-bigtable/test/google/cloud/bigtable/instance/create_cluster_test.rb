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
  let(:ops_name) {
    "operations/projects/#{project_id}/instances/#{instance_id}/clusters/#{cluster_id}/locations/us-east-1b/operations/1234567890"
  }
  let(:cluster_grpc){
    Google::Bigtable::Admin::V2::Cluster.new(
      cluster_hash(
        name: cluster_id,
        nodes: 3,
        location: location_id,
        storage_type: :SSD,
        state: :READY
      )
    )
  }
  let(:job_data) {
    {
      name: ops_name,
      metadata: {
        type_url: "type.googleapis.com/google.bigtable.admin.v2.CreateClusterMetadata",
        value: ""
      }
    }
  }
  let(:job_grpc) { Google::Longrunning::Operation.new(job_data) }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.CreateClusterMetadata",
        value: Google::Bigtable::Admin::V2::CreateClusterMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.Cluster",
        value: cluster_grpc.to_proto
      )
    )
  end

  it "creates a cluster" do
    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Cluster,
      Google::Bigtable::Admin::V2::CreateClusterMetadata
    )

    cluster = Google::Bigtable::Admin::V2::Cluster.new(
      serve_nodes: 3, location: location_path(location_id), default_storage_type: :SSD
    )

    mock.expect :create_cluster, create_res, [
      instance_path(instance_id),
      cluster_id,
      cluster
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    instance_grpc = Google::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
    instance = Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
    job = instance.create_cluster(cluster_id, location_id, nodes: 3, storage_type: :SSD)

    job.must_be_kind_of Google::Cloud::Bigtable::Cluster::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.cluster.must_be :nil?

    job.reload!
    cluster = job.cluster

    cluster.wont_be :nil?
    cluster.must_be_kind_of Google::Cloud::Bigtable::Cluster

    mock.verify
  end
end
