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


require "helper"

describe Google::Cloud::Bigtable::Table::ColumnFamilyMap, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  it "adds a column family" do
    cfs_map = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new(bigtable.service, instance_id, table_id)
    cfs_map.must_be :empty?

    cf_name = "new-cf"
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
    cfs_map.add(cf_name, gc_rule)

    cfs_map.length.must_equal 1
    cf = cfs_map[cf_name]
    cf.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    cf.gc_rule.must_be_kind_of Google::Cloud::Bigtable::GcRule
    cf.gc_rule.to_grpc.must_equal gc_rule.to_grpc
  end

  it "adds a column family without gc_rule" do
    cfs_map = Google::Cloud::Bigtable::Table::ColumnFamilyMap.new(bigtable.service, instance_id, table_id)
    cfs_map.must_be :empty?

    cf_name = "new-cf"
    cfs_map.add(cf_name)

    cfs_map.length.must_equal 1
    cf = cfs_map[cf_name]
    cf.must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    cf.gc_rule.must_be :nil?
  end
end
