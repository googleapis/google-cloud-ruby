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

describe Google::Cloud::Bigtable::ColumnFamilyMap, :mock_bigtable do
  let(:cfm) { Google::Cloud::Bigtable::ColumnFamilyMap.from_grpc column_families_grpc }
  let(:deprecated_gc_rule_warning) { "The positional gc_rule argument is deprecated. Use the named gc_rule argument instead.\n" }
  let(:frozen_error_class) { defined? FrozenError ? FrozenError : RuntimeError }

  it "adds a column family" do
    cf_name = "new-cf"

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 1
    cfm.add cf_name, gc_rule: gc_rule

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 4
    cf = cfs[cf_name]
    _(cf).must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    _(cf.gc_rule).must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    _(cf.gc_rule).must_equal gc_rule.to_grpc
  end

  it "adds a column family without gc_rule" do
    cf_name = "new-cf"

    cfm.add cf_name

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 4
    cf = cfs[cf_name]
    _(cf).must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    _(cf.gc_rule).must_be :nil?
  end

  it "adds a column family with the deprecated gc_rule" do
    cf_name = "new-cf"

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 1
    expect do
      cfm.add cf_name, gc_rule
    end.must_output "", deprecated_gc_rule_warning

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 4
    cf = cfs[cf_name]
    _(cf).must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    _(cf.gc_rule).must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    _(cf.gc_rule).must_equal gc_rule.to_grpc
  end

  it "doesn't add a column family if one already exists" do
    cf_name = cfm.names.first

    error = expect { cfm.add cf_name }.must_raise ArgumentError
    _(error.message).must_equal "column family \"cf1\" already exists"
  end

  it "doesn't add a column family when frozen" do
    cf_name = "new-cf"

    cfm.freeze

    error = expect { cfm.add cf_name }.must_raise frozen_error_class
    _(error.message).must_match(/can't modify frozen Hash/)
  end

  it "updates a column family" do
    cf_name = cfm.names.first

    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 1
    cfm.update cf_name, gc_rule: gc_rule

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 3
    cf = cfs[cf_name]
    _(cf).must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    _(cf.gc_rule).must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    _(cf.gc_rule).must_equal gc_rule.to_grpc
  end

  it "updates a column family without gc_rule" do
    cf_name = cfm.names.first

    cfm.update cf_name

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 3
    cf = cfs[cf_name]
    _(cf).must_be_kind_of Google::Bigtable::Admin::V2::ColumnFamily
    _(cf.gc_rule).must_be :nil?
  end

  it "doesn't update a column family if one doesn't exist" do
    cf_name = "new-cf"

    error = expect { cfm.update cf_name }.must_raise ArgumentError
    _(error.message).must_equal "column family \"new-cf\" does not exist"
  end

  it "doesn't update a column family when frozen" do
    cf_name = cfm.names.first

    cfm.freeze

    error = expect { cfm.update cf_name }.must_raise frozen_error_class
    _(error.message).must_match(/can't modify frozen Hash/)
  end

  it "deletes a column family" do
    cf_name = cfm.names.first

    cfm.delete cf_name

    cfs = cfm.to_grpc
    _(cfs.length).must_equal 2
    cf = cfs[cf_name]
    _(cf).must_be :nil?
  end

  it "doesn't delete a column family if one doesn't exist" do
    cf_name = "new-cf"

    error = expect { cfm.delete cf_name }.must_raise ArgumentError
    _(error.message).must_equal "column family \"new-cf\" does not exist"
  end

  it "doesn't delete a column family when frozen" do
    cf_name = cfm.names.first

    cfm.freeze

    error = expect { cfm.delete cf_name }.must_raise frozen_error_class
    _(error.message).must_match(/can't modify frozen Hash/)
  end
end
