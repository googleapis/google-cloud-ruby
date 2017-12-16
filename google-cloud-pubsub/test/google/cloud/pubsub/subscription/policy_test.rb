# Copyright 2015 Google LLC
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

describe Google::Cloud::Pubsub::Subscription, :policy, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:sub_name) { "subscription-name-goes-here" }
  let(:sub_json) { subscription_json topic_name, sub_name }
  let(:sub_hash) { JSON.parse sub_json }
  let(:sub_grpc) { Google::Pubsub::V1::Subscription.decode_json(sub_json) }
  let(:subscription) { Google::Cloud::Pubsub::Subscription.from_grpc sub_grpc, pubsub.service }

  it "gets the IAM Policy" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ]
      }]
    }.to_json
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [subscription_path(sub_name), options: default_options]
    subscription.service.mocked_subscriber = mock

    policy = subscription.policy

    mock.verify

    policy.must_be_kind_of Google::Cloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be_kind_of Array
    policy.roles["roles/viewer"].count.must_equal 2
    policy.roles["roles/viewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/viewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ]
      }]
    }.to_json
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [subscription_path(sub_name), options: default_options]

    new_policy = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }

    policy = Google::Iam::V1::Policy.decode_json(JSON.dump(new_policy))
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock.expect :set_iam_policy, set_res, [subscription_path(sub_name), policy, options: default_options]
    subscription.service.mocked_subscriber = mock

    policy = subscription.policy

    policy.add "roles/owner", "user:newowner@example.com"
    policy.remove "roles/owner", "user:owner@example.com"

    policy_2 = subscription.policy = policy

    mock.verify

    policy_2.must_be_kind_of Google::Cloud::Pubsub::Policy
    policy_2.roles.must_be_kind_of Hash
    policy_2.roles.size.must_equal 1
    policy_2.roles["roles/viewer"].must_be :nil?
    policy_2.roles["roles/owner"].must_be_kind_of Array
    policy_2.roles["roles/owner"].count.must_equal 2
    policy_2.roles["roles/owner"].first.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    policy_2.roles["roles/owner"].last.must_equal "user:newowner@example.com"
  end

  it "sets the IAM Policy in a block" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ]
      }]
    }.to_json
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [subscription_path(sub_name), options: default_options]

    new_policy = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }

    policy = Google::Iam::V1::Policy.decode_json(JSON.dump(new_policy))
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock.expect :set_iam_policy, set_res, [subscription_path(sub_name), policy, options: default_options]
    subscription.service.mocked_subscriber = mock

    policy = subscription.policy do |p|
      p.add "roles/owner", "user:newowner@example.com"
      p.remove "roles/owner", "user:owner@example.com"
    end

    mock.verify

    policy.must_be_kind_of Google::Cloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be :nil?
    policy.roles["roles/owner"].must_be_kind_of Array
    policy.roles["roles/owner"].count.must_equal 2
    policy.roles["roles/owner"].first.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    policy.roles["roles/owner"].last.must_equal "user:newowner@example.com"
  end

  it "tests the available permissions" do
    permissions = ["pubsub.subscriptions.get", "pubsub.subscriptions.consume"]
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["pubsub.subscriptions.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [subscription_path(sub_name), permissions, options: default_options]
    subscription.service.mocked_subscriber = mock

    permissions = subscription.test_permissions "pubsub.subscriptions.get",
                                                "pubsub.subscriptions.consume"

    mock.verify

    permissions.must_equal ["pubsub.subscriptions.get"]
  end
end
