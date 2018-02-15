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

describe Google::Cloud::Spanner::Instance, :save, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_json) { instance_hash(name: instance_id).to_json }
  let(:instance_grpc) { Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_json }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:job_json) { "{\"name\":\"1234567890\",\"metadata\":{\"typeUrl\":\"google.spanner.admin.instance.v1.CreateInstanceMetadata\",\"value\":\"\"}}" }
  let(:job_grpc) { Google::Longrunning::Operation.decode_json job_json }

  it "updates and saves itself" do
    instance.display_name = "Updated display name"
    instance.nodes = 99
    instance.labels = { "env" => "production" }

    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Instance::V1::Instance,
                   Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata
                 )
    mask = Google::Protobuf::FieldMask.new paths: ["display_name", "node_count", "labels"]
    mock = Minitest::Mock.new
    mock.expect :update_instance, update_res, [instance_grpc, mask]
    spanner.service.mocked_instances = mock

    job = instance.save

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Instance::Job
    job.wont_be :done?
  end

  it "updates and saves when changing the labels directly" do
    instance.display_name = "Updated display name"
    instance.nodes = 99
    instance.labels["env"] = "production"

    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   Object.new,
                   Google::Spanner::Admin::Instance::V1::Instance,
                   Google::Spanner::Admin::Instance::V1::CreateInstanceMetadata
                 )
    mask = Google::Protobuf::FieldMask.new paths: ["display_name", "node_count", "labels"]
    mock = Minitest::Mock.new
    mock.expect :update_instance, update_res, [instance_grpc, mask]
    spanner.service.mocked_instances = mock

    job = instance.save

    mock.verify

    job.must_be_kind_of Google::Cloud::Spanner::Instance::Job
    job.wont_be :done?
  end
end
