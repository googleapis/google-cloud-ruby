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

describe "DataClient Read Rows Filters", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "strip value filter" do
    filter = table.filter.strip_value

    rows = table.read_rows(filter: filter, limit: 1).to_a
    rows.wont_be :empty?
    cell = rows.first.cells[family].first
    cell.value.must_be :empty?
  end

  it "key regex filter" do
    filter = table.filter.key("test-1.*")
    rows = table.read_rows(filter: filter).to_a
    rows.wont_be :empty?
    rows.each do |r|
      r.key.start_with?("test-1").must_equal true
    end
  end

  it "sample filter" do
    filter = table.filter.sample(0.2)
    rows = table.read_rows(filter: filter).to_a
    rows.wont_be :empty?
  end

  it "family filter" do
    filter = table.filter.family("c.*")
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells.each do |family, _|
        family.start_with?("c").must_equal true
      end
    end
  end

  it "family filter" do
    filter = table.filter.qualifier("field.*")
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.qualifier.start_with?("field").must_equal true
      end
    end
  end

  it "value filter" do
    filter = table.filter.value("value.*")
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.value.start_with?("value").must_equal true
      end
    end
  end

  it "cells per row offset filter" do
    filter = table.filter.cells_per_row_offset(1)
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].length.must_equal 1
    end
  end

  it "cells per row filter" do
    filter = table.filter.cells_per_row(1)
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].length.must_equal 1
    end
  end

  it "cells per column filter" do
    filter = table.filter.cells_per_column(1)
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].map(&:qualifier).length.must_equal 1
    end
  end

  it "timestamp range filter" do
    timestamp = Time.now.to_i * 1000
    entry = table.new_mutation_entry("timestamp-#{random_str}")
    entry.set_cell(family, "timestamp", "timestamp range test", timestamp: timestamp)
    table.mutate_row(entry)

    filter = table.filter.timestamp_range(from: timestamp)
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.timestamp.must_be :>=, timestamp
      end
    end
  end

  it "value range filter" do
    range = table.new_value_range.from("value-1").to('value-2')

    filter = table.filter.value_range(range)
    rows = table.read_rows(filter: filter).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.value.must_be :>=, "value-1"
        cell.value.must_be :<=, "value-2"
      end
    end
  end

  it "column range filter" do
    range = table.new_column_range(family).from("field1")

    filter = table.filter.column_range(range)
    rows = table.read_rows(filter: filter, limit: 2).to_a
    rows.wont_be :empty?

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.qualifier.must_be :>=, "field1"
      end
    end
  end

  it "conditional filter" do
    predicate = table.filter.key("test-1")
    label = table.filter.label("test")
    strip_value = table.filter.strip_value

    condition = table.filter.condition(predicate)
    condition.on_match(label).otherwise(strip_value)

    rows = table.read_rows(filter: condition).to_a
    rows.wont_be :empty?
  end

  it "chain filter" do
    filter = table.filter.chain.key("test-.*").strip_value.label("test")

    rows = table.read_rows(filter: filter).to_a
    rows.wont_be :empty?
  end

  it "interleave filter" do
    filter = table.filter.interleave.key("test-.*").cells_per_row(1)

    rows = table.read_rows(filter: filter).to_a
    rows.wont_be :empty?
  end
end
