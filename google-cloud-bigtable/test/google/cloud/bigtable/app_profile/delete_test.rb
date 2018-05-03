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

describe Google::Cloud::Bigtable::AppProfile, :delete, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:app_profile_id) { "test-app-profile" }
  let(:app_profile_grpc) {
    Google::Bigtable::Admin::V2::AppProfile.new(
      name: app_profile_path(instance_id, app_profile_id),
      description: "Test instance app profile",
      multi_cluster_routing_use_any: Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
    )
  }
  let(:app_profile) {
    Google::Cloud::Bigtable::AppProfile.from_grpc(app_profile_grpc, bigtable.service)
  }

  it "can delete itself and do not ignore warnings" do
    ignore_warnings = false
    mock = Minitest::Mock.new
    mock.expect :delete_app_profile, true, [app_profile_grpc.name, ignore_warnings]
    bigtable.service.mocked_instances = mock

    result = app_profile.delete
    result.must_equal true
    mock.verify
  end

  it "can delete itself and ignore warnings" do
    ignore_warnings = true

    mock = Minitest::Mock.new
    mock.expect :delete_app_profile, true, [app_profile_grpc.name, ignore_warnings]
    bigtable.service.mocked_instances = mock

    result = app_profile.delete(ignore_warnings: ignore_warnings)
    result.must_equal true
    mock.verify
  end
end
