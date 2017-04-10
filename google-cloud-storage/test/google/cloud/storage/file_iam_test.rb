# Copyright 2017 Google Inc. All rights reserved.
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

describe Google::Cloud::Storage::File, :iam, :mock_storage do
  let(:bucket_name) { "bucket" }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(bucket_name).to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:file_name) { "file.ext" }
  let(:file_hash) { random_file_hash bucket.name, file_name }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  
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
  let(:new_policy_gapi) {
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
  let(:old_policy) { Google::Cloud::Storage::Policy.from_gapi old_policy_gapi }
  let(:new_policy) { Google::Cloud::Storage::Policy.from_gapi new_policy_gapi }

  it "gets the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_object_iam_policy, old_policy_gapi, [bucket_name, file_name]

    storage.service.mocked_service = mock
    policy = file.policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "memoizes policy" do
    file.instance_variable_set "@policy", old_policy

    # No mocks, no errors, no HTTP calls are made
    policy = file.policy
    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "can force load the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_object_iam_policy, new_policy_gapi, [bucket_name, file_name]

    storage.service.mocked_service = mock
    policy = file.policy force: true
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "can force load the policy, even if already memoized" do
    # memoize the policy object
    file.instance_variable_set "@policy", old_policy

    returned_policy = file.policy
    returned_policy.must_be_kind_of Google::Cloud::Storage::Policy
    returned_policy.roles.must_be_kind_of Hash
    returned_policy.roles.size.must_equal 1
    returned_policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    returned_policy.roles["roles/storage.objectViewer"].count.must_equal 1
    returned_policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"

    mock = Minitest::Mock.new
    mock.expect :get_object_iam_policy, new_policy_gapi, [bucket_name, file_name]

    storage.service.mocked_service = mock
    policy = file.policy force: true
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 2
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy" do
    mock = Minitest::Mock.new
    mock.expect :set_object_iam_policy, new_policy_gapi, [bucket_name, file_name, new_policy_gapi]

    storage.service.mocked_service = mock
    file.policy = new_policy
    mock.verify

    # Setting the policy also memoizes the policy
    file.policy.must_be_kind_of Google::Cloud::Storage::Policy
    file.policy.roles.must_be_kind_of Hash
    file.policy.roles.size.must_equal 1
    file.policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    file.policy.roles["roles/storage.objectViewer"].count.must_equal 2
    file.policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    file.policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy in a block" do
    # memoize the policy object, to ensure that it is reloaded for update
    file.instance_variable_set "@policy", old_policy

    mock = Minitest::Mock.new
    mock.expect :get_object_iam_policy, old_policy_gapi, [bucket_name, file_name]

    mock.expect :set_object_iam_policy, new_policy_gapi, [bucket_name, file_name, new_policy_gapi]

    storage.service.mocked_service = mock
    policy = file.policy do |p|
      p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    file.policy.roles.size.must_equal 1
    file.policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    file.policy.roles["roles/storage.objectViewer"].count.must_equal 2
    file.policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    file.policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.objects.get"]
    mock.expect :test_object_iam_permissions, update_policy_response, [bucket_name, file_name, ["storage.objects.get", "storage.objects.delete"]]

    storage.service.mocked_service = mock
    permissions = file.test_permissions "storage.objects.get",
                                           "storage.objects.delete"
    mock.verify

    permissions.must_equal ["storage.objects.get"]
  end
end
