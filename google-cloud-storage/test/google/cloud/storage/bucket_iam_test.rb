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

describe Google::Cloud::Storage::Bucket, :iam, :mock_storage do
  let(:bucket_name) { "found-bucket" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  describe "version 1" do
    let(:old_policy_gapi) {
      policy_gapi(
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
      policy_gapi(
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
      policy_gapi(
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
    let(:old_policy) { Google::Cloud::Storage::PolicyV1.from_gapi old_policy_gapi }
    let(:updated_policy) { Google::Cloud::Storage::PolicyV1.from_gapi updated_policy_gapi }
    let(:new_policy) { Google::Cloud::Storage::PolicyV1.from_gapi new_policy_gapi }

    it "gets the policy" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: nil, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAE="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 1
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
    end

    it "gets the policy with requested_policy_version: 1" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: 1, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.policy requested_policy_version: 1
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAE="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 1
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
    end

    it "gets the policy with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: nil, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAE="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 1
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
    end

    it "sets the policy" do
      mock = Minitest::Mock.new
      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.update_policy updated_policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 2
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
      _(policy.roles["roles/storage.objectViewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
    end

    it "sets the policy with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.update_policy updated_policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 2
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
      _(policy.roles["roles/storage.objectViewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
    end

    it "sets the policy in a block" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: nil, user_project: nil]

      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.policy do |p|
        p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
      end
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 2
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
      _(policy.roles["roles/storage.objectViewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
    end

    it "sets the policy in a block with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: nil, user_project: "test"]

      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.policy do |p|
        p.add "roles/storage.objectViewer", "serviceAccount:1234567890@developer.gserviceaccount.com"
      end
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV1
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 1
      _(policy.roles).must_be_kind_of Hash
      _(policy.roles.size).must_equal 1
      _(policy.roles["roles/storage.objectViewer"]).must_be_kind_of Array
      _(policy.roles["roles/storage.objectViewer"].count).must_equal 2
      _(policy.roles["roles/storage.objectViewer"].first).must_equal "user:viewer@example.com"
      _(policy.roles["roles/storage.objectViewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
  end

  describe "version 3" do
    let(:old_policy_gapi) {
      policy_gapi(
        version: 1,
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
      policy_gapi(
        version: 3,
        bindings: [
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "user:viewer@example.com"
            ]
          ),
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "serviceAccount:1234567890@developer.gserviceaccount.com"
            ],
            condition: {
              title: "always-true",
              description: "test condition always-true",
              expression: "true"
            }
          )
        ]
      )
    }
    let(:new_policy_gapi) {
      policy_gapi(
        etag: "CAF=",
        version: 3,
        bindings: [
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "user:viewer@example.com"
            ]
          ),
          Google::Apis::StorageV1::Policy::Binding.new(
            role: "roles/storage.objectViewer",
            members: [
              "serviceAccount:1234567890@developer.gserviceaccount.com"
            ],
            condition: {
              title: "always-true",
              description: "test condition always-true",
              expression: "true"
            }
          )
        ]
      )
    }
    let(:old_policy) { Google::Cloud::Storage::PolicyV3.from_gapi old_policy_gapi }
    let(:updated_policy) { Google::Cloud::Storage::PolicyV3.from_gapi updated_policy_gapi }
    let(:new_policy) { Google::Cloud::Storage::PolicyV3.from_gapi new_policy_gapi }

    it "gets the policy" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: 3, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.policy requested_policy_version: 3
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAE="
      _(policy.version).must_equal 1
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 1
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
    end

    it "gets the policy with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: 3, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.policy requested_policy_version: 3
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAE="
      _(policy.version).must_equal 1
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 1
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
    end

    it "sets the policy" do
      mock = Minitest::Mock.new
      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.update_policy updated_policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 3
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 2
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
      _(policy.bindings.to_a[1]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[1].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[1].members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
      _(policy.bindings.to_a[1].condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
      _(policy.bindings.to_a[1].condition.title).must_equal "always-true"
      _(policy.bindings.to_a[1].condition.description).must_equal "test condition always-true"
      _(policy.bindings.to_a[1].condition.expression).must_equal "true"
    end

    it "sets the policy with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.update_policy updated_policy
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 3
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 2
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
      _(policy.bindings.to_a[1]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[1].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[1].members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
      _(policy.bindings.to_a[1].condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
      _(policy.bindings.to_a[1].condition.title).must_equal "always-true"
      _(policy.bindings.to_a[1].condition.description).must_equal "test condition always-true"
      _(policy.bindings.to_a[1].condition.expression).must_equal "true"
    end

    it "sets the policy in a block" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: 3, user_project: nil]

      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: nil]

      storage.service.mocked_service = mock
      policy = bucket.policy requested_policy_version: 3 do |p|
        p.version = 3
        p.bindings.insert({
                            role: "roles/storage.objectViewer",
                            members: ["serviceAccount:1234567890@developer.gserviceaccount.com"],
                            condition: {
                              title: "always-true",
                              description: "test condition always-true",
                              expression: "true"
                            }
                          })
      end
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 3
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 2
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
      _(policy.bindings.to_a[1]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[1].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[1].members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
      _(policy.bindings.to_a[1].condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
      _(policy.bindings.to_a[1].condition.title).must_equal "always-true"
      _(policy.bindings.to_a[1].condition.description).must_equal "test condition always-true"
      _(policy.bindings.to_a[1].condition.expression).must_equal "true"
    end

    it "sets the policy in a block with user_project set to true" do
      mock = Minitest::Mock.new
      mock.expect :get_bucket_iam_policy, old_policy_gapi, [bucket_name, options_requested_policy_version: 3, user_project: "test"]

      mock.expect :set_bucket_iam_policy, new_policy_gapi, [bucket_name, updated_policy_gapi, user_project: "test"]

      storage.service.mocked_service = mock
      policy = bucket_user_project.policy requested_policy_version: 3 do |p|
        p.version = 3
        p.bindings.insert({
                            role: "roles/storage.objectViewer",
                            members: ["serviceAccount:1234567890@developer.gserviceaccount.com"],
                            condition: {
                              title: "always-true",
                              description: "test condition always-true",
                              expression: "true"
                            }
                          })
      end
      mock.verify

      _(policy).must_be_kind_of Google::Cloud::Storage::PolicyV3
      _(policy.etag).must_equal "CAF="
      _(policy.version).must_equal 3
      _(policy.bindings).must_be_kind_of Google::Cloud::Storage::Policy::Bindings
      _(policy.bindings.to_a.count).must_equal 2
      _(policy.bindings.to_a[0]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[0].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[0].members).must_equal ["user:viewer@example.com"]
      _(policy.bindings.to_a[0].condition).must_be :nil?
      _(policy.bindings.to_a[1]).must_be_kind_of Google::Cloud::Storage::Policy::Binding
      _(policy.bindings.to_a[1].role).must_equal "roles/storage.objectViewer"
      _(policy.bindings.to_a[1].members).must_equal ["serviceAccount:1234567890@developer.gserviceaccount.com"]
      _(policy.bindings.to_a[1].condition).must_be_kind_of Google::Cloud::Storage::Policy::Condition
      _(policy.bindings.to_a[1].condition.title).must_equal "always-true"
      _(policy.bindings.to_a[1].condition.description).must_equal "test condition always-true"
      _(policy.bindings.to_a[1].condition.expression).must_equal "true"
    end
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.buckets.get"]
    mock.expect :test_bucket_iam_permissions, update_policy_response, [bucket_name, ["storage.buckets.get", "storage.buckets.delete"], user_project: nil]

    storage.service.mocked_service = mock
    permissions = bucket.test_permissions "storage.buckets.get",
                                           "storage.buckets.delete"
    mock.verify

    _(permissions).must_equal ["storage.buckets.get"]
  end

  it "tests the permissions available with user_project set to true" do
    mock = Minitest::Mock.new
    update_policy_response = Google::Apis::StorageV1::TestIamPermissionsResponse.new permissions: ["storage.buckets.get"]
    mock.expect :test_bucket_iam_permissions, update_policy_response, [bucket_name, ["storage.buckets.get", "storage.buckets.delete"], user_project: "test"]

    storage.service.mocked_service = mock
    permissions = bucket_user_project.test_permissions "storage.buckets.get",
                                           "storage.buckets.delete"
    mock.verify

    _(permissions).must_equal ["storage.buckets.get"]
  end
end
