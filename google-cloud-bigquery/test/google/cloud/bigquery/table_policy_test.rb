# Copyright 2020 Google LLC
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

describe Google::Cloud::Bigquery::Table, :policy, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_path) { formatted_table_path dataset_id, table_id }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:old_policy_gapi) {
    policy_gapi(
      bindings: [
        Google::Apis::BigqueryV2::Binding.new(
          role: "roles/bigquery.dataViewer",
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
        Google::Apis::BigqueryV2::Binding.new(
          role: "roles/bigquery.dataViewer",
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
        Google::Apis::BigqueryV2::Binding.new(
          role: "roles/bigquery.dataViewer",
          members: [
            "user:viewer@example.com",
            "serviceAccount:1234567890@developer.gserviceaccount.com"
          ]
        )
      ]
    )
  }
  let(:old_policy) { Google::Cloud::BigqueryV2::Policy.from_gapi old_policy_gapi }
  let(:updated_policy) { Google::Cloud::BigqueryV2::Policy.from_gapi updated_policy_gapi }
  let(:new_policy) { Google::Cloud::BigqueryV2::Policy.from_gapi new_policy_gapi }

  it "gets the policy" do
    mock = Minitest::Mock.new
    mock.expect :get_table_iam_policy, old_policy_gapi, [table_path, get_iam_policy_request_gapi]

    bigquery.service.mocked_service = mock
    policy = table.policy
    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
    _(policy).must_be :frozen?
    _(policy.etag).must_equal "CAE="
    _(policy.etag).must_be :frozen?
    _(policy.bindings).must_be_kind_of Array
    _(policy.bindings.size).must_equal 1
    _(policy.bindings[0]).must_be :frozen?
    _(policy.bindings[0].role).must_be :frozen?
    _(policy.bindings[0].members).must_be_kind_of Array
    _(policy.bindings[0].members).must_be :frozen?
    binding = policy.binding "roles/bigquery.dataViewer"
    _(binding).must_equal policy.bindings[0]
    _(binding).must_be :frozen?
    _(binding.role).must_be :frozen?
    members = binding.members
    _(members).must_be_kind_of Array
    _(members).must_be :frozen?
    _(members.count).must_equal 1
    _(members.first).must_equal "user:viewer@example.com"
  end

  it "raises if a block is provided to #policy" do
    expect do
      table.policy do |p|
        p.binding("roles/bigquery.dataViewer").members << "serviceAccount:1234567890@developer.gserviceaccount.com"
      end
    end.must_raise ArgumentError
  end

  it "updates the policy in a block" do
    mock = Minitest::Mock.new
    mock.expect :get_table_iam_policy, old_policy_gapi, [table_path, get_iam_policy_request_gapi]
    mock.expect :set_table_iam_policy, new_policy_gapi, [table_path, set_iam_policy_request_gapi(updated_policy_gapi)]

    bigquery.service.mocked_service = mock
    policy = table.update_policy do |p|
      _(p.bindings).must_be_kind_of Array
      _(p.bindings.size).must_equal 1
      _(p.bindings[0]).wont_be :frozen?
      _(p.bindings[0].role).wont_be :frozen?
      _(p.bindings[0].members).must_be_kind_of Array
      _(p.bindings[0].members).wont_be :frozen?
      binding = p.binding "roles/bigquery.dataViewer"
      _(binding).wont_be :frozen?
      members = binding.members
      _(members).must_be_kind_of Array
      _(members.size).must_equal 1
      _(members).wont_be :frozen?
      members << "serviceAccount:1234567890@developer.gserviceaccount.com"
    end
    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
    _(policy.etag).must_equal "CAF="
    _(policy.bindings).must_be_kind_of Array
    _(policy.bindings).must_be :frozen?
    _(policy.bindings.size).must_equal 1
    _(policy.bindings[0]).must_be :frozen?
    _(policy.bindings[0].role).must_be :frozen?
    _(policy.bindings[0].members).must_be_kind_of Array
    _(policy.bindings[0].members).must_be :frozen?
    binding = policy.binding "roles/bigquery.dataViewer"
    _(binding).must_equal policy.bindings[0]
    _(binding).must_be :frozen?
    members = binding.members
    _(members).must_be_kind_of Array
    _(members).must_be :frozen?
    _(members.count).must_equal 2
    _(members.first).must_equal "user:viewer@example.com"
    _(members.last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "raises if no block is provided to #update_policy" do
    expect { table.update_policy }.must_raise ArgumentError
  end

  it "tests the permissions available" do
    mock = Minitest::Mock.new
    mock.expect :test_table_iam_permissions,
                iam_permissions_response_gapi(["bigquery.tables.get"]),
                [table_path, iam_permissions_request_gapi(["bigquery.tables.get", "bigquery.tables.delete"])]

    bigquery.service.mocked_service = mock
    permissions = table.test_iam_permissions "bigquery.tables.get", "bigquery.tables.delete"
    mock.verify

    _(permissions).must_equal ["bigquery.tables.get"]
  end

  def get_iam_policy_request_gapi
    Google::Apis::BigqueryV2::GetIamPolicyRequest.new(
      options: Google::Apis::BigqueryV2::GetPolicyOptions.new(requested_policy_version: 1)
    )
  end

  def set_iam_policy_request_gapi policy_gapi
    Google::Apis::BigqueryV2::SetIamPolicyRequest.new policy: policy_gapi
  end

  def iam_permissions_request_gapi permissions
    Google::Apis::BigqueryV2::TestIamPermissionsRequest.new permissions: permissions
  end

  def iam_permissions_response_gapi permissions
    Google::Apis::BigqueryV2::TestIamPermissionsResponse.new permissions: permissions
  end
end
