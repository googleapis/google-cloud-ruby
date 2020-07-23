# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Project, :create_instance, :mock_spanner do
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.UpdateDatabaseDdlRequest",
        value: ""
      }
    )
  end
  let(:config) { "regional-us-central1" }
  let(:instance_grpc) do
    Google::Cloud::Spanner::Admin::Instance::V1::Instance.new \
      name: "projects/bustling-kayak-91516/instances/my-new-instance",
      config: "projects/my-project/instanceConfigs/regional-us-central1",
      display_name: "My New Instance",
      node_count: 1,
      state: :READY,
      labels: {}
  end
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name:"1234567890",
      metadata: Google::Protobuf::Any.new(
        type_url: "google.spanner.admin.instance.v1.CreateInstanceMetadata",
        value: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.spanner.admin.instance.v1.Instance",
        value: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata.new.to_proto
      )
    )
  end

  it "creates an empty instance" do
    instance_id = "new-instance"

    mock = Minitest::Mock.new
    create_req = Google::Cloud::Spanner::Admin::Instance::V1::Instance.new config: instance_config_path(config)
    create_res = \
      Gapic::Operation.new(
        job_grpc, mock,
        result_type: Google::Cloud::Spanner::Admin::Instance::V1::Instance,
        metadata_type: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata
      )
    operation_done = \
      Gapic::Operation.new(
        job_grpc_done, mock,
        result_type: Google::Cloud::Spanner::Admin::Instance::V1::Instance,
        metadata_type: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata
    )
    mock.expect :create_instance, create_res, [parent: project_path, instance_id: instance_id, instance: create_req]
    mock.expect :get_operation, operation_done, [{name: "1234567890"}, Gapic::CallOptions]
    spanner.service.mocked_instances = mock

    job = spanner.create_instance instance_id, config: config

    _(job).must_be_kind_of Google::Cloud::Spanner::Instance::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.instance).must_be :nil?

    job.reload!
    instance = job.instance

    _(instance).wont_be :nil?
    _(instance).must_be_kind_of Google::Cloud::Spanner::Instance

    mock.verify
  end

  it "creates a full instance and labels with symbols" do
    instance_id = "new-instance"

    create_req = Google::Cloud::Spanner::Admin::Instance::V1::Instance.new(
      config: instance_config_path(config), display_name: "My New Instance",
      node_count: 99, labels: { "env" => "production" }
    )
    create_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Instance::V1::Instance,
        metadata_type: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata
      )
    mock = Minitest::Mock.new
    mock.expect :create_instance, create_res, [parent: project_path, instance_id: instance_id, instance: create_req]
    spanner.service.mocked_instances = mock

    job = spanner.create_instance instance_id, config: config, name: "My New Instance", nodes: 99, labels: { env: :production }

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Instance::Job
    _(job).wont_be :done?
  end
end
