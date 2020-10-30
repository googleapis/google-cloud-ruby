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

describe Google::Cloud::Bigtable::Backup, :iam_policy, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:cluster_id) { "test-cluster" }
  let(:backup_id) { "test-backup" }
  let(:expire_time) { Time.now.round(0) + 60 * 60 * 7 }
  let(:backup_res) { backup_grpc instance_id, cluster_id, backup_id, "test-table-source", expire_time }
  let(:backup) { Google::Cloud::Bigtable::Backup.from_grpc backup_res, bigtable.service }
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
    mock.expect :get_iam_policy, get_res, [resource: backup.path]
    backup.service.mocked_tables = mock

    policy = backup.policy

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
    mock.expect :get_iam_policy, get_res, [resource: backup.path]

    updated_policy_hash = JSON.parse(owner_policy_json)
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json(updated_policy_hash.to_json)
    set_res = Google::Iam::V1::Policy.decode_json(updated_policy_hash.merge(etag: "eHl6").to_json)
    mock.expect :set_iam_policy, set_res, [resource: backup.path, policy: set_req]
    backup.service.mocked_tables = mock

    policy = backup.policy

    policy.add("roles/owner", "user:newowner@example.com")
    policy.remove("roles/owner", "user:owner@example.com")

    policy = backup.update_policy(policy)

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
    mock.expect :get_iam_policy, get_res, [resource: backup.path]

    updated_policy_hash = JSON.parse(owner_policy_json)
    updated_policy_hash["bindings"].first["members"].shift
    updated_policy_hash["bindings"].first["members"] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.decode_json(updated_policy_hash.to_json)
    set_res = Google::Iam::V1::Policy.decode_json(updated_policy_hash.merge(etag: "eHl6").to_json)
    mock.expect :set_iam_policy, set_res, [resource: backup.path, policy: set_req]
    backup.service.mocked_tables = mock

    policy = backup.policy do |v|
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
   permissions = ["bigtable.backups.create", "bigtable.backups.list"]
   test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
     permissions: ["bigtable.backups.list"]
   )
   mock = Minitest::Mock.new
   mock.expect :test_iam_permissions, test_res, [resource: backup.path, permissions: permissions]
   backup.service.mocked_tables = mock

   permissions = backup.test_iam_permissions(
     "bigtable.backups.create", "bigtable.backups.list"
   )

   mock.verify

   _(permissions).must_be_kind_of Array
   _(permissions).must_equal ["bigtable.backups.list"]
 end
end
