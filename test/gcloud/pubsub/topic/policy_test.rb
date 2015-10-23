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
  let(:topic) { Gcloud::Pubsub::Topic.from_gapi JSON.parse(topic_json(topic_name)),
                                                pubsub.connection }

  it "gets the IAM Policy" do
    policy_json = {
      "etag"=>"BwUiutJSWn8=",
      "bindings"=>[{
        "role"=>"roles/viewer",
        "members"=>[
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }.to_json

    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}:getIamPolicy" do |env|
      [200, {"Content-Type"=>"application/json"},
       policy_json]
    end

    policy = topic.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "memoizes policy" do
    policy_hash = {
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }

    topic.instance_variable_set "@policy", policy_hash

    # No mocks, no errors, no HTTP calls are made
    policy = topic.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "makes API calls when forced, even if already memoized" do
    policy_hash = {
      "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ],
      }]
    }

    policy_json = {
      "etag"=>"BwUiutJSWn8=",
      "bindings"=>[{
        "role"=>"roles/owner",
        "members"=>[
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
         ]
      }]
    }.to_json

    mock_connection.get "/v1/projects/#{project}/topics/#{topic_name}:getIamPolicy" do |env|
      [200, {"Content-Type"=>"application/json"},
       policy_json]
    end

    topic.instance_variable_set "@policy", policy_hash
    returned_policy = topic.policy
    returned_policy.must_be_kind_of Hash
    returned_policy["bindings"].count.must_equal 1
    returned_policy["bindings"].first["role"].must_equal "roles/viewer"
    returned_policy["bindings"].first["members"].count.must_equal 2
    returned_policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    returned_policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"

    policy = topic.policy force: true
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

    mock_connection.post "/v1/projects/#{project}/topics/#{topic_name}:setIamPolicy" do |env|
      json_policy = JSON.parse env.body
      json_policy["policy"]["bindings"].count.must_equal 1
      json_policy["policy"]["bindings"].first["role"].must_equal "roles/owner"
      json_policy["policy"]["bindings"].first["members"].count.must_equal 2
      json_policy["policy"]["bindings"].first["members"].first.must_equal "user:owner@example.com"
      json_policy["policy"]["bindings"].first["members"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
      [200, {"Content-Type"=>"application/json"},
       { "policy" => new_policy }.to_json]
    end

    topic.policy = new_policy
    # Setting the policy also memoizes the policy
    topic.policy["bindings"].count.must_equal 1
    topic.policy["bindings"].first["role"].must_equal "roles/owner"
    topic.policy["bindings"].first["members"].count.must_equal 2
    topic.policy["bindings"].first["members"].first.must_equal "user:owner@example.com"
    topic.policy["bindings"].first["members"].last.must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
  end
end
