# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Pubsub::Subscription, :policy, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Gcloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.connection, pubsub.service }

  it "gets the IAM Policy" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }.to_json

    get_req = Google::Iam::V1::GetIamPolicyRequest.new(
      resource: "projects/#{project}/subscriptions/#{sub_name}"
    )
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [get_req]
    subscription.service.mocked_iam = mock

    policy = subscription.policy

    mock.verify

    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "memoizes policy" do
    policy_hash = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }

    subscription.instance_variable_set "@policy", policy_hash

    # No mocks, no errors, no HTTP calls are made
    policy = subscription.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "makes API calls when forced, even if already memoized" do
    policy_hash = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }

    policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ],
      }]
    }.to_json

    get_req = Google::Iam::V1::GetIamPolicyRequest.new(
      resource: "projects/#{project}/subscriptions/#{sub_name}"
    )
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [get_req]
    subscription.service.mocked_iam = mock

    subscription.instance_variable_set "@policy", policy_hash
    returned_policy = subscription.policy
    returned_policy.must_be_kind_of Hash
    returned_policy["bindings"].count.must_equal 1
    returned_policy["bindings"].first["role"].must_equal "roles/viewer"
    returned_policy["bindings"].first["members"].count.must_equal 2
    returned_policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    returned_policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"

    policy = subscription.policy force: true

    mock.verify

    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/owner"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:owner@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    new_policy = {
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ],
      }],
    }

    set_req = Google::Iam::V1::SetIamPolicyRequest.new(
      resource: "projects/#{project}/subscriptions/#{sub_name}",
      policy: Google::Iam::V1::Policy.decode_json(JSON.dump(new_policy))
    )
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock = Minitest::Mock.new
    mock.expect :set_iam_policy, set_res, [set_req]
    subscription.service.mocked_iam = mock

    subscription.policy = new_policy

    mock.verify

    # Setting the policy also memoizes the policy
    subscription.policy["bindings"].count.must_equal 1
    subscription.policy["bindings"].first["role"].must_equal "roles/owner"
    subscription.policy["bindings"].first["members"].count.must_equal 2
    subscription.policy["bindings"].first["members"].first.must_equal "user:owner@example.com"
    subscription.policy["bindings"].first["members"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
  end

  it "tests the available permissions" do
    test_req = Google::Iam::V1::TestIamPermissionsRequest.new(
      resource: "projects/#{project}/subscriptions/#{sub_name}",
      permissions: ["pubsub.subscriptions.get", "pubsub.subscriptions.consume"]
    )
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["pubsub.subscriptions.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [test_req]
    subscription.service.mocked_iam = mock

    permissions = subscription.test_permissions "pubsub.subscriptions.get",
                                                "pubsub.subscriptions.consume"

    mock.verify

    permissions.must_equal ["pubsub.subscriptions.get"]
  end
end
