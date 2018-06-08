# frozen_string_literal: true

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

describe Google::Cloud::Bigtable::Instance, :app_profile, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:instance_grpc){
    Google::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }
  let(:description) { "Test app profile" }

  it "gets an app profile" do
    app_profile_id = "found-table"

    routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    get_res = Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: description,
      multi_cluster_routing_use_any: routing_policy
    )

    mock = Minitest::Mock.new
    mock.expect :get_app_profile, get_res, [app_profile_path(instance_id, app_profile_id)]
    bigtable.service.mocked_instances = mock
    app_profile = instance.app_profile(app_profile_id)

    mock.verify

    app_profile.project_id.must_equal project_id
    app_profile.instance_id.must_equal instance_id
    app_profile.name.must_equal app_profile_id
    app_profile.path.must_equal app_profile_path(instance_id, app_profile_id)
    app_profile.description.must_equal description
    app_profile.multi_cluster_routing.must_equal routing_policy
    app_profile.routing_policy.must_equal routing_policy
  end

  it "returns nil when getting an non-existent app profile" do
    not_found_app_profile_id = "not-found-app-profile"

    stub = Object.new
    def stub.get_app_profile *args
      gax_error = Google::Gax::GaxError.new "not found"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise gax_error
    end

    bigtable.service.mocked_instances = stub

    app_profile = instance.app_profile(not_found_app_profile_id)
    app_profile.must_be :nil?
  end
end
