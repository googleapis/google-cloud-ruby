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
  it "knows the identifiers" do
    cf_name = "cf"
    gc_rule_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3)
    cf_grpc = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new(
      gc_rule: gc_rule_grpc
    )
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      cf_name
    )

    _(column_family).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(column_family.gc_rule).wont_be :nil?
    _(column_family.gc_rule).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(column_family.gc_rule.max_versions).must_equal 3
    _(column_family.name).must_equal cf_name
  end

  it "set column family gc rule" do
    cf_grpc = Google::Cloud::Bigtable::Admin::V2::ColumnFamily.new
    column_family = Google::Cloud::Bigtable::ColumnFamily.from_grpc(
      cf_grpc,
      "cf"
    )

    _(column_family.gc_rule).must_be :nil?

    column_family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
    _(column_family.gc_rule).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(column_family.gc_rule.max_versions).must_equal 3
  end
end
