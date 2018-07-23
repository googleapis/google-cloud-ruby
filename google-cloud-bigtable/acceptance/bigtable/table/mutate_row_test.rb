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

describe "DataClient Mutate Row", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "set cell and delete cells" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")

    table.mutate_row(entry).must_equal true
    row = table.read_row(row_key)
    cell = row.cells[family].select{|v| v.qualifier == qualifier}.first
    cell.must_be_kind_of Google::Cloud::Bigtable::Row::Cell

    # Delete cell
    entry = table.new_mutation_entry(row_key)
    entry.delete_cells(family, qualifier)

    table.mutate_row(entry)
    table.read_row(row_key).must_be :nil?
  end

  it "set cell with timestamp and delete cells with timestamp range" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"
    timestamp = (Time.now.to_i * 1000).floor

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp
    ).set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp + 1000
    ).set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp + 2000
    )

    table.mutate_row(entry).must_equal true
    row = table.read_row(row_key)
    row.cells[family].select{|v| v.qualifier == qualifier}.length.must_equal 3

    # Delete cell
    entry = table.new_mutation_entry(row_key)
    entry.delete_cells(
      family, qualifier, timestamp_from: timestamp, timestamp_to: timestamp + 2000
    )

    table.mutate_row(entry)
    row = table.read_row(row_key)
    row.cells[family].select{|v| v.qualifier == qualifier}.length.must_equal 1
  end

  it "delete all cells from specified column family" do
    postfix = random_str
    row_key = "deletecells-#{postfix}"
    qualifier = "deletecells-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")
    table.mutate_row(entry).must_equal true

    entry = table.new_mutation_entry(row_key).delete_from_family(family)
    table.mutate_row(entry).must_equal true
    table.read_row(row_key).must_be :nil?
  end

  it "delete row" do
    postfix = random_str
    row_key = "deleterow-#{postfix}"
    qualifier = "deleterow-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")
    table.mutate_row(entry).must_equal true

    entry = table.new_mutation_entry(row_key).delete_from_row
    table.mutate_row(entry).must_equal true
    table.read_row(row_key).must_be :nil?
  end

  it "set integer cell value" do
    postfix = random_str
    row_key = "introw-#{postfix}"
    qualifier = "introw-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, 100)
    table.mutate_row(entry).must_equal true

    row = table.read_row(row_key)
    cell = row.cells[family].select{|v| v.qualifier == qualifier}.first
    cell.to_i.must_equal 100
  end
end
