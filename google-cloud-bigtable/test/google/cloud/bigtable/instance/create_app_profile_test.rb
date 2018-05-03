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

describe Google::Cloud::Bigtable::Instance, :create_app_profile, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }
  let(:app_profile_id) { "new-app-profile" }
  let(:description) { "Test app profile" }

  it "creates an app profile with single cluster routing policy" do
    routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      "test-cluster",
      allow_transactional_writes: true
    )

    create_res = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: description,
      single_cluster_routing: routing_policy
    )

    app_profile = Google::Bigtable::Admin::V2::AppProfile.new(
      description: description,
      single_cluster_routing: routing_policy
    )

    mock = Minitest::Mock.new
    mock.expect :create_app_profile, create_res, [
      instance_path(instance_id),
      app_profile_id,
      app_profile,
      ignore_warnings: true
    ]
    bigtable.service.mocked_instances = mock

    app_profile = instance.create_app_profile(
      app_profile_id,
      routing_policy,
      description: description,
      ignore_warnings: true
    )

    mock.verify

    app_profile.project_id.must_equal project_id
    app_profile.instance_id.must_equal instance_id
    app_profile.name.must_equal app_profile_id
    app_profile.path.must_equal app_profile_path(instance_id, app_profile_id)
    app_profile.description.must_equal description
    app_profile.single_cluster_routing.must_equal routing_policy
    app_profile.routing_policy.must_equal routing_policy
  end

  it "creates an app profile with multi cluster routing policy" do
    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    create_res = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: description,
      multi_cluster_routing_use_any: routing_policy
    )

    app_profile = Google::Bigtable::Admin::V2::AppProfile.new(
      description: description,
      multi_cluster_routing_use_any: routing_policy
    )

    mock = Minitest::Mock.new
    mock.expect :create_app_profile, create_res, [
      instance_path(instance_id),
      app_profile_id,
      app_profile,
      ignore_warnings: false
    ]
    bigtable.service.mocked_instances = mock

    app_profile = instance.create_app_profile(
      app_profile_id,
      routing_policy,
      description: description
    )

    mock.verify

    app_profile.project_id.must_equal project_id
    app_profile.instance_id.must_equal instance_id
    app_profile.name.must_equal app_profile_id
    app_profile.path.must_equal app_profile_path(instance_id, app_profile_id)
    app_profile.description.must_equal description
    app_profile.multi_cluster_routing.must_equal routing_policy
    app_profile.routing_policy.must_equal routing_policy
  end
end
