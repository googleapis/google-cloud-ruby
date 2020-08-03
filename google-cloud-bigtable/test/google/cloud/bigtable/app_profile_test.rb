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
  let(:description) { "Test instance app profile" }
  let(:routing_policy_grpc) { multi_cluster_routing_grpc }
  let(:app_profile_grpc) do
    Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: description,
      multi_cluster_routing_use_any: routing_policy_grpc
    )
  end
  let(:app_profile) { Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service) }

  it "knows the identifiers" do
    _(app_profile).must_be_kind_of Google::Cloud::Bigtable::AppProfile
    _(app_profile.project_id).must_equal project_id
    _(app_profile.instance_id).must_equal instance_id
    _(app_profile.name).must_equal app_profile_id
    _(app_profile.path).must_equal app_profile_path(instance_id, app_profile_id)
    _(app_profile.description).must_equal description
    _(app_profile.multi_cluster_routing.to_grpc).must_equal routing_policy_grpc
    _(app_profile.routing_policy.to_grpc).must_equal routing_policy_grpc
    _(app_profile.single_cluster_routing).must_be :nil?
  end

  it "set multi_cluster_routing policy" do
    app_profile_grpc = Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id)
    )
    app_profile = Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)

    _(app_profile.routing_policy).must_be :nil?

    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    app_profile.routing_policy = routing_policy

    _(app_profile.routing_policy).must_be_kind_of Google::Cloud::Bigtable::MultiClusterRoutingUseAny
    _(app_profile.routing_policy.to_grpc).must_equal routing_policy.to_grpc
  end

  it "set single_cluster_routing policy" do
    app_profile_grpc = Google::Cloud::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id)
    )
    app_profile = Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)

    _(app_profile.routing_policy).must_be :nil?

    routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      "test-cluster",
      allow_transactional_writes: true
    )
    app_profile.routing_policy = routing_policy

    _(app_profile.routing_policy).must_be_kind_of Google::Cloud::Bigtable::SingleClusterRouting
    _(app_profile.routing_policy.to_grpc).must_equal routing_policy.to_grpc
  end

  it "reloads its state" do
    mock = Minitest::Mock.new
    mock.expect :get_app_profile, app_profile_grpc, [name: app_profile_path(instance_id, app_profile_id)]
    app_profile.service.mocked_instances = mock

    app_profile.reload!

    mock.verify

    _(app_profile.project_id).must_equal project_id
    _(app_profile.instance_id).must_equal instance_id
    _(app_profile.name).must_equal app_profile_id
    _(app_profile.path).must_equal app_profile_path(instance_id, app_profile_id)
  end
end
