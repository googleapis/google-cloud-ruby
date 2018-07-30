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

describe "DataClient Read Modify Write Row", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "append to row cell value" do
    row_key = "readmodify-#{random_str}"
    qualifier = "readmodify"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "Value")
    table.mutate_row(entry)

    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.append(
      family, qualifier, " append-xyz"
    )

    row = table.read_modify_write_row(row_key, rule)
    row.cells[family].first.value.must_equal "Value append-xyz"
  end

  it "increment row cell value" do
    row_key = "readmodify-#{random_str}"
    qualifier = "readmodify"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, 100)
    table.mutate_row(entry)

    rule = Google::Cloud::Bigtable::ReadModifyWriteRule.increment(
      family, qualifier, 1
    )

    row = table.read_modify_write_row(row_key, rule)
    row.cells[family].first.to_i.must_equal 101
  end
end
