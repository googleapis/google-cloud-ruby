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

describe Google::Cloud::Storage::Bucket, :iam, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket_hash) { random_bucket_hash bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  
  let(:old_policy_gapi) {
    Google::Apis::StorageV1::Policy.new(
      etag: "CAE=",
      resource_id: "buckets/#{bucket_name}",
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
      resource_id: "buckets/#{bucket_name}",
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
  let(:old_policy) { Google::Cloud::Storage::Policy.from_gapi old_policy_gapi, storage.service }
  let(:new_policy) { Google::Cloud::Storage::Policy.from_gapi new_policy_gapi, storage.service }

  it "gets the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name]

    storage.service.mocked_service = mock
    policy = bucket.policy
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "memoizes policy" do
    bucket.instance_variable_set "@policy", old_policy

    # No mocks, no errors, no HTTP calls are made
    policy = bucket.policy
    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    policy.roles.size.must_equal 1
    policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    policy.roles["roles/storage.objectViewer"].count.must_equal 1
    policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
  end

  it "can force load the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, new_policy_gapi, [bucket_name]

    storage.service.mocked_service = mock
    policy = bucket.policy force: true
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
    bucket.instance_variable_set "@policy", old_policy

    returned_policy = bucket.policy
    returned_policy.must_be_kind_of Google::Cloud::Storage::Policy
    returned_policy.roles.must_be_kind_of Hash
    returned_policy.roles.size.must_equal 1
    returned_policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    returned_policy.roles["roles/storage.objectViewer"].count.must_equal 1
    returned_policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"

    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, new_policy_gapi, [bucket_name]

    storage.service.mocked_service = mock
    policy = bucket.policy force: true
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
    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, new_policy_gapi]

    storage.service.mocked_service = mock
    bucket.policy = new_policy
    mock.verify

    # Setting the policy also memoizes the policy
    bucket.policy.must_be_kind_of Google::Cloud::Storage::Policy
    bucket.policy.roles.must_be_kind_of Hash
    bucket.policy.roles.size.must_equal 1
    bucket.policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    bucket.policy.roles["roles/storage.objectViewer"].count.must_equal 2
    bucket.policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    bucket.policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the policy in a block" do
    # memoize the policy object, to ensure that it is reloaded for update
    bucket.instance_variable_set "@policy", old_policy

    mock = Minitest::Mock.new
    mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name]

    mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, new_policy_gapi]

    storage.service.mocked_service = mock
    policy = bucket.policy do |p|
      p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    policy.must_be_kind_of Google::Cloud::Storage::Policy
    policy.roles.must_be_kind_of Hash
    bucket.policy.roles.size.must_equal 1
    bucket.policy.roles["roles/storage.objectViewer"].must_be_kind_of Array
    bucket.policy.roles["roles/storage.objectViewer"].count.must_equal 2
    bucket.policy.roles["roles/storage.objectViewer"].first.must_equal "user:viewer@example.com"
    bucket.policy.roles["roles/storage.objectViewer"].last.must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.buckets.get"]
    mock.expect :test_bucket_iam_permissions, update_policy_response, [bucket_name, ["storage.buckets.get", "storage.buckets.delete"]]

    storage.service.mocked_service = mock
    permissions = bucket.test_permissions "storage.buckets.get",
                                           "storage.buckets.delete"
    mock.verify

    permissions.must_equal ["storage.buckets.get"]
  end
end
