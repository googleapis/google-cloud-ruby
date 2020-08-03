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

describe Google::Cloud::Bigtable::Instance, :app_profile, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:location_id) { "us-east-1b" }
  let(:instance_grpc){
    Google::Cloud::Bigtable::Admin::V2::Instance.new(name: instance_path(instance_id))
  }
  let(:instance) {
    Google::Cloud::Bigtable::Instance.from_grpc(instance_grpc, bigtable.service)
  }

  it "gets an app_profile" do
    app_profile_id = "found-app_profile"

    get_res = app_profile_grpc instance_id, app_profile_id

    mock = Minitest::Mock.new
    mock.expect :get_app_profile, get_res, [name: app_profile_path(instance_id, app_profile_id)]
    bigtable.service.mocked_instances = mock
    app_profile = instance.app_profile(app_profile_id)

    mock.verify

    _(app_profile.project_id).must_equal project_id
    _(app_profile.instance_id).must_equal instance_id
    _(app_profile.name).must_equal app_profile_id
    _(app_profile.path).must_equal app_profile_path(instance_id, app_profile_id)
  end

  it "returns nil when getting an non-existent app_profile" do
    not_found_app_profile_id = "not-found-app_profile"

    stub = Object.new
    def stub.get_app_profile *args
      raise Google::Cloud::NotFoundError.new("not found")
    end

    bigtable.service.mocked_instances = stub

    app_profile = instance.app_profile(not_found_app_profile_id)
    _(app_profile).must_be :nil?
  end
end
