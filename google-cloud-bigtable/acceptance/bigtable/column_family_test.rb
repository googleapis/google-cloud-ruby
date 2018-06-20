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

describe "Table ColumnFamily", :bigtable do
  let(:instance) { bigtable_instance }

  before(:all) do
    @table_id = "test-table-#{random_str}"
    @table = instance.create_table(@table_id) do |cfs|
      cfs.add('cf1', Google::Cloud::Bigtable::GcRule.max_age(600))
      cfs.add('cf2', Google::Cloud::Bigtable::GcRule.max_versions(1))
    end
  end

  it "create column family" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
    cf = @table.column_family("cfcreate", gc_rule).create

    cf.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    cf.name.must_equal "cfcreate"
    cf.gc_rule.max_versions.must_equal 1

    instance.table(@table_id).column_families.find{|cf| cf.name == "cfcreate"}.wont_be :nil?
  end

  it "update column family" do
    cf = @table.column_families.find{|cf| cf.name == "cf1"}
    cf.gc_rule.max_age = 300
    updated_cf = cf.save
    updated_cf.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    updated_cf.gc_rule.max_age.must_equal 300

    @table.reload!
    cf = @table.column_families.find{|cf| cf.name == "cf1"}
    cf.gc_rule.max_age.must_equal 300
  end

  it "delete column family" do
    cf = @table.column_families.find{|cf| cf.name == "cf2"}
    cf.delete.must_equal true

    @table.reload!
    @table.column_families.find{|cf| cf.name == "cf2"}.must_be :nil?
  end

  it "create column family with union gc rules" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(300)
    gc_union_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)

    cf = @table.column_family("cfunion", gc_union_rule).create

    cf.gc_rule.union.rules.length.must_equal 2
  end

  it "create column family with intersection gc rules" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(1)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(600)
    gc_intersection_rule = Google::Cloud::Bigtable::GcRule.intersection(
      gc_rule_1, gc_rule_2
    )

    cf = @table.column_family("cfintersect", gc_intersection_rule).create

    cf.gc_rule.intersection.rules.length.must_equal 2
  end
end
