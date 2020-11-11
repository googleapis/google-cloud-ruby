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
  let(:roles) { ["bigquery.tables.delete", "bigquery.tables.get"] }
  let(:role) { "roles/bigquery.dataOwner" }
  let(:service_account) { bigquery.service.credentials.client.issuer }
  let(:member) { "serviceAccount:#{service_account}" }

  it "allows permissions to be tested and policy to be updated" do
    permissions = table.test_iam_permissions roles
    _(permissions).must_equal roles
    _(permissions).must_be :frozen?

    policy = table.policy # get
    _(policy).must_be_kind_of Google::Cloud::Bigquery::Policy
    _(policy).must_be :frozen?
    etag_1 = policy.etag
    _(etag_1).wont_be :empty?
    _(etag_1).must_be :frozen?
    _(policy.bindings).must_be :empty?
    _(policy.bindings).must_be :frozen?
    _(policy.bindings.find { |b| b.role == role }).must_be :nil?

    # update
    policy = table.update_policy do |p|
      _(p.bindings).must_be :empty?
      _(p.bindings).wont_be :frozen?
      _(p).wont_be :frozen?
      p.grant role: role, members: member
      binding = p.bindings.find { |b| b.role == role }
      binding.members << member # duplicate member will not be added to request
    end

    _(policy).must_be :frozen?
    etag_2 = policy.etag
    _(etag_2).wont_be :empty?
    _(etag_2).must_be :frozen?
    _(etag_2).wont_equal etag_1
    _(policy.bindings).must_be :frozen?
    _(policy.bindings.count).must_equal 1
    _(policy.bindings[0]).must_be :frozen?
    binding = policy.bindings.find { |b| b.role == role }
    _(binding).must_equal policy.bindings[0]
    _(binding).must_be_kind_of Google::Cloud::Bigquery::Policy::Binding
    _(binding).must_be :frozen?
    members = binding.members
    _(members).must_be_kind_of Array
    _(members).must_be :frozen?
    _(members.count).must_equal 1
    _(members[0]).must_equal member
    _(members[0]).must_be :frozen?

    # update
    policy = table.update_policy do |p|
      p.revoke role: role, members: member
    end

    policy = table.policy # get
    _(policy.bindings).must_be :empty?
    _(policy.bindings.find { |b| b.role == role }).must_be :nil?
  end
end
