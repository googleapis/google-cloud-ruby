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
  let(:instance_grpc) { Google::Cloud::Spanner::Admin::Instance::V1::Instance.new instance_hash(name: instance_id) }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:job_grpc) do
    Google::Longrunning::Operation.new(
      name: "1234567890",
      metadata: {
        type_url: "google.spanner.admin.database.v1.UpdateDatabaseDdlRequest",
        value: ""
      }
    )
  end

  it "updates and saves itself" do
    instance.display_name = "Updated display name"
    instance.nodes = 99
    instance.labels = { "env" => "production" }

    update_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Instance::V1::Instance,
        metadata_type: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata
      )
    mask = Google::Protobuf::FieldMask.new paths: ["display_name", "node_count", "labels"]
    mock = Minitest::Mock.new
    mock.expect :update_instance, update_res, [{ instance: instance_grpc, field_mask: mask }, nil]
    spanner.service.mocked_instances = mock

    job = instance.save

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Instance::Job
    _(job).wont_be :done?
  end

  it "updates and saves when changing the labels directly" do
    instance.display_name = "Updated display name"
    instance.nodes = 99
    instance.labels["env"] = "production"

    update_res = \
      Gapic::Operation.new(
        job_grpc, Object.new,
        result_type: Google::Cloud::Spanner::Admin::Instance::V1::Instance,
        metadata_type: Google::Cloud::Spanner::Admin::Instance::V1::CreateInstanceMetadata
      )
    mask = Google::Protobuf::FieldMask.new paths: ["display_name", "node_count", "labels"]
    mock = Minitest::Mock.new
    mock.expect :update_instance, update_res, [{ instance: instance_grpc, field_mask: mask }, nil]
    spanner.service.mocked_instances = mock

    job = instance.save

    mock.verify

    _(job).must_be_kind_of Google::Cloud::Spanner::Instance::Job
    _(job).wont_be :done?
  end
end
