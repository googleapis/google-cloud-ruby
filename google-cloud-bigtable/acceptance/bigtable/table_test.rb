# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "bigtable_helper"

describe "Instance Tables", :bigtable do
  let(:instance_id) { bigtable_instance_id }

  it "create, list all, get table and delete table" do
    table_id = "test-table-#{random_str}"

    table = bigtable.create_table(instance_id, table_id) do |cfs|
      cfs.add("cf", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(3))
    end

    _(table).must_be_kind_of Google::Cloud::Bigtable::Table

    tables = bigtable.tables(instance_id).to_a
    _(tables).wont_be :empty?
    tables.each do |t|
      _(t).must_be_kind_of Google::Cloud::Bigtable::Table
    end

    table = bigtable.table(instance_id, table_id, perform_lookup: true)
    _(table).must_be_kind_of Google::Cloud::Bigtable::Table

    table.delete
    _(table.exists?).must_equal false
  end

  it "create table with initial splits and granularity" do
    table_id = "test-table-#{random_str}"
    initial_splits = ["customer-001", "customer-005", "customer-010"]

    table = bigtable.create_table(
        instance_id,
        table_id,
        initial_splits: initial_splits,
        granularity: :MILLIS) do |cfs|
      cfs.add("cf", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    _(table).must_be_kind_of Google::Cloud::Bigtable::Table
    _(table.granularity_millis?).must_equal true
    _(table.exists?).must_equal true

    entries = 10.times.map do |i|
      key = "customer-#{"%03d" % (i+1).to_s}"
      table.new_mutation_entry(key).set_cell("cf", "field1", "v-#{i+1}")
    end

    responses = table.mutate_rows(entries)
    _(responses.count).must_equal entries.count
    responses.each { |r| _(r.status.code).must_equal 0 }

    sample_keys = table.sample_row_keys.to_a.map(&:key)

    initial_splits.each do |key|
      _(sample_keys).must_include(key)
    end

    table.delete
  end

  it "creates a table with column families" do
    table_id = "test-table-#{random_str}"

    table = bigtable.create_table(instance_id, table_id) do |cfs|
      cfs.add("cf1") # default service value for GcRule
      cfs.add("cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5))
      cfs.add("cf3", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600))
    end

    column_families = table.column_families
    _(column_families).must_be_kind_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(column_families).must_be :frozen?
    _(column_families.count).must_equal 3

    cf1 = column_families["cf1"]
    _(cf1).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf1.gc_rule).must_be :nil?

    cf2 = column_families["cf2"]
    _(cf2).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf2.gc_rule.max_versions).must_equal 5

    cf3 = column_families["cf3"]
    _(cf3).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf3.gc_rule.max_age).must_equal 600

    table.delete
  end

  describe "replication consistency" do
    let(:table) { bigtable_read_table }

    it "generate consistency token and check consistency" do
      token = table.generate_consistency_token
      _(token).wont_be :nil?
      result = table.check_consistency(token)
      _([true, false]).must_include result
    end

    it "generate consistency token and check consistency wail unitil complete" do
      result = table.wait_for_replication(timeout: 600, check_interval: 3)
      _([true, false]).must_include result
    end
  end

  describe "IAM policies and permissions" do
    let(:service_account) { bigtable.service.credentials.client.issuer }
    let(:table) { bigtable_read_table }

    it "tests permissions" do
      roles = ["bigtable.tables.delete", "bigtable.tables.get"]
      permissions = table.test_iam_permissions(roles)
      _(permissions).must_be_kind_of Array
      _(permissions).must_equal roles
    end

    it "allows policy to be updated on a table" do
      _(table.policy).must_be_kind_of Google::Cloud::Bigtable::Policy

      _(service_account).wont_be :nil?

      role = "roles/bigtable.user"
      member = "serviceAccount:#{service_account}"

      policy = table.policy
      policy.add(role, member)
      updated_policy = table.update_policy(policy)

      _(updated_policy.role(role)).wont_be :nil?

      role_member = table.policy.role(role).select { |m| m == member }
      _(role_member.size).must_equal 1
    end
  end
end
