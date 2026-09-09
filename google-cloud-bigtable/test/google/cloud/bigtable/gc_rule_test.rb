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

describe Google::Cloud::Bigtable::GcRule, :mock_bigtable do
  it "creates a max age gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_age(100)

    _(gc_rule).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(gc_rule.max_age).must_equal 100

    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(
      max_age: Google::Protobuf::Duration.new(seconds: 100)
    )
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "updates a max age gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule.max_age = 200

    _(gc_rule.max_age).must_equal 200
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(
      max_age: Google::Protobuf::Duration.new(seconds: 200)
    )
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "updates a max age gc rule using microseconds" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_age(100.001)

    _(gc_rule.max_age).must_equal 100.001
    gc_rule.max_age = 200.999999999

    _(gc_rule.max_age).must_equal 200.999999999
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(
      max_age: Google::Protobuf::Duration.new(seconds: 200, nanos: 999999999)
    )
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "creates a max versions gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)

    _(gc_rule).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(gc_rule.max_versions).must_equal 3

    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(
      max_num_versions: 3
    )
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "updates a max versions gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)

    gc_rule.max_versions = 4
    _(gc_rule.max_versions).must_equal 4

    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(
      max_num_versions: 4
    )
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "creates a union gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)

    _(gc_rule).must_be_kind_of Google::Cloud::Bigtable::GcRule

    rules = gc_rule.union
    _(rules).must_be_kind_of Array
    _(rules.count).must_equal 2
    _(rules[0]).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(rules[0].max_versions).must_equal 3
    _(rules[1]).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(rules[1].max_age).must_equal 100

    union_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule::Union.new(rules: [
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3),
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 100))
    ])
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(union: union_grpc)
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "updates a union gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)


    gc_rule_3 = Google::Cloud::Bigtable::GcRule.max_versions(4)
    gc_rule_4 = Google::Cloud::Bigtable::GcRule.max_age(200)

    gc_rule.union = [gc_rule_3, gc_rule_4]
    rules = gc_rule.union
    _(rules.count).must_equal 2
    _(rules[0].max_versions).must_equal 4
    _(rules[1].max_age).must_equal 200

    union_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule::Union.new(rules: [
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 4),
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 200))
    ])
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(union: union_grpc)
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "creates a intersection gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.intersection(gc_rule_1, gc_rule_2)

    rules = gc_rule.intersection
    _(rules).must_be_kind_of Array
    _(rules.count).must_equal 2
    _(rules[0]).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(rules[0].max_versions).must_equal 3
    _(rules[1]).must_be_kind_of Google::Cloud::Bigtable::GcRule
    _(rules[1].max_age).must_equal 100

    intersection_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule::Intersection.new(rules: [
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3),
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 100))
    ])
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(intersection: intersection_grpc)
    _(gc_rule.to_grpc).must_equal expected_grpc
  end

  it "updates a intersection gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.intersection(gc_rule_1, gc_rule_2)


    gc_rule_3 = Google::Cloud::Bigtable::GcRule.max_versions(4)
    gc_rule_4 = Google::Cloud::Bigtable::GcRule.max_age(200)

    gc_rule.intersection = [gc_rule_3, gc_rule_4]
    rules = gc_rule.intersection
    _(rules.count).must_equal 2
    _(rules[0].max_versions).must_equal 4
    _(rules[1].max_age).must_equal 200

    intersection_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule::Intersection.new(rules: [
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_num_versions: 4),
      Google::Cloud::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 200))
    ])
    expected_grpc = Google::Cloud::Bigtable::Admin::V2::GcRule.new(intersection: intersection_grpc)
    _(gc_rule.to_grpc).must_equal expected_grpc
  end
end
