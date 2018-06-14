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
  it "create max age gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule.grpc.must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    gc_rule.max_age.must_equal 100

    expected_grpc = Google::Bigtable::Admin::V2::GcRule.new(
      max_age: Google::Protobuf::Duration.new(seconds: 100)
    )
    gc_rule.grpc.must_equal expected_grpc
  end

  it "create max versions gc rule" do
    gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)

    gc_rule.grpc.must_be_kind_of Google::Bigtable::Admin::V2::GcRule
    gc_rule.max_versions.must_equal 3

    expected_grpc = Google::Bigtable::Admin::V2::GcRule.new(
      max_num_versions: 3
    )
    gc_rule.grpc.must_equal expected_grpc
  end

  it "create union gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)

    gc_rule.grpc.must_be_kind_of Google::Bigtable::Admin::V2::GcRule

    union = Google::Bigtable::Admin::V2::GcRule::Union.new(rules: [
      Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3),
      Google::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 100))
    ])
    gc_rule.union.must_equal union

    expected_grpc = Google::Bigtable::Admin::V2::GcRule.new(union: union)
    gc_rule.grpc.must_equal expected_grpc
  end

  it "create intersection gc rule" do
    gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_versions(3)
    gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_age(100)

    gc_rule = Google::Cloud::Bigtable::GcRule.intersection(gc_rule_1, gc_rule_2)

    gc_rule.grpc.must_be_kind_of Google::Bigtable::Admin::V2::GcRule

    intersection = Google::Bigtable::Admin::V2::GcRule::Intersection.new(rules: [
      Google::Bigtable::Admin::V2::GcRule.new(max_num_versions: 3),
      Google::Bigtable::Admin::V2::GcRule.new(max_age: Google::Protobuf::Duration.new(seconds: 100))
    ])
    gc_rule.intersection.must_equal intersection

    expected_grpc = Google::Bigtable::Admin::V2::GcRule.new(intersection: intersection)
    gc_rule.grpc.must_equal expected_grpc
  end
end
