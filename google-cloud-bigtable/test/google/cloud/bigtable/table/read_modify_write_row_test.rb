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

describe Google::Cloud::Bigtable::Table, :read_modify_write_row, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:family_name) { "cf" }
  let(:timestamp_micros) { 1527625039663 }
  let(:labels) { ["test-labels"] }
  let(:qualifier) { "field01" }
  let(:cell_value) { "xyz" }
  let(:append_value) { "append-123" }
  let(:increment_amount) { 1 }
  let(:table) {
    bigtable.table(instance_id, table_id)
  }

  it "read modify and write row with single rule" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock

    row_key = "user-1"

    cell = { value: cell_value, timestamp_micros: timestamp_micros, labels: labels }
    column = {
      qualifier: qualifier,
      cells: [cell]
    }
    family = { name: family_name, columns: [column]}
    res = Google::Bigtable::V2::ReadModifyWriteRowResponse.new(
      row: { key: row_key, families: [family] }
    )
    rule = Google::Bigtable::V2::ReadModifyWriteRule.new(
      family_name: family_name, column_qualifier: qualifier, append_value: append_value
    )

    mock.expect :read_modify_write_row, res, [
      table_path(instance_id, table_id),
      row_key,
      [rule],
      app_profile_id: nil
    ]

    row = table.read_modify_write_row(
      row_key,
      Google::Cloud::Bigtable::ReadModifyWriteRule.append(family_name, qualifier, append_value)
    )
    mock.verify

    row.must_be_kind_of Google::Cloud::Bigtable::Row
    row.key.must_equal row_key
    row.cells[family_name].length.must_equal 1

    cell = row.cells[family_name].first
    cell.value.must_equal cell_value
    cell.family.must_equal family_name
    cell.qualifier.must_equal qualifier
    cell.timestamp.must_equal timestamp_micros
    cell.labels.must_equal labels
  end

  it "read modify and write row with multiple rule" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock

    row_key = "user-1"

    cell1 = { value: cell_value + "1", timestamp_micros: 0 }
    cell2 = { value: cell_value + "2", timestamp_micros: 0 }

    column = {
      qualifier: qualifier,
      cells: [cell1, cell2]
    }
    family = { name: family_name, columns: [column]}
    res = Google::Bigtable::V2::ReadModifyWriteRowResponse.new(
      row: { key: row_key, families: [family] }
    )
    rule_1 = Google::Bigtable::V2::ReadModifyWriteRule.new(
      family_name: family_name, column_qualifier: qualifier, append_value: append_value
    )

    rule_2 = Google::Bigtable::V2::ReadModifyWriteRule.new(
      family_name: family_name, column_qualifier: qualifier, increment_amount: increment_amount
    )

    mock.expect :read_modify_write_row, res, [
      table_path(instance_id, table_id),
      row_key,
      [rule_1, rule_2],
      app_profile_id: nil
    ]

    row = table.read_modify_write_row(
      row_key,
      [
        Google::Cloud::Bigtable::ReadModifyWriteRule.append(family_name, qualifier, append_value),
        Google::Cloud::Bigtable::ReadModifyWriteRule.increment(family_name, qualifier, increment_amount)
      ]
    )
    mock.verify

    row.must_be_kind_of Google::Cloud::Bigtable::Row
    row.key.must_equal row_key
    row.cells[family_name].length.must_equal 2

    row.cells[family_name].each_with_index do |cell, i|
      cell.value.must_equal "#{cell_value}#{i+1}"
      cell.family.must_equal family_name
      cell.qualifier.must_equal qualifier
      cell.timestamp.must_equal 0
      cell.labels.must_equal []
    end
  end
end
