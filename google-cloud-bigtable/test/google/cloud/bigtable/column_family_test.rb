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


require "helper"

describe Google::Cloud::Bigtable::ColumnFamily, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  it "knows the identifiers" do
    cf_name = "cf"
    gc_rule_grpc = Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
    cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new(
      gc_rule: gc_rule_grpc
    )
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      bigtable.service,
      name: cf_name,
      instance_id: instance_id,
      table_id: table_id
    )

    column_family.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    column_family.gc_rule.wont_be :nil?
    column_family.gc_rule.must_be_kind_of Google::Cloud::Bigtable::GcRule
    column_family.gc_rule.max_versions.must_equal 3
    column_family.name.must_equal cf_name
    column_family.table_id.must_equal table_id
    column_family.instance_id.must_equal instance_id
  end

  it "set column family gc rule" do
    cf_grpc = Google::Bigtable::Admin::V2::ColumnFamily.new
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      bigtable.service,
      name: "cf",
      instance_id: instance_id,
      table_id: table_id
    )

    column_family.gc_rule.must_be :nil?

    column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
    column_family.gc_rule.must_be_kind_of Google::Cloud::Bigtable::GcRule
    column_family.gc_rule.max_versions.must_equal 3
  end
end
