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

describe Google::Cloud::ResourceManager::Project, :iam, :mock_res_man do
  let(:seed) { 123 }
  let(:project_gapi) { random_project_gapi seed }
  let(:project) { Google::Cloud::ResourceManager::Project.from_gapi project_gapi,
                                                             resource_manager.service }
  let(:old_policy_gapi) {
    Google::Apis::CloudresourcemanagerV1::Policy.new(
      etag: "CAE=",
      bindings: [
        Google::Apis::CloudresourcemanagerV1::Binding.new(
          role: "roles/viewer",
          members: [
            "user:viewer@example.com"
          ]
        )
      ]
    )
  }
  let(:updated_policy_gapi) {
    Google::Apis::CloudresourcemanagerV1::Policy.new(
      etag: "CAE=",
      bindings: [
        Google::Apis::CloudresourcemanagerV1::Binding.new(
          role: "roles/viewer",
          members: [
            "user:viewer@example.com",
            "serviceAccount:1234567890@developer.gserviceaccount.com"
          ]
        )
      ]
    )
  }
  let(:new_policy_gapi) {
    Google::Apis::CloudresourcemanagerV1::Policy.new(
      etag: "CAF=",
      bindings: [
        Google::Apis::CloudresourcemanagerV1::Binding.new(
          role: "roles/viewer",
          members: [
            "user:viewer@example.com",
            "serviceAccount:1234567890@developer.gserviceaccount.com"
          ]
        )
      ]
    )
  }
  let(:old_policy) { Google::Cloud::ResourceManager::Policy.from_gapi old_policy_gapi }
  let(:updated_policy) { Google::Cloud::ResourceManager::Policy.from_gapi updated_policy_gapi }
  let(:new_policy) { Google::Cloud::ResourceManager::Policy.from_gapi new_policy_gapi }

  it "gets the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_project_iam_policy, old_policy_gapi, ["example-project-123"]

    resource_manager.service.mocked_service = mock
    policy = project.policy
    mock.verify

    _(policy).must_be_kind_of Google::Cloud::ResourceManager::Policy
    _(policy.etag).must_equal "CAE="
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 1
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
  end

  it "sets the policy" do
    mock = Minitest::Mock.new
    update_policy_request = Google::Apis::CloudresourcemanagerV1::SetIamPolicyRequest.new policy: updated_policy_gapi
    mock.expect :set_project_iam_policy, new_policy_gapi, ["example-project-123", update_policy_request]

    resource_manager.service.mocked_service = mock
    policy = project.update_policy updated_policy
    mock.verify

    _(policy).must_be_kind_of Google::Cloud::ResourceManager::Policy
    _(policy.etag).must_equal "CAF="
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 2
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
    _(policy.roles["roles/viewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy in a block" do
    mock = Minitest::Mock.new
    mock.expect :get_project_iam_policy, old_policy_gapi, ["example-project-123"]

    update_policy_request = Google::Apis::CloudresourcemanagerV1::SetIamPolicyRequest.new policy: updated_policy_gapi
    mock.expect :set_project_iam_policy, new_policy_gapi, ["example-project-123", update_policy_request]

    resource_manager.service.mocked_service = mock
    policy = project.policy do |p|
      p.add "roles/viewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    _(policy).must_be_kind_of Google::Cloud::ResourceManager::Policy
    _(policy.etag).must_equal "CAF="
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 2
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
    _(policy.roles["roles/viewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_request  = Google::Apis::CloudresourcemanagerV1::TestIamPermissionsRequest.new  permissions: ["resourcemanager.projects.get", "resourcemanager.projects.delete"]
    update_policy_response = Google::Apis::CloudresourcemanagerV1::TestIamPermissionsResponse.new permissions: ["resourcemanager.projects.get"]
    mock.expect :test_project_iam_permissions, update_policy_response, ["example-project-123", update_policy_request]

    resource_manager.service.mocked_service = mock
    permissions = project.test_permissions "resourcemanager.projects.get",
                                           "resourcemanager.projects.delete"
    mock.verify

    _(permissions).must_equal ["resourcemanager.projects.get"]
  end
end
