# frozen_string_literal: true

# Copyright 2025 Google LLC
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

require "google/cloud/bigtable/admin/v2/bigtable_table_admin"

describe ::Google::Cloud::Bigtable::Admin::V2::GcRule do
  let(:gc_rule) { ::Google::Cloud::Bigtable::Admin::V2::GcRule.new }
  let(:intersection) { ::Google::Cloud::Bigtable::Admin::V2::GcRule::Intersection.new }
  let(:union) { ::Google::Cloud::Bigtable::Admin::V2::GcRule::Union.new }
  let(:max_age) { ::Google::Protobuf::Duration.new(seconds: 60) }
  let(:max_num_versions) { 10 }

  it "warns on bracket change" do
    gc_rule.max_num_versions = max_num_versions
    assert_equal(max_num_versions, gc_rule.max_num_versions)
    assert_output(nil, /Setting GcRule#intersection automatically clears GcRule#max_num_versions/) do
      gc_rule["intersection"] = intersection
    end
    assert_equal(0, gc_rule.max_num_versions)
  end

  it "does not warn on bracket change if the gcrule was empty before" do
    assert_output(nil, "") do
      gc_rule["max_num_versions"] = max_num_versions
    end
  end

  it "does not warn on bracket change if the gcrule was unset before" do
    gc_rule.max_num_versions = max_num_versions
    assert_equal(max_num_versions, gc_rule.max_num_versions)
    gc_rule.max_num_versions = nil
    assert_equal(0, gc_rule.max_num_versions)
    assert_output(nil, "") do
      gc_rule["intersection"] = intersection
    end
  end

  it "does not warn on bracket change if the same key was set before" do
    assert_output(nil, "") do
      gc_rule["max_num_versions"] = max_num_versions
      gc_rule["max_num_versions"] = max_num_versions + 1
    end
  end

  it "warns on max_num_versions change" do
    gc_rule.union = union
    refute_nil(gc_rule.union)
    assert_output(nil, /Setting GcRule#max_num_versions automatically clears GcRule#union/) do
      gc_rule.max_num_versions = max_num_versions
    end
    assert_nil(gc_rule.union)
  end

  it "does not warn on max_num_versions change if the gcrule was empty before" do
    assert_output(nil, "") do
      gc_rule.max_num_versions = max_num_versions
    end
  end

  it "does not warn on max_num_versions change if the same key was set before" do
    assert_output(nil, "") do
      gc_rule.max_num_versions = max_num_versions
      gc_rule.max_num_versions = max_num_versions + 1
    end
  end

  it "warns on max_age change" do
    gc_rule.max_num_versions = max_num_versions
    assert_equal(max_num_versions, gc_rule.max_num_versions)
    assert_output(nil, /Setting GcRule#max_age automatically clears GcRule#max_num_versions/) do
      gc_rule.max_age = max_age
    end
    assert_equal(0, gc_rule.max_num_versions)
  end

  it "warns on intersection change" do
    gc_rule.max_age = max_age
    refute_nil(gc_rule.max_age)
    assert_output(nil, /Setting GcRule#intersection automatically clears GcRule#max_age/) do
      gc_rule.intersection = intersection
    end
    assert_nil(gc_rule.max_age)
  end

  it "warns on union change" do
    gc_rule.intersection = intersection
    refute_nil(gc_rule.intersection)
    assert_output(nil, /Setting GcRule#union automatically clears GcRule#intersection/) do
      gc_rule.union = union
    end
    assert_nil(gc_rule.intersection)
  end

  it "includes the source code link in the warning" do
    gc_rule.max_num_versions = max_num_versions
    assert_output(nil, /gcrule_oneof_test\.rb/) do
      gc_rule.intersection = intersection
    end
  end

  it "constructs max_num_versions" do
    obj = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_num_versions(max_num_versions)
    assert_equal(max_num_versions, obj.max_num_versions)
  end

  it "constructs max_age" do
    obj = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_age(max_age)
    assert_equal(max_age, obj.max_age)
  end

  it "constructs intersection" do
    obj1 = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_num_versions(max_num_versions)
    obj2 = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_age(max_age)
    obj = ::Google::Cloud::Bigtable::Admin::V2::GcRule.intersection(obj1, obj2)
    assert_equal(obj1, obj.intersection.rules[0])
    assert_equal(obj2, obj.intersection.rules[1])
  end

  it "constructs union" do
    obj1 = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_num_versions(max_num_versions)
    obj2 = ::Google::Cloud::Bigtable::Admin::V2::GcRule.max_age(max_age)
    obj = ::Google::Cloud::Bigtable::Admin::V2::GcRule.union(obj1, obj2)
    assert_equal(obj1, obj.union.rules[0])
    assert_equal(obj2, obj.union.rules[1])
  end
end
