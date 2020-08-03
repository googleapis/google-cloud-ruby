# Copyright 2015 Google LLC
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

describe Google::Cloud::PubSub::Topic, :policy, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::PubSub::Topic.from_grpc Google::Cloud::PubSub::V1::Topic.new(topic_hash(topic_name)), pubsub.service }

  it "gets the IAM Policy" do
    policy_hash = {
      "etag"=>"CAE=",
      "bindings"=>[{
        "role"=>"roles/viewer",
        "members"=>[
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }
    get_res = Google::Iam::V1::Policy.decode_json policy_hash.to_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: topic_path(topic_name)]
    topic.service.mocked_iam = mock

    policy = topic.policy

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::PubSub::Policy
    _(policy.etag).must_equal "\b\x01"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 2
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
    _(policy.roles["roles/viewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    policy_hash = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ]
      }]
    }
    get_res = Google::Iam::V1::Policy.decode_json policy_hash.to_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: topic_path(topic_name)]

    updated_policy = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }
    new_policy = {
      "etag"=>"CBD=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }

    set_req = Google::Iam::V1::Policy.decode_json JSON.dump(updated_policy)
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock.expect :set_iam_policy, set_res, [resource: topic_path(topic_name), policy: set_req]
    topic.service.mocked_iam = mock

    policy = topic.policy

    policy.add "roles/owner", "user:newowner@example.com"
    policy.remove "roles/owner", "user:owner@example.com"

    policy_2 = topic.update_policy policy

    mock.verify

    _(policy_2).must_be_kind_of Google::Cloud::PubSub::Policy
    _(policy_2.etag).must_equal "\b\x10"
    _(policy_2.roles).must_be_kind_of Hash
    _(policy_2.roles.size).must_equal 1
    _(policy_2.roles["roles/viewer"]).must_be :nil?
    _(policy_2.roles["roles/owner"]).must_be_kind_of Array
    _(policy_2.roles["roles/owner"].count).must_equal 2
    _(policy_2.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy_2.roles["roles/owner"].last).must_equal "user:newowner@example.com"
  end

  it "sets the IAM Policy in a block" do
    policy_hash = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ]
      }]
    }
    get_res = Google::Iam::V1::Policy.decode_json policy_hash.to_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: topic_path(topic_name)]

    updated_policy = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }
    new_policy = {
      "etag"=>"CBD=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "serviceAccount:0987654321@developer.gserviceaccount.com",
          "user:newowner@example.com"
        ]
      }]
    }

    set_req = Google::Iam::V1::Policy.decode_json JSON.dump(updated_policy)
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock.expect :set_iam_policy, set_res, [resource: topic_path(topic_name), policy: set_req]
    topic.service.mocked_iam = mock

    policy = topic.policy do |p|
      p.add "roles/owner", "user:newowner@example.com"
      p.remove "roles/owner", "user:owner@example.com"
    end

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::PubSub::Policy
    _(policy.etag).must_equal "\b\x10"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be :nil?
    _(policy.roles["roles/owner"]).must_be_kind_of Array
    _(policy.roles["roles/owner"].count).must_equal 2
    _(policy.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy.roles["roles/owner"].last).must_equal "user:newowner@example.com"
  end

  it "tests the available permissions" do
    permissions = ["pubsub.topics.get", "pubsub.topics.publish"]
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["pubsub.topics.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [resource: topic_path(topic_name), permissions: permissions]
    topic.service.mocked_iam = mock

    permissions = topic.test_permissions "pubsub.topics.get",
                                         "pubsub.topics.publish"

    mock.verify

    _(permissions).must_equal ["pubsub.topics.get"]
  end
end
