# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Bucket, :iam, :lazy, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service, user_project: true }

  let(:old_policy_gapi) {
    Google::Apis::StorageV1::Policy.new(
      etag: "CAE=",
      bindings: [
        Google::Apis::StorageV1::Policy::Binding.new(
          role: "roles/storage.objectViewer",
          members: [
            "user:viewer@example.com"
          ]
        )
      ]
    )
  }
  let(:updated_policy_gapi) {
    Google::Apis::StorageV1::Policy.new(
      etag: "CAE=",
      bindings: [
        Google::Apis::StorageV1::Policy::Binding.new(
          role: "roles/storage.objectViewer",
          members: [
            "user:viewer@example.com",
            "serviceAccount:1234567890@developer.gserviceaccount.com"
          ]
        )
      ]
    )
  }
  let(:new_policy_gapi) {
    Google::Apis::StorageV1::Policy.new(
      etag: "CAF=",
      bindings: [
        Google::Apis::StorageV1::Policy::Binding.new(
          role: "roles/storage.objectViewer",
          members: [
            "user:viewer@example.com",
            "serviceAccount:1234567890@developer.gserviceaccount.com"
          ]
        )
      ]
    )
  }
  let(:old_policy) { Google::Cloud::Storage::Policy.from_gapi old_policy_gapi }
  let(:updated_policy) { Google::Cloud::Storage::Policy.from_gapi updated_policy_gapi }
  let(:new_policy) { Google::Cloud::Storage::Policy.from_gapi new_policy_gapi }

  it "gets the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, user_project: nil]

    storage.service.mocked_service = mock
    policy = bucket.policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAE="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "gets the policy with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, user_project: "test"]

    storage.service.mocked_service = mock
    policy = bucket_user_project.policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAE="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "sets the policy" do
    mock = Minitest::Mock.new
    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

    storage.service.mocked_service = mock
    policy = bucket.update_policy updated_policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAF="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

    storage.service.mocked_service = mock
    policy = bucket_user_project.update_policy updated_policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAF="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy in a block" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, user_project: nil]

    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

    storage.service.mocked_service = mock
    policy = bucket.policy do |p|
      p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAF="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy in a block with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, user_project: "test"]

    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

    storage.service.mocked_service = mock
    policy = bucket_user_project.policy do |p|
      p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.etag.must_equal "CAF="
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.buckets.get"]
    mock.expect :test_bucket_iam_permissions, update_policy_response, [bucket_name, ["storage.buckets.get", "storage.buckets.delete"], user_project: nil]

    storage.service.mocked_service = mock
    permissions = bucket.test_permissions "storage.buckets.get",
                                           "storage.buckets.delete"
    mock.verify

    permissions.must_equal ["storage.buckets.get"]
  end

  it "tests the permissions available with user_project set to true" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.buckets.get"]
    mock.expect :test_bucket_iam_permissions, update_policy_response, [bucket_name, ["storage.buckets.get", "storage.buckets.delete"], user_project: "test"]

    storage.service.mocked_service = mock
    permissions = bucket_user_project.test_permissions "storage.buckets.get",
                                           "storage.buckets.delete"
    mock.verify

    permissions.must_equal ["storage.buckets.get"]
  end
end
