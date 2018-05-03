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

describe Google::Cloud::Bigtable::Project, :create_instance, :mock_bigtable do
  let(:instance_id) { "new-instance" }
  let(:display_name) { "Test instance" }
  let(:labels) { { "env" => "test" } }
  let(:ops_name) {
    "operations/projects/#{project_id}/instances/#{instance_id}/locations/us-east-1b/operations/1234567890"
  }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(
      name: instance_path(instance_id),
      display_name: display_name,
      state: :READY,
      type: :PRODUCTION,
      labels: labels
    )
  }
  let(:job_data) {
    {
      "name": ops_name,
      "metadata": {
        "type_url": "type.googleapis.com/google.bigtable.admin.v2.CreateInstanceMetadata",
        "value": ""
      }
    }
  }
  let(:job_grpc) { Google::Longrunning::Operation.new(job_data) }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.CreateInstanceMetadata",
        value: Google::Bigtable::Admin::V2::CreateInstanceMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.Instance",
        value: instance_grpc.to_proto
      )
    )
  end

  it "creates an empty instance" do
    instance = Google::Bigtable::Admin::V2::Instance.new(
      instance_hash(display_name: display_name)
    )
    clusters_map = Google::Cloud::Bigtable::Instance::ClusterMap.new.tap do |c|
      c.add("test-cluster", location_path("us-east1-b"), nodes: 1)
    end

    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Instance,
      Google::Bigtable::Admin::V2::CreateInstanceMetadata
    )

    mock.expect :create_instance, create_res, [
      project_path, instance_id, instance, clusters_map
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = bigtable.create_instance(
      instance_id,
      display_name: display_name
    ) do |clusters|
      clusters.add("test-cluster", "us-east1-b", nodes: 1)
    end

    job.must_be_kind_of Google::Cloud::Bigtable::Instance::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.instance.must_be :nil?

    job.reload!
    instance = job.instance

    instance.wont_be :nil?
    instance.must_be_kind_of Google::Cloud::Bigtable::Instance

    mock.verify
  end

  it "creates a full instance with labels and multiple clusters" do
    type = :PRODUCTION
    new_instance_fields = instance_hash(
      display_name: display_name,
      type: type,
      labels: labels
    )
    instance = Google::Bigtable::Admin::V2::Instance.new(new_instance_fields)
    clusters_map = Google::Cloud::Bigtable::Instance::ClusterMap.new.tap do |c|
      c.add("test-cluster-1", location_path("us-east1-b"), nodes: 3, storage_type: :SSD)
      c.add("test-cluster-2", location_path("us-east1-b"), nodes: 3, storage_type: :SSD)
    end

    mock = Minitest::Mock.new
    create_res = Google::Gax::Operation.new(
      job_grpc,
      mock,
      Google::Bigtable::Admin::V2::Instance,
      Google::Bigtable::Admin::V2::CreateInstanceMetadata
    )

    mock.expect :create_instance, create_res, [
      project_path, instance_id, instance, clusters_map
    ]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = bigtable.create_instance(
      instance_id,
      display_name: display_name,
      type: type,
      labels: labels
    ) do |clusters|
      clusters.add("test-cluster-1", "us-east1-b", nodes: 3, storage_type: :SSD)
      clusters.add("test-cluster-2", "us-east1-b", nodes: 3, storage_type: :SSD)
    end

    job.must_be_kind_of Google::Cloud::Bigtable::Instance::Job
    job.wont_be :done?
    job.wont_be :error?
    job.error.must_be :nil?
    job.instance.must_be :nil?

    job.reload!
    instance = job.instance

    instance.wont_be :nil?
    instance.must_be_kind_of Google::Cloud::Bigtable::Instance

    mock.verify
  end
end
