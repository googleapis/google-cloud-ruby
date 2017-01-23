# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Spanner::Project, :create_instance, :mock_spanner do
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"google.spanner.admin.instance.v1.CreateInstanceMetadata\",\"value\":\"\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }
  let(:config) { instance_config_hash[:name] }

  it "creates an empty instance" do
    instance_id = "new-instance"

    create_req = Google::Spanner::Admin::Instance::V1::Instance.new config: config
    create_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Instance::V1::Instance,
                   Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata
                 )
    mock = Minitest::Mock.new
    mock.expect :create_instance, create_res, [project_path, instance_id, create_req]
    spanner.service.mocked_instances = mock

    job = spanner.create_instance instance_id, config: config

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Instance::Job
    job.wont_be :done?
  end

  it "creates a full instance and labels with symbols" do
    instance_id = "new-instance"

    create_req = Google::Spanner::Admin::Instance::V1::Instance.new(config: config,
      display_name: "My New Instance", node_count: 99, labels: { "env" => "production" }
    )
    create_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Instance::V1::Instance,
                   Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata
                 )
    mock = Minitest::Mock.new
    mock.expect :create_instance, create_res, [project_path, instance_id, create_req]
    spanner.service.mocked_instances = mock

    job = spanner.create_instance instance_id, config: config, name: "My New Instance", nodes: 99, labels: { env: :production }

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Instance::Job
    job.wont_be :done?
  end
end
