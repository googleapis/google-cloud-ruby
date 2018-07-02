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

describe Google::Cloud::Bigtable::AppProfile, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:app_profile_id) { "test-app-profile" }

  it "knows the identifiers" do
    description = "Test instance app profile"
    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    app_profile_grpc = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: description,
      multi_cluster_routing_use_any: routing_policy
    )

    app_profile = Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)

    app_profile.must_be_kind_of Google::Cloud::Bigtable::AppProfile
    app_profile.project_id.must_equal project_id
    app_profile.instance_id.must_equal instance_id
    app_profile.name.must_equal app_profile_id
    app_profile.path.must_equal app_profile_path(instance_id, app_profile_id)
    app_profile.description.must_equal description
    app_profile.multi_cluster_routing.must_equal routing_policy
    app_profile.routing_policy.must_equal routing_policy
    app_profile.single_cluster_routing.must_be :nil?
  end

  it "set multi_cluster_routing policy" do
    app_profile_grpc = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id)
    )
    app_profile = Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)

    app_profile.routing_policy.must_be :nil?

    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    app_profile.routing_policy = routing_policy

    app_profile.routing_policy.must_be_kind_of Google::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny
    app_profile.routing_policy.must_equal routing_policy
  end

  it "set single_cluster_routing policy" do
    app_profile_grpc = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id)
    )
    app_profile = Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)

    app_profile.routing_policy.must_be :nil?

    routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      "test-cluster",
      allow_transactional_writes: true
    )
    app_profile.routing_policy = routing_policy

    app_profile.routing_policy.must_be_kind_of Google::Bigtable::Admin::V2::AppProfile::SingleClusterRouting
    app_profile.routing_policy.must_equal routing_policy
  end
end
