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
  let(:table) { bigtable_mutation_table }

  it "raises Google::Cloud::InvalidArgumentError for invalid id for collection columnFamilies" do
    postfix = random_str

    # Set cell
    entry = table.new_mutation_entry("setcell-#{postfix}")
    entry.set_cell(family + "&  *^(*&^%^%&^", "mutate-row-#{postfix}", "mutatetest value #{postfix}")
    assert_raises Google::Cloud::InvalidArgumentError do
      table.mutate_row(entry)
    end
  end

  it "set cell and delete cells" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")

    _(table.mutate_row(entry)).must_equal true
    row = table.read_row(row_key)
    cell = row.cells[family].select{|v| v.qualifier == qualifier}.first
    _(cell).must_be_kind_of Google::Cloud::Bigtable::Row::Cell

    # Delete cell
    entry = table.new_mutation_entry(row_key)
    entry.delete_cells(family, qualifier)

    table.mutate_row(entry)
    _(table.read_row(row_key)).must_be :nil?
  end

  it "set cell with timestamp and delete cells with integer timestamp range" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"
    timestamp = (Time.now.to_f * 1000000).round(-3)

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp
    ).set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp + 1000
    ).set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp + 2000
    )

    _(table.mutate_row(entry)).must_equal true
    row = table.read_row(row_key)
    _(row.cells[family].select{|v| v.qualifier == qualifier}.length).must_equal 3

    # Delete cell
    entry = table.new_mutation_entry(row_key)
    entry.delete_cells(
      family, qualifier, timestamp_from: timestamp, timestamp_to: timestamp + 2000
    )

    table.mutate_row(entry)
    row = table.read_row(row_key)
    _(row.cells[family].select{|v| v.qualifier == qualifier}.length).must_equal 1
  end

  it "raises when set_cell with incorrect Time timestamp" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"

    _(table.granularity).must_equal :MILLIS

    # Set cell
    entry = table.new_mutation_entry(row_key)
    err = expect do
      entry.set_cell(
        family, qualifier, "mutatetest value #{postfix}", timestamp: Time.now
      )
    end.must_raise Google::Protobuf::TypeError
    _(err.message).must_match "Expected number type for integral field 'timestamp_micros' (given Time)."
  end

  it "raises when set_cell with incorrect microsecond integer timestamp" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"
    timestamp_micros = (Time.now.to_f * 1000000).round
    timestamp_micros += 1 if (timestamp_micros % 10).zero?

    _(table.granularity).must_equal :MILLIS

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp_micros
    )
    err = expect do
      table.mutate_row(entry)
    end.must_raise Google::Cloud::InvalidArgumentError
    _(err.message).must_match /Timestamp granularity mismatch. Expected a multiple of 1000 \(millisecond granularity\), but got #{timestamp_micros}/
  end

  it "raises when set_cell with incorrect millisecond integer timestamp" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"
    timestamp_millis = (Time.now.to_f * 1000).to_i
    timestamp_millis += 1 if (timestamp_millis % 10).zero?

    _(table.granularity).must_equal :MILLIS

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp_millis
    )
    err = expect do
      table.mutate_row(entry)
    end.must_raise Google::Cloud::InvalidArgumentError
    _(err.message).must_match /Timestamp granularity mismatch. Expected a multiple of 1000 \(millisecond granularity\), but got #{timestamp_millis}/
  end

  it "set_cell with correct microseconds rounded to milliseconds integer timestamp" do
    postfix = random_str
    row_key = "setcell-#{postfix}"
    qualifier = "mutate-row-#{postfix}"
    timestamp_micros = (Time.now.to_f * 1000000).round(-3)

    _(table.granularity).must_equal :MILLIS

    # Set cell
    entry = table.new_mutation_entry(row_key)
    entry.set_cell(
      family, qualifier, "mutatetest value #{postfix}", timestamp: timestamp_micros
    )

    _(table.mutate_row(entry)).must_equal true
    row = table.read_row(row_key)
    cells = row.cells[family].select{|v| v.qualifier == qualifier}
    _(cells.length).must_equal 1
    _(cells.first.timestamp).must_equal timestamp_micros

    # Delete cell
    entry = table.new_mutation_entry(row_key)
    entry.delete_cells family, qualifier
    table.mutate_row(entry)
  end

  it "delete all cells from specified column family" do
    postfix = random_str
    row_key = "deletecells-#{postfix}"
    qualifier = "deletecells-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")
    _(table.mutate_row(entry)).must_equal true

    entry = table.new_mutation_entry(row_key).delete_from_family(family)
    _(table.mutate_row(entry)).must_equal true
    _(table.read_row(row_key)).must_be :nil?
  end

  it "delete row" do
    postfix = random_str
    row_key = "deleterow-#{postfix}"
    qualifier = "deleterow-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, "mutatetest value #{postfix}")
    _(table.mutate_row(entry)).must_equal true

    entry = table.new_mutation_entry(row_key).delete_from_row
    _(table.mutate_row(entry)).must_equal true
    _(table.read_row(row_key)).must_be :nil?
  end

  it "set integer cell value" do
    postfix = random_str
    row_key = "introw-#{postfix}"
    qualifier = "introw-#{postfix}"

    entry = table.new_mutation_entry(row_key)
    entry.set_cell(family, qualifier, 100)
    _(table.mutate_row(entry)).must_equal true

    row = table.read_row(row_key)
    cell = row.cells[family].select{|v| v.qualifier == qualifier}.first
    _(cell.to_i).must_equal 100
  end
end
