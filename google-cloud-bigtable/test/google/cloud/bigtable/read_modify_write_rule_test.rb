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

describe Google::Cloud::Bigtable::ReadModifyWriteRule, :read_modifu_write_rue, :mock_bigtable do
  let(:family) { "test-cf" }
  let(:qualifier) { "field1" }

  it "create instance of rule" do
    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.new(family, qualifier)
    grpc = rule.to_grpc
    grpc.family_name.must_equal family
    grpc.column_qualifier.must_equal qualifier
  end

  it "create append rule instance" do
    append_value = "append-xyz"
    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.append(
      family, qualifier, append_value
    )

    rule.must_be_kind_of Google::Cloud::Bigtable::ReadModifyWriteRule
    grpc = rule.to_grpc
    grpc.family_name.must_equal family
    grpc.column_qualifier.must_equal qualifier
    grpc.append_value.must_equal append_value
  end

  it "create increment amount instance" do
    increment_amount = 100
    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.increment(
      family, qualifier, increment_amount
    )

    rule.must_be_kind_of Google::Cloud::Bigtable::ReadModifyWriteRule
    grpc = rule.to_grpc
    grpc.family_name.must_equal family
    grpc.column_qualifier.must_equal qualifier
    grpc.increment_amount.must_equal increment_amount
  end

  it "set append value field" do
    value = "append-xyz"
    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.new(family, qualifier)
    rule.append(value)

    grpc = rule.to_grpc
    grpc.append_value.must_equal value
  end

  it "set increment value field" do
    amount = 100
    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.new(family, qualifier)
    rule.increment(amount)

    grpc = rule.to_grpc
    grpc.increment_amount.must_equal amount
  end
end
