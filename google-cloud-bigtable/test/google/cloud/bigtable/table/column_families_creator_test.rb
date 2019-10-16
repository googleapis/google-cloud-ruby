# frozen_string_literal: true

# Copyright 2019 Google LLC
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

describe Google::Cloud::Bigtable::Table::ColumnFamiliesCreator, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:table_id) { "test-table" }
  let(:creator) { Google::Cloud::Bigtable::Table::ColumnFamiliesCreator.new }

  it "adds a column family" do
    cf_name = "new-cf"
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
    creator.add(cf_name, gc_rule)

    cfs = creator.to_grpc
    cfs.length.must_equal 1
    cf = cfs[cf_name]
    cf.must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    cf.gc_rule.must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    cf.gc_rule.must_equal gc_rule.to_grpc
  end

  it "adds a column family without gc_rule" do
    cf_name = "new-cf"
    creator.add(cf_name)

    cfs = creator.to_grpc
    cfs.length.must_equal 1
    cf = cfs[cf_name]
    cf.must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    cf.gc_rule.must_be :nil?
  end
end
