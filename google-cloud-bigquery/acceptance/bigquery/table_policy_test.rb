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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Table, :policy, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "kittens" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer   "id",    description: "id description",    mode: :required
      end
    end
    t
  end

  it "allows permissions to be tested and policy to be updated" do
    roles = ["bigquery.tables.delete", "bigquery.tables.get"]
    permissions = table.test_iam_permissions roles
    _(permissions).must_equal roles
    _(permissions).must_be :frozen?

    policy = table.policy # get
    _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
    _(policy).must_be :frozen?
    etag_1 = policy.etag
    _(etag_1).wont_be :empty?
    _(etag_1).must_be :frozen?
    _(policy.roles).must_be :empty?
    _(policy.roles).must_be :frozen?

    # We need a valid service account in order to update the policy
    service_account = bigquery.service.credentials.client.issuer
    _(service_account).wont_be :nil?
    role = "roles/bigquery.dataOwner"
    member = "serviceAccount:#{service_account}"

    # update
    policy = table.update_policy do |p|
      _(p.roles).must_be :empty?
      _(p.roles).wont_be :frozen?
      _(p).wont_be :frozen?

      p.add role, member
      p.add role, member # duplicate member will not be added to request
    end

    _(policy).must_be :frozen?
    etag_2 = policy.etag
    _(etag_2).wont_be :empty?
    _(etag_2).must_be :frozen?
    _(etag_2).wont_equal etag_1
    _(policy.roles).must_be :frozen?
    _(policy.roles.count).must_equal 1
    members = policy.role(role)
    _(members).must_be_kind_of Array
    _(members.count).must_equal 1
    _(members[0]).must_equal member
  end
end
