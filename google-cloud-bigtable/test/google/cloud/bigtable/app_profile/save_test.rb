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

describe Google::Cloud::Bigtable::AppProfile, :save, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:app_profile_id) { "test-app-profile" }
  let(:app_profile_grpc) {
    Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: "Test instance app profile",
      multi_cluster_routing_use_any: multi_cluster_routing_grpc
    )
  }
  let(:app_profile) {
    Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)
  }
  let(:ops_name) { "operations/1234567890" }
  let(:job_grpc) do
    operation_pending_grpc ops_name, "type.googleapis.com/google.protobuf.Any"
  end
  let :job_done_grpc do
    operation_done_grpc(
      ops_name,
      "type.googleapis.com/google.bigtable.admin.v2.UpdateAppProfileMetadata",
      Google::Bigtable::Admin::V2::UpdateAppProfileMetadata.new,
      "type.googleapis.com/google.bigtable.admin.v2.AppProfile",
      app_profile_grpc
    )
  end

  it "updates with single cluster routing_policy" do
    app_profile.description = "User data instance app profile"
    app_profile.routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      "test-cluster",
      allow_transactional_writes: false
    )

    mock = Minitest::Mock.new
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   mock,
                   Google::Bigtable::Admin::V2::AppProfile,
                   Google::Bigtable::Admin::V2::UpdateAppProfileMetadata
                 )
    update_mask =   Google::Protobuf::FieldMask.new(
      paths: ["description", "single_cluster_routing"]
    )
    mock.expect :update_app_profile, update_res, [
      app_profile_grpc,
      update_mask,
      ignore_warnings: false
    ]
    mock.expect :get_operation, job_done_grpc, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = app_profile.save

    _(job).must_be_kind_of Google::Cloud::Bigtable::AppProfile::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.app_profile).must_be :nil?

    job.reload!
    app_profile = job.app_profile

    _(app_profile).wont_be :nil?
    _(app_profile).must_be_kind_of Google::Cloud::Bigtable::AppProfile

    mock.verify
  end

  it "updates with multi cluster routing_policy" do
    app_profile.description = "User data instance app profile"
    app_profile.routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing

    mock = Minitest::Mock.new
    update_res = Google::Gax::Operation.new(
                   job_grpc,
                   mock,
                   Google::Bigtable::Admin::V2::AppProfile,
                   Google::Bigtable::Admin::V2::UpdateAppProfileMetadata
                 )
    update_mask =   Google::Protobuf::FieldMask.new(
      paths: ["description", "multi_cluster_routing_use_any"]
    )
    mock.expect :update_app_profile, update_res, [
      app_profile_grpc,
      update_mask,
      ignore_warnings: true
    ]
    mock.expect :get_operation, job_done_grpc, [ops_name, Hash]
    bigtable.service.mocked_instances = mock

    job = app_profile.save(ignore_warnings: true)

    _(job).must_be_kind_of Google::Cloud::Bigtable::AppProfile::Job
    _(job).wont_be :done?
    _(job).wont_be :error?
    _(job.error).must_be :nil?
    _(job.app_profile).must_be :nil?

    job.reload!
    app_profile = job.app_profile

    _(app_profile).wont_be :nil?
    _(app_profile).must_be_kind_of Google::Cloud::Bigtable::AppProfile

    mock.verify
  end
end
