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

  let(:table_cluster_states) { cluster_states_grpc }
  let(:table_column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Cloud::Bigtable::Admin::V2::Table.new(
    table_hash(
      name: table_path(instance_id, table_id),
      cluster_states: table_cluster_states,
      column_families: table_column_families,
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

    cluster_states = table.cluster_states
    _(cluster_states).must_be_instance_of Array
    _(cluster_states.map(&:cluster_name).sort).must_equal table_cluster_states.keys
    cluster_states.each do |cs|
      _(cs).must_be_instance_of Google::Cloud::Bigtable::Table::ClusterState
      _(cs.replication_state).must_equal :READY
    end

    column_families = table.column_families
    _(column_families).must_be_instance_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(column_families).must_be :frozen?
    _(column_families.names.sort).must_equal table_column_families.keys
    column_families.each do |name, cf|
      _(cf.gc_rule.to_grpc).must_equal table_column_families[cf.name].gc_rule
    end
  end

  describe "#helpers" do
    let(:table) do
      Google::Cloud::Bigtable::Table.new(table_grpc, bigtable.service, view: :NAME_ONLY)
    end

    it "create mutation entry instance" do
      mutation_entry = table.new_mutation_entry("row-1")
      _(mutation_entry).must_be_kind_of Google::Cloud::Bigtable::MutationEntry
      _(mutation_entry.row_key).must_equal "row-1"
    end

    it "create read modify write row rule instance" do
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
    mock.expect :get_table, table_grpc, name: table_path(instance_id, table_id), view: :SCHEMA_VIEW
    table.service.mocked_tables = mock

    table.reload!

    mock.verify
  end

  it "reloads its state with view option" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_grpc, name: table_path(instance_id, table_id), view: :REPLICATION_VIEW
    table.service.mocked_tables = mock

    table.reload! view: :REPLICATION_VIEW

    mock.verify
  end

  describe "views" do
    let(:table_grpc) { Google::Cloud::Bigtable::Admin::V2::Table.new(name: table_path(instance_id, table_id)) }
    let(:table) { Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service, view: :NAME_ONLY) }

    it "loads SCHEMA_VIEW on access to column_families" do
      get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, table_id),
        column_families: column_families_grpc,
        granularity: :MILLIS
      )

      mock = Minitest::Mock.new
      mock.expect :get_table, get_res, name: table_path(instance_id, table_id), view: :SCHEMA_VIEW
      table.service.mocked_tables = mock

      _(table.column_families).wont_be :empty?
      _(table.column_families).wont_be :empty? # No RPC on subsequent access

      mock.verify
    end

    it "loads SCHEMA_VIEW on access to granularity" do
      get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, table_id),
        column_families: column_families_grpc,
        granularity: :MILLIS
      )

      mock = Minitest::Mock.new
      mock.expect :get_table, get_res, name: table_path(instance_id, table_id), view: :SCHEMA_VIEW
      table.service.mocked_tables = mock

      _(table.granularity).must_equal :MILLIS
      _(table.granularity).must_equal :MILLIS # No RPC on subsequent access

      mock.verify
    end

    it "loads FULL on access to cluster_states" do
      get_res = Google::Cloud::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, table_id),
        cluster_states: table_cluster_states,
        column_families: column_families_grpc,
        granularity: :MILLIS
      )

      mock = Minitest::Mock.new
      mock.expect :get_table, get_res, name: table_path(instance_id, table_id), view: :FULL
      table.service.mocked_tables = mock

      _(table.cluster_states).wont_be :empty?
      _(table.cluster_states).wont_be :empty? # No RPC on subsequent access

      mock.verify
    end

    it "loads SCHEMA_VIEW and FULL on access to column_families and cluster_states" do
      get_res_schema = Google::Cloud::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, table_id),
        column_families: column_families_grpc,
        granularity: :MILLIS
      )
      get_res_full = Google::Cloud::Bigtable::Admin::V2::Table.new(
        name: table_path(instance_id, table_id),
        cluster_states: table_cluster_states,
        column_families: column_families_grpc,
        granularity: :MILLIS
      )

      mock = Minitest::Mock.new
      mock.expect :get_table, get_res_schema, name: table_path(instance_id, table_id), view: :SCHEMA_VIEW
      mock.expect :get_table, get_res_full, name: table_path(instance_id, table_id), view: :FULL
      table.service.mocked_tables = mock

      _(table.column_families).wont_be :empty?
      _(table.cluster_states).wont_be :empty?
      _(table.column_families).wont_be :empty? # No RPC on subsequent access
      _(table.cluster_states).wont_be :empty? # No RPC on subsequent access

      mock.verify
    end
  end

  it "reloads its state with view option" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_grpc, name: table_path(instance_id, table_id), view: :ENCRYPTION_VIEW
    table.service.mocked_tables = mock

    table.reload! view: :ENCRYPTION_VIEW

    mock.verify
  end
end
