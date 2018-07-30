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

describe "DataClient Read Rows", :bigtable do
  let(:family) { "cf" }
  let(:table) { bigtable_table }

  it "read single row" do
    row = table.read_row("test-1")
    row.key.must_equal "test-1"
    row.must_be_kind_of Google::Cloud::Bigtable::Row
  end

  it "read single row with filter" do
    filter = table.filter.label("readtest")
    row = table.read_row("test-1", filter: filter)
    row.must_be_kind_of Google::Cloud::Bigtable::Row

    row.cells.each do |_, cells|
      cells.each do |cell|
        cell.labels.must_equal ["readtest"]
      end
    end
  end

  it "read rows" do
    rows = table.read_rows.map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.wont_be :empty?
  end

  it "read rows with limit" do
    rows = table.read_rows(limit: 2).map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.length.must_equal 2
  end

  it "read rows using row keys" do
    keys = ["test-1", "test-3"]
    rows = table.read_rows(keys: keys).map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.length.must_equal 2
    rows.map(&:key).must_equal keys
  end

  it "read rows with filter" do
    filter = table.filter.key("test-.*")

    rows = table.read_rows(filter: filter).map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.wont_be :empty?
    rows.each do |row|
      row.key.start_with?("test-").must_equal true
    end
  end

  it "read rows with range" do
    range = table.new_row_range.from("test-5")
    rows = table.read_rows(ranges: range).map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.wont_be :empty?
    rows.each do |row|
      (row.key >= "test-5").must_equal true
    end
  end

  it "read rows with limit, filter and range" do
    range = table.new_row_range.from("test-1")
    filter = table.filter.qualifier("field.*")
    limit = 5

    rows = table.read_rows(ranges: range, filter: filter, limit: limit).map do |row|
      row.must_be_kind_of Google::Cloud::Bigtable::Row
      row
    end

    rows.wont_be :empty?
    rows.length.must_equal 5
    rows.each do |row|
      (row.key >= "test-1").must_equal true
    end

    rows.each do |row|
      row.cells[family].each do |cell|
        cell.qualifier.start_with?("field").must_equal true
      end
    end
  end
end
