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

describe Google::Cloud::Bigtable::Table, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Cloud::Bigtable::Admin::V2::Table.new(
    table_hash(
      name: table_path(instance_id, table_id),
      cluster_states: cluster_states,
      column_families: column_families,
      granularity: :MILLIS
    )
  )
  end
  let(:table) { Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service, view: :FULL) }

  it "knows the identifiers" do

    _(table).must_be_kind_of Google::Cloud::Bigtable::Table
    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)

    _(table.granularity).must_equal :MILLIS
    _(table.granularity_millis?).must_equal true

    _(table.cluster_states.map(&:cluster_name).sort).must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      _(cs.replication_state).must_equal :READY
    end

    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
  end

  describe "#helpers" do
    let(:table) do
      Google::Cloud::Bigtable::Table.new(Object.new, Object.new)
    end

    it "create mutation entry instance" do
      mutation_entry = table.new_mutation_entry("row-1")
      _(mutation_entry).must_be_kind_of Google::Cloud::Bigtable::MutationEntry
      _(mutation_entry.row_key).must_equal "row-1"
    end

    it "create read modify write row rule instance" do
      table = Google::Cloud::Bigtable::Table.new(Object.new, Object.new)
      rule = table.new_read_modify_write_rule("cf", "field1")
      _(rule).must_be_kind_of Google::Cloud::Bigtable::ReadModifyWriteRule
      _(rule.to_grpc.family_name).must_equal "cf"
      _(rule.to_grpc.column_qualifier).must_equal "field1"
    end

    it "create value range instance" do
      range = table.new_value_range
      _(range).must_be_kind_of Google::Cloud::Bigtable::ValueRange
    end

    it "create column range instance" do
      range = table.new_column_range("cf")
      _(range).must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      _(range.family).must_equal "cf"
    end

    it "create row range instance" do
      range = table.new_row_range
      _(range).must_be_kind_of Google::Cloud::Bigtable::RowRange
    end

    it "get filter module" do
      filter = table.filter
      _(filter).must_equal Google::Cloud::Bigtable::RowFilter
    end
  end

  it "reloads its state" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_grpc, [name: table_path(instance_id, table_id), view: nil]
    table.service.mocked_tables = mock

    table.reload!

    mock.verify

    _(table.project_id).must_equal project_id
    _(table.instance_id).must_equal instance_id
    _(table.name).must_equal table_id
    _(table.path).must_equal table_path(instance_id, table_id)
    _(table.granularity).must_equal :MILLIS

    _(table.column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(table.column_families).must_be :frozen?
    _(table.column_families.names.sort).must_equal column_families.keys
    table.column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal column_families[cf.name].gc_rule
    end
  end
end
