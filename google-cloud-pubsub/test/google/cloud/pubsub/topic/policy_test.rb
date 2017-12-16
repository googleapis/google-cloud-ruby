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

describe Google::Cloud::Pubsub::Topic, :policy, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Google::Cloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
                                                pubsub.service }

  it "gets the IAM Policy" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings"=>[{
        "role"=>"roles/viewer",
        "members"=>[
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }.to_json
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [topic_path(topic_name), options: default_options]
    topic.service.mocked_publisher = mock

    policy = topic.policy

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
    mock.expect :get_iam_policy, get_res, [topic_path(topic_name), options: default_options]

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
    mock.expect :set_iam_policy, set_res, [topic_path(topic_name), policy, options: default_options]
    topic.service.mocked_publisher = mock

    policy = topic.policy

    policy.add "roles/owner", "user:newowner@example.com"
    policy.remove "roles/owner", "user:owner@example.com"

    policy_2 = topic.policy = policy

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
    mock.expect :get_iam_policy, get_res, [topic_path(topic_name), options: default_options]

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
    mock.expect :set_iam_policy, set_res, [topic_path(topic_name), policy, options: default_options]
    topic.service.mocked_publisher = mock

    policy = topic.policy do |p|
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
    permissions = ["pubsub.topics.get", "pubsub.topics.publish"]
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["pubsub.topics.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [topic_path(topic_name), permissions, options: default_options]
    topic.service.mocked_publisher = mock

    permissions = topic.test_permissions "pubsub.topics.get",
                                         "pubsub.topics.publish"

    mock.verify

    permissions.must_equal ["pubsub.topics.get"]
  end
end
