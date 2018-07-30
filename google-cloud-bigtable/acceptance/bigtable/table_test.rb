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
  let(:instance) { bigtable_instance }

  it "create, list all, get table and delete table" do
    table_id = "test-table-#{random_str}"

    table = instance.create_table(table_id) do |cfs|
      cfs.add("cf", Google::Cloud::Bigtable::GcRule.max_versions(3))
    end

    table.must_be_kind_of Google::Cloud::Bigtable::Table

    tables = instance.tables.to_a
    tables.wont_be :empty?
    tables.each do |t|
      t.must_be_kind_of Google::Cloud::Bigtable::Table
    end

    table = instance.table(table_id, skip_lookup: false)
    table.must_be_kind_of Google::Cloud::Bigtable::Table

    table.delete
    table = instance.table(table_id)
    table.exists?.must_equal false
  end

  it "create table with initial splits" do
    table_id = "test-table-#{random_str}"

    initial_splits = ["customer_1", "customer_10000"]

    table = instance.create_table(table_id, initial_splits: initial_splits) do |cfs|
      cfs.add("cf", Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    table.must_be_kind_of Google::Cloud::Bigtable::Table
    instance.table(table_id, view: :FULL, skip_lookup: false).wont_be :nil?
    table.delete
  end

  it "create table with time granularity" do
    table_id = "test-table-#{random_str}"

    table = instance.create_table(table_id, granularity: :MILLIS) do |cfs|
      cfs.add("cf", Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    table.must_be_kind_of Google::Cloud::Bigtable::Table
    table.granularity_millis?.must_equal true
    instance.table(table_id, view: :NAME_ONLY, skip_lookup: false).wont_be :nil?
    table.delete
  end

  it "modify column families" do
    table_id = "test-table-#{random_str}"

    table = instance.create_table(table_id) do |cfs|
      cfs.add("cf1", Google::Cloud::Bigtable::GcRule.max_versions(1))
      cfs.add("cf2", Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    modifications = []
    modifications << Google::Cloud::Bigtable::ColumnFamily.create_modification(
      "cf3", Google::Cloud::Bigtable::GcRule.max_age(600)
    )

    modifications << Google::Cloud::Bigtable::ColumnFamily.update_modification(
      "cf1", Google::Cloud::Bigtable::GcRule.max_versions(5)
    )

    modifications << Google::Cloud::Bigtable::ColumnFamily.drop_modification("cf2")

    updated_table = table.modify_column_families(modifications)
    updated_table.must_be_kind_of Google::Cloud::Bigtable::Table

    column_families = updated_table.column_families
    cf3 = column_families.find{|c| c.name == "cf3"}
    cf3.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    cf3.gc_rule.max_age.must_equal 600

    cf1 = column_families.find{|c| c.name == "cf1"}
    cf1.gc_rule.max_versions.must_equal 5

    column_families.find{|c| c.name == "cf2"}.must_be :nil?

    table.delete
  end

  describe "drop rows" do
    it "delete all rows" do
      table_id = "test-table-#{random_str}"
      table = create_table(table_id, row_count: 2)
      table.delete_all_rows.must_equal true

      rows = table.read_rows.to_a
      rows.must_be_empty
    end

    it "delete rows by prefix" do
      table_id = "test-table-#{random_str}"
      table = create_table(table_id, row_count: 2)
      table.delete_rows_by_prefix("test-1").must_equal true

      rows = table.read_rows.to_a
      rows.length.must_equal 1
    end
  end

  describe "replication consistency" do
    let(:table) { bigtable_table }

    it "generate consistency token and check consistency" do
      token = table.generate_consistency_token
      token.wont_be :nil?
      result = table.check_consistency(token)
      [true, false].must_include result
    end

    it "generate consistency token and check consistency wail unitil complete" do
      result = table.wait_for_replication(timeout: 600, check_interval: 3)
      [true, false].must_include result
    end
  end
end
