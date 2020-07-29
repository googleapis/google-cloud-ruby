# Copyright 2019 Google LLC
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

describe Google::Cloud::Bigtable::Instance, :create_app_profile, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:app_profile_id) { "test-app-profile" }
  let(:path) { app_profile_path(instance_id, app_profile_id) }
  let(:description) { "Test instance app profile" }
  let(:app_profile_resp) {
    Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      name: path,
      description: description,
      multi_cluster_routing_use_any: multi_cluster_routing_grpc
    )
  }

  it "creates a app_profile" do
    mock = Minitest::Mock.new
    app_profile_req = app_profile_resp.dup
    app_profile_req.name = ""
    mock.expect :create_app_profile,
                app_profile_resp,
                [
                  parent: instance_path(instance_id),
                  app_profile_id: app_profile_id,
                  app_profile: app_profile_req,
                  ignore_warnings: false
                ]
    bigtable.service.mocked_instances = mock

    instance_grpc = Google::Cloud::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
    instance = Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)

    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    app_profile = instance.create_app_profile app_profile_id, routing_policy, description: description

    _(app_profile).wont_be :nil?
    _(app_profile).must_be_kind_of Google::Cloud::Bigtable::AppProfile
    _(app_profile.path).must_equal path
    _(app_profile.description).must_equal description
    _(app_profile.routing_policy).must_be_kind_of Google::Cloud::Bigtable::MultiClusterRoutingUseAny

    mock.verify
  end
end
