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

describe Gcloud::ResourceManager::Project, :iam, :mock_res_man do
  let(:seed) { 123 }
  let(:project_hash) { random_project_hash(seed) }
  let(:project) { Gcloud::ResourceManager::Project.from_gapi project_hash,
                                                             resource_manager.connection }
  let(:old_bindings_hash) do
    { "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com"
        ], }], }
  end
  let(:new_bindings_hash) do
    { "bindings" => [{
        "role" => "roles/viewer",
        "members" => [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ], }], }
  end
  let(:old_policy_json) { { "policy" => old_bindings_hash }.to_json }
  let(:new_policy_json) { { "policy" => new_bindings_hash }.to_json }

  it "gets the policy" do
    mock_connection.post "/v1beta1/projects/#{project.project_id}:getIamPolicy" do |env|
      [200, {"Content-Type"=>"application/json"},
       old_policy_json]
    end

    policy = project.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 1
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
  end

  it "memoizes policy" do
    project.instance_variable_set "@policy", old_bindings_hash

    # No mocks, no errors, no HTTP calls are made
    policy = project.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 1
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
  end

  it "can force load the policy" do
    mock_connection.post "/v1beta1/projects/#{project.project_id}:getIamPolicy" do |env|
      [200, {"Content-Type"=>"application/json"},
       new_policy_json]
    end

    policy = project.policy force: true
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "can force load the policy, even if already memoized" do
    mock_connection.post "/v1beta1/projects/#{project.project_id}:getIamPolicy" do |env|
      [200, {"Content-Type"=>"application/json"},
       new_policy_json]
    end

    project.instance_variable_set "@policy", old_bindings_hash
    returned_policy = project.policy
    returned_policy.must_be_kind_of Hash
    returned_policy["bindings"].count.must_equal 1
    returned_policy["bindings"].first["role"].must_equal "roles/viewer"
    returned_policy["bindings"].first["members"].count.must_equal 1
    returned_policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"

    policy = project.policy force: true
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy" do
    mock_connection.post "/v1beta1/projects/#{project.project_id}:setIamPolicy" do |env|
      json_policy = JSON.parse env.body
      json_policy["policy"]["bindings"].count.must_equal 1
      json_policy["policy"]["bindings"].first["role"].must_equal "roles/viewer"
      json_policy["policy"]["bindings"].first["members"].count.must_equal 2
      json_policy["policy"]["bindings"].first["members"].first.must_equal "user:viewer@example.com"
      json_policy["policy"]["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
      [200, {"Content-Type"=>"application/json"},
       new_policy_json]
    end

    project.policy = new_bindings_hash
    # Setting the policy also memoizes the policy
    project.policy["bindings"].count.must_equal 1
    project.policy["bindings"].first["role"].must_equal "roles/viewer"
    project.policy["bindings"].first["members"].count.must_equal 2
    project.policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    project.policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    # skip
    mock_connection.post "/v1beta1/projects/#{project.project_id}:testIamPermissions" do |env|
      json_permissions = JSON.parse env.body
      json_permissions["permissions"].count.must_equal 2
      json_permissions["permissions"].first.must_equal "resourcemanager.projects.get"
      json_permissions["permissions"].last.must_equal  "resourcemanager.projects.delete"
      [200, {"Content-Type"=>"application/json"},
       { "permissions" => ["resourcemanager.projects.get"] }.to_json]
    end

    permissions = project.test_permissions "resourcemanager.projects.get",
                                           "resourcemanager.projects.delete"
    permissions.must_equal ["resourcemanager.projects.get"]
  end
end
