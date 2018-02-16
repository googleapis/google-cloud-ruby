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

describe Google::Cloud::Spanner::Instance, :iam, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:instance_json) { instance_hash(name: instance_id).to_json }
  let(:instance_grpc) { Google::Spanner::Admin::Instance::V1::Instance.decode_json instance_json }
  let(:instance) { Google::Cloud::Spanner::Instance.from_grpc instance_grpc, spanner.service }
  let(:viewer_policy_json) do
    {
      etag: "CAE=",
      bindings: [{
        role: "roles/viewer",
        members: [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }.to_json
  end
  let(:owner_policy_json) do
    {
      etag: "CAE=",
      bindings: [{
        role: "roles/owner",
        members: [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
         ]
      }]
    }.to_json
  end

  it "gets the IAM Policy" do
    get_res = Google::Iam::V1::Policy.decode_json viewer_policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [instance.path]
    instance.service.mocked_instances = mock

    policy = instance.policy

    mock.verify

    policy.must_be_kind_of Google::Cloud::Spanner::Policy
    policy.etag.must_equal "\b\x01"
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be_kind_of Array
    policy.roles["roles/viewer"].count.must_equal 2
    policy.roles["roles/viewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/viewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    get_res = Google::Iam::V1::Policy.decode_json owner_policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [instance.path]

    updated_policy_hash = JSON.parse owner_policy_json
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json updated_policy_hash.to_json
    set_res = Google::Iam::V1::Policy.decode_json updated_policy_hash.merge(etag: "CBD=").to_json
    mock.expect :set_iam_policy, set_res, [instance.path, set_req]
    instance.service.mocked_instances = mock

    policy = instance.policy

    policy.add "roles/owner", "user:newowner@example.com"
    policy.remove "roles/owner", "user:owner@example.com"

    policy = instance.update_policy policy

    mock.verify

    policy.must_be_kind_of Google::Cloud::Spanner::Policy
    policy.etag.must_equal "\b\x10"
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be :nil?
    policy.roles["roles/owner"].must_be_kind_of Array
    policy.roles["roles/owner"].count.must_equal 2
    policy.roles["roles/owner"].first.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    policy.roles["roles/owner"].last.must_equal  "user:newowner@example.com"
  end

  it "sets the IAM Policy in a block" do

    get_res = Google::Iam::V1::Policy.decode_json owner_policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [instance.path]

    updated_policy_hash = JSON.parse owner_policy_json
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json updated_policy_hash.to_json
    set_res = Google::Iam::V1::Policy.decode_json updated_policy_hash.merge(etag: "CBD=").to_json
    mock.expect :set_iam_policy, set_res, [instance.path, set_req]
    instance.service.mocked_instances = mock

    policy = instance.policy do |p|
      p.add "roles/owner", "user:newowner@example.com"
      p.remove "roles/owner", "user:owner@example.com"
    end

    mock.verify

    policy.must_be_kind_of Google::Cloud::Spanner::Policy
    policy.etag.must_equal "\b\x10"
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be :nil?
    policy.roles["roles/owner"].must_be_kind_of Array
    policy.roles["roles/owner"].count.must_equal 2
    policy.roles["roles/owner"].first.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    policy.roles["roles/owner"].last.must_equal  "user:newowner@example.com"
  end

  it "tests the available permissions" do
    permissions = ["spanner.instances.get", "spanner.instances.publish"]
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["spanner.instances.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [instance.path, permissions]
    instance.service.mocked_instances = mock

    permissions = instance.test_permissions "spanner.instances.get",
                                            "spanner.instances.publish"

    mock.verify

    permissions.must_equal ["spanner.instances.get"]
  end
end
