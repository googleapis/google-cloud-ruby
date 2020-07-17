# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Database, :iam, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:database_grpc) { Google::Cloud::Spanner::Admin::Database::V1::Database.new database_hash(instance_id: instance_id, database_id: database_id) }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }
  let(:viewer_policy_hash) do
    {
      etag: "\b\x01",
      bindings: [{
        role: "roles/viewer",
        members: [
          "user:viewer@example.com",
          "serviceAccount:1234567890@developer.gserviceaccount.com"
         ]
      }]
    }
  end
  let(:owner_policy_hash) do
    {
      etag: "\b\x01",
      bindings: [{
        role: "roles/owner",
        members: [
          "user:owner@example.com",
          "serviceAccount:0987654321@developer.gserviceaccount.com"
         ]
      }]
    }
  end

  it "gets the IAM Policy" do
    get_res = Google::Iam::V1::Policy.new viewer_policy_hash
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: database.path]
    database.service.mocked_databases = mock

    policy = database.policy

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Spanner::Policy
    _(policy.etag).must_equal "\b\x01"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be_kind_of Array
    _(policy.roles["roles/viewer"].count).must_equal 2
    _(policy.roles["roles/viewer"].first).must_equal "user:viewer@example.com"
    _(policy.roles["roles/viewer"].last).must_equal "serviceAccount:1234567890@developer.gserviceaccount.com"
  end

  it "sets the IAM Policy" do
    get_res = Google::Iam::V1::Policy.new owner_policy_hash
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: database.path]

    updated_policy_hash = owner_policy_hash.dup
    updated_policy_hash[:bindings].first[:members].shift
    updated_policy_hash[:bindings].first[:members] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.new updated_policy_hash
    set_res = Google::Iam::V1::Policy.new updated_policy_hash.merge(etag: "\b\x10")
    mock.expect :set_iam_policy, set_res, [resource: database.path, policy: set_req]
    database.service.mocked_databases = mock

    policy = database.policy

    policy.add "roles/owner", "user:newowner@example.com"
    policy.remove "roles/owner", "user:owner@example.com"

    policy = database.update_policy policy

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Spanner::Policy
    _(policy.etag).must_equal "\b\x10"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be :nil?
    _(policy.roles["roles/owner"]).must_be_kind_of Array
    _(policy.roles["roles/owner"].count).must_equal 2
    _(policy.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy.roles["roles/owner"].last).must_equal  "user:newowner@example.com"
  end

  it "sets the IAM Policy in a block" do
    get_res = Google::Iam::V1::Policy.new owner_policy_hash
    mock = Minitest::Mock.new
    mock.expect :get_iam_policy, get_res, [resource: database.path]

    updated_policy_hash = owner_policy_hash.dup
    updated_policy_hash[:bindings].first[:members].shift
    updated_policy_hash[:bindings].first[:members] << "user:newowner@example.com"

    set_req = Google::Iam::V1::Policy.new updated_policy_hash
    set_res = Google::Iam::V1::Policy.new updated_policy_hash.merge(etag: "\b\x10")
    mock.expect :set_iam_policy, set_res, [resource: database.path, policy: set_req]
    database.service.mocked_databases = mock

    policy = database.policy do |p|
      p.add "roles/owner", "user:newowner@example.com"
      p.remove "roles/owner", "user:owner@example.com"
    end

    mock.verify

    _(policy).must_be_kind_of Google::Cloud::Spanner::Policy
    _(policy.etag).must_equal "\b\x10"
    _(policy.roles).must_be_kind_of Hash
    _(policy.roles.size).must_equal 1
    _(policy.roles["roles/viewer"]).must_be :nil?
    _(policy.roles["roles/owner"]).must_be_kind_of Array
    _(policy.roles["roles/owner"].count).must_equal 2
    _(policy.roles["roles/owner"].first).must_equal "serviceAccount:0987654321@developer.gserviceaccount.com"
    _(policy.roles["roles/owner"].last).must_equal  "user:newowner@example.com"
  end

  it "tests the available permissions" do
    permissions = ["spanner.databases.get", "spanner.databases.publish"]
    test_res = Google::Iam::V1::TestIamPermissionsResponse.new(
      permissions: ["spanner.databases.get"]
    )
    mock = Minitest::Mock.new
    mock.expect :test_iam_permissions, test_res, [resource: database.path, permissions: permissions]
    database.service.mocked_databases = mock

    permissions = database.test_permissions "spanner.databases.get",
                                            "spanner.databases.publish"

    mock.verify

    _(permissions).must_equal ["spanner.databases.get"]
  end
end
