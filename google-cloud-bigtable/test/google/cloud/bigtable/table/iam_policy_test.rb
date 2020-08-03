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

describe Google::Cloud::Bigtable::Table, :iam_policy, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:column_families) { column_families_grpc }
  let(:table_grpc){
    Google::Cloud::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  }
  let(:table) do
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  end
  let(:viewer_policy_json) do
    {
      etag: "YWJj",
      bindings: [{
        role: "roles/viewer",
        members: [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }.to_json
  end
  let(:owner_policy_json) do
    {
      etag: "YWJj",
      bindings: [{
        role: "roles/owner",
        members: [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
         ]
      }]
    }.to_json
  end

  it "gets the IAM Policy" do
    get_res = Google::Iam::V1::Policy.decode_json(viewer_policy_json)
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: table.path]
    table.service.mocked_tables = mock

    policy = table.policy

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Bigtable::Policy
    _(policy.etag).must_equal "abc"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 2
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
    _(policy.roles["roles/viewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "update the iam policy" do
    get_res = Google::Iam::V1::Policy.decode_json(owner_policy_json)
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: table.path]

    updated_policy_hash = JSON.parse(owner_policy_json)
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json(updated_policy_hash.to_json)
    set_res = Google::Iam::V1::Policy.decode_json(updated_policy_hash.merge(etag: "eHl6").to_json)
    mock.expect :set_iam_policy, set_res, [resource: table.path, policy: set_req]
    table.service.mocked_tables = mock

    policy = table.policy

    policy.add("roles/owner", "user:newowner@example.com")
    policy.remove("roles/owner", "user:owner@example.com")

    policy = table.update_policy(policy)

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Bigtable::Policy
    _(policy.etag).must_equal "xyz"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be :nil?
    _(policy.roles["roles/owner"]).must_be_kind_of Array
    _(policy.roles["roles/owner"].count).must_equal 2
    _(policy.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy.roles["roles/owner"].last).must_equal  "user:newowner@example.com"
  end

  it "get and set policy using block" do
    get_res = Google::Iam::V1::Policy.decode_json(owner_policy_json)
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: table.path]

    updated_policy_hash = JSON.parse(owner_policy_json)
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json(updated_policy_hash.to_json)
    set_res = Google::Iam::V1::Policy.decode_json(updated_policy_hash.merge(etag: "eHl6").to_json)
    mock.expect :set_iam_policy, set_res, [resource: table.path, policy: set_req]
    table.service.mocked_tables = mock

    policy = table.policy do |v|
      v.add("roles/owner", "user:newowner@example.com")
      v.remove("roles/owner", "user:owner@example.com")
    end

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Bigtable::Policy
    _(policy.etag).must_equal "xyz"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be :nil?
    _(policy.roles["roles/owner"]).must_be_kind_of Array
    _(policy.roles["roles/owner"].count).must_equal 2
    _(policy.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy.roles["roles/owner"].last).must_equal  "user:newowner@example.com"
  end

  it "tests the available permissions" do
   permissions = ["bigtable.tables.create", "bigtable.tables.list"]
   test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
     permissions: ["bigtable.tables.list"]
   )
   mock = Minitest::Mock.new
   mock.expect :test_iam_permissions, test_res, [resource: table.path, permissions: permissions]
   table.service.mocked_tables = mock

   permissions = table.test_iam_permissions(
     "bigtable.tables.create", "bigtable.tables.list"
   )

   mock.verify

   _(permissions).must_be_kind_of Array
   _(permissions).must_equal ["bigtable.tables.list"]
 end
end
