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
  let(:project_gapi) { Gcloud::ResourceManager::Service::API::Project.new project_hash }
  let(:project) { Gcloud::ResourceManager::Project.from_gapi project_gapi,
                                                             resource_manager.service }
  let(:old_policy_hash) do
    { etag: "CAE=",
      bindings: [{
        role: "roles/viewer",
        members: [
          "user:viewer@example.com"
        ], }], }
  end
  let(:new_policy_hash) do
    { etag: "CAE=",
      bindings: [{
        role: "roles/viewer",
        members: [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
        ], }], }
  end
  let(:old_policy) { Gcloud::ResourceManager::Service::API::Policy.new old_policy_hash }
  let(:new_policy) { Gcloud::ResourceManager::Service::API::Policy.new new_policy_hash }

  it "gets the policy" do
    mock = Minitest::Mock.new
    random_project = Gcloud::ResourceManager::Service::API::Project.new random_project_hash(123)
    mock.expect :get_project_iam_policy, old_policy, ["projects/example-project-123"]

    resource_manager.service.mocked_service = mock
    policy = project.policy
    mock.verify

    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 1
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
  end

  it "memoizes policy" do
    project.instance_variable_set "@policy", JSON.parse(old_policy.to_json)

    # No mocks, no errors, no HTTP calls are made
    policy = project.policy
    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 1
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
  end

  it "can force load the policy" do
    mock = Minitest::Mock.new
    random_project = Gcloud::ResourceManager::Service::API::Project.new random_project_hash(123)
    mock.expect :get_project_iam_policy, new_policy, ["projects/example-project-123"]

    resource_manager.service.mocked_service = mock
    policy = project.policy force: true
    mock.verify

    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "can force load the policy, even if already memoized" do
    # memoize the policy object
    project.instance_variable_set "@policy", JSON.parse(old_policy.to_json)

    returned_policy = project.policy
    returned_policy.must_be_kind_of Hash
    returned_policy["bindings"].count.must_equal 1
    returned_policy["bindings"].first["role"].must_equal "roles/viewer"
    returned_policy["bindings"].first["members"].count.must_equal 1
    returned_policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"

    mock = Minitest::Mock.new
    random_project = Gcloud::ResourceManager::Service::API::Project.new random_project_hash(123)
    mock.expect :get_project_iam_policy, new_policy, ["projects/example-project-123"]

    resource_manager.service.mocked_service = mock
    policy = project.policy force: true
    mock.verify

    policy.must_be_kind_of Hash
    policy["bindings"].count.must_equal 1
    policy["bindings"].first["role"].must_equal "roles/viewer"
    policy["bindings"].first["members"].count.must_equal 2
    policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy" do
    mock = Minitest::Mock.new
    update_policy_request = Gcloud::ResourceManager::Service::API::SetIamPolicyRequest.new policy: new_policy
    mock.expect :set_project_iam_policy, new_policy, ["projects/example-project-123", update_policy_request]

    resource_manager.service.mocked_service = mock
    project.policy = new_policy_hash
    mock.verify

    # Setting the policy also memoizes the policy
    project.policy["bindings"].count.must_equal 1
    project.policy["bindings"].first["role"].must_equal "roles/viewer"
    project.policy["bindings"].first["members"].count.must_equal 2
    project.policy["bindings"].first["members"].first.must_equal "user:viewer@example.com"
    project.policy["bindings"].first["members"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_request  = Gcloud::ResourceManager::Service::API::TestIamPermissionsRequest.new  permissions: ["resourcemanager.projects.get", "resourcemanager.projects.delete"]
    update_policy_response = Gcloud::ResourceManager::Service::API::TestIamPermissionsResponse.new permissions: ["resourcemanager.projects.get"]
    mock.expect :test_project_iam_permissions, update_policy_response, ["projects/example-project-123", update_policy_request]

    resource_manager.service.mocked_service = mock
    permissions = project.test_permissions "resourcemanager.projects.get",
                                           "resourcemanager.projects.delete"
    mock.verify

    permissions.must_equal ["resourcemanager.projects.get"]
  end
end
