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
  it "knows the identifiers" do
    instance_id = "test-instance"
    table_id = "test-table"

    cluster_states = clusters_state_grpc
    column_families = column_families_grpc
    table_grpc = Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
    table = Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service, view: :FULL)

    table.must_be_kind_of Google::Cloud::Bigtable::Table
    table.project_id.must_equal project_id
    table.instance_id.must_equal instance_id
    table.name.must_equal table_id
    table.path.must_equal table_path(instance_id, table_id)

    table.granularity.must_equal :MILLIS
    table.granularity_millis?.must_equal true

    table.cluster_states.map(&:cluster_name).sort.must_equal cluster_states.keys
    table.cluster_states.each do |cs|
      cs.replication_state.must_equal :READY
    end

    table.column_families.map(&:name).sort.must_equal column_families.keys
    table.column_families.each do |cf|
      cf.gc_rule.to_grpc.must_equal column_families[cf.name].gc_rule
    end
  end

  describe "#helpers" do
    let(:table) do
      Google::Cloud::Bigtable::Table.new(Object.new, Object.new)
    end

    it "create mutation entry instance" do
      mutation_entry = table.new_mutation_entry("row-1")
      mutation_entry.must_be_kind_of Google::Cloud::Bigtable::MutationEntry
      mutation_entry.row_key.must_equal "row-1"
    end

    it "create read modify write row rule instance" do
      table = Google::Cloud::Bigtable::Table.new(Object.new, Object.new)
      rule = table.new_read_modify_write_rule("cf", "field1")
      rule.must_be_kind_of Google::Cloud::Bigtable::ReadModifyWriteRule
      rule.to_grpc.family_name.must_equal "cf"
      rule.to_grpc.column_qualifier.must_equal "field1"
    end

    it "create value range instance" do
      range = table.new_value_range
      range.must_be_kind_of Google::Cloud::Bigtable::ValueRange
    end

    it "create column range instance" do
      range = table.new_column_range("cf")
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      range.family.must_equal "cf"
    end

    it "create row range instance" do
      range = table.new_row_range
      range.must_be_kind_of Google::Cloud::Bigtable::RowRange
    end

    it "get filter module" do
      filter = table.filter
      filter.must_equal Google::Cloud::Bigtable::RowFilter
    end
  end
end
