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

describe Google::Cloud::Bigtable::Instance, :save, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:display_name) { "Test instance" }
  let(:labels) { { "env" => "test" } }
  let(:ops_name) {
    "operations/1234567890"
  }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(
      instance_hash(
        name: instance_id,
        display_name: display_name,
        state: :READY,
        type: :DEVELOPMENT,
        labels: labels
      )
    )
  }
  let(:instance) { Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service) }
  let(:job_data) {
    {
      name: ops_name,
      metadata: {
        type_url: "type.googleapis.com/google.bigtable.admin.v2.UpdateInstanceMetadata",
        value: ""
      }
    }
  }
  let(:job_grpc) { Google::Longrunning::Operation.new(job_data) }
  let(:job_grpc_done) do
    Google::Longrunning::Operation.new(
      name: ops_name,
      metadata: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.UpdateInstanceMetadata",
        value: Google::Bigtable::Admin::V2::UpdateInstanceMetadata.new.to_proto
      ),
      done: true,
      response: Google::Protobuf::Any.new(
        type_url: "type.googleapis.com/google.bigtable.admin.v2.Instance",
        value: instance_grpc.to_proto
      )
    )
  end

  it "updates and saves itself" do
    instance.display_name = "Updated display name"
    instance.type = :PRODUCTION
    instance.labels = { "env" => "production" }

    mock = Minitest::Mock.new
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   mock,
                   Google::Bigtable::Admin::V2::Instance,
                   Google::Bigtable::Admin::V2::UpdateInstanceMetadata
                 )
    mask = Google::Protobuf::FieldMask.new(paths: %w[labels display_name type])
    mock.expect :partial_update_instance, update_res, [instance_grpc, mask]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = instance.save

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

  it "updates and saves when changing the labels directly" do
    instance.display_name = "Updated display name"
    instance.labels["env"] = "production"

    mock = Minitest::Mock.new
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   mock,
                   Google::Bigtable::Admin::V2::Instance,
                   Google::Bigtable::Admin::V2::UpdateInstanceMetadata
                 )
    mask = Google::Protobuf::FieldMask.new(paths: %w[labels display_name type])
    mock.expect :partial_update_instance, update_res, [instance_grpc, mask]
    mock.expect :get_operation, job_grpc_done, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = instance.save

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
