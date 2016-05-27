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

describe Gcloud::Pubsub::Topic, :policy, :mock_pubsub do
  let(:topic_name) { "topic-name-goes-here" }
  let(:topic) { Gcloud::Pubsub::Topic.from_grpc Google::Pubsub::V1::Topic.decode_json(topic_json(topic_name)),
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

    get_req = Google::Iam::V1::GetIamPolicyRequest.new(
      resource: "projects/#{project}/topics/#{topic_name}"
    )
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [get_req]
    topic.service.mocked_iam = mock

    policy = topic.policy

    mock.verify

    policy.must_be_kind_of Gcloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be_kind_of Array
    policy.roles["roles/viewer"].count.must_equal 2
    policy.roles["roles/viewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/viewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "memoizes policy" do
    existing_policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }.to_json

    existing_policy = Gcloud::Pubsub::Policy.from_grpc Google::Iam::V1::Policy.decode_json(existing_policy_json)
    topic.instance_variable_set "@policy", existing_policy

    # No mocks, no errors, no HTTP calls are made
    policy = topic.policy
    policy.must_be_kind_of Gcloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be_kind_of Array
    policy.roles["roles/viewer"].count.must_equal 2
    policy.roles["roles/viewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/viewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "makes API calls when forced, even if already memoized" do
    existing_policy_json = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }.to_json

    policy_json = {
      "etag"=>"CAE=",
      "bindings"=>[{
        "role"=>"roles/owner",
        "members"=>[
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
         ]
      }]
    }.to_json

    get_req = Google::Iam::V1::GetIamPolicyRequest.new(
      resource: "projects/#{project}/topics/#{topic_name}"
    )
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [get_req]
    topic.service.mocked_iam = mock

    existing_policy = Gcloud::Pubsub::Policy.from_grpc Google::Iam::V1::Policy.decode_json(existing_policy_json)
    topic.instance_variable_set "@policy", existing_policy
    returned_policy = topic.policy
    returned_policy.must_be_kind_of Gcloud::Pubsub::Policy
    returned_policy.roles.must_be_kind_of Hash
    returned_policy.roles.size.must_equal 1
    returned_policy.roles["roles/viewer"].must_be_kind_of Array
    returned_policy.roles["roles/viewer"].count.must_equal 2
    returned_policy.roles["roles/viewer"].first.must_equal "user:viewer@example.com"
    returned_policy.roles["roles/viewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"

    policy = topic.policy force: true

    mock.verify

    policy.must_be_kind_of Gcloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be :nil?
    policy.roles["roles/owner"].must_be_kind_of Array
    policy.roles["roles/owner"].count.must_equal 2
    policy.roles["roles/owner"].first.must_equal "user:owner@example.com"
    policy.roles["roles/owner"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    policy_json = {
      "etag"=>"CAE=",
      "bindings"=>[]
    }.to_json

    get_req = Google::Iam::V1::GetIamPolicyRequest.new(
      resource: "projects/#{project}/topics/#{topic_name}"
    )
    get_res = Google::Iam::V1::Policy.decode_json policy_json
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [get_req]

    new_policy = {
      "etag"=>"CAE=",
      "bindings" => [{
        "role" => "roles/owner",
        "members" => [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
        ],
      }],
    }

    set_req = Google::Iam::V1::SetIamPolicyRequest.new(
      resource: "projects/#{project}/topics/#{topic_name}",
      policy: Google::Iam::V1::Policy.decode_json(JSON.dump(new_policy))
    )
    set_res = Google::Iam::V1::Policy.decode_json JSON.dump(new_policy)
    mock.expect :set_iam_policy, set_res, [set_req]
    topic.service.mocked_iam = mock

    policy = topic.policy

    policy.roles["roles/owner"] = ["user:owner@example.com", "serviceAccount:0987654321@developer.gserviceaccount.com"]
    topic.policy = policy

    #TODO
    # policy.add "roles/owner", "user:owner@example.com", "serviceAccount:0987654321@developer.gserviceaccount.com"
    # policy.remove "roles/owner", "user:owner@example.com"
    #
    # policy.roles.size.must_equal 1
    # policy.etag
    #TODO

    mock.verify

    # Setting the policy also memoizes the policy
    policy = topic.policy
    policy.must_be_kind_of Gcloud::Pubsub::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/viewer"].must_be :nil?
    policy.roles["roles/owner"].must_be_kind_of Array
    policy.roles["roles/owner"].count.must_equal 2
    policy.roles["roles/owner"].first.must_equal "user:owner@example.com"
    policy.roles["roles/owner"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
  end

  it "tests the available permissions" do
    test_req = Google::Iam::V1::TestIamPermissionsRequest.new(
      resource: "projects/#{project}/topics/#{topic_name}",
      permissions: ["pubsub.topics.get", "pubsub.topics.publish"]
    )
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["pubsub.topics.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [test_req]
    topic.service.mocked_iam = mock

    permissions = topic.test_permissions "pubsub.topics.get",
                                         "pubsub.topics.publish"

    mock.verify

    permissions.must_equal ["pubsub.topics.get"]
  end
end
