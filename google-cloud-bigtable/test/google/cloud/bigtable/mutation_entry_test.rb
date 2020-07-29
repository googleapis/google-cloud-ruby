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

describe Google::Cloud::Bigtable::MutationEntry, :mutation_entry, :mock_bigtable do
  let(:row_key) { "test-row-key" }

  it "create empty instance" do
    entry = Google::Cloud::Bigtable::MutationEntry.new
    _(entry.row_key).must_be :nil?
    _(entry.mutations).must_be_empty
    _(entry.retryable?).must_equal true
  end

  it "create instance with only row_key" do
    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    _(entry.row_key).must_equal row_key

    grpc = entry.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::MutateRowsRequest::Entry
    _(grpc.row_key).must_equal row_key
  end

  describe "#set_cell" do
    let(:family) { "cf" }
    let(:qualifier) { "field1" }
    let(:cell_value) { "test-value" }

    it "add set cell mutation without timestamp" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.set_cell(family, qualifier, cell_value)
      _(entry.mutations.length).must_equal 1
      _(entry.retryable?).must_equal true

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.set_cell).wont_be_nil

      set_cell_grpc = mutation.set_cell
      _(set_cell_grpc.family_name).must_equal family
      _(set_cell_grpc.column_qualifier).must_equal qualifier
      _(set_cell_grpc.value).must_equal cell_value
      _(set_cell_grpc.timestamp_micros).must_equal 0
    end

    it "add set cell mutation with timestamp" do
      timestamp = timestamp_micros
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.set_cell(family, qualifier, cell_value, timestamp: timestamp)
      _(entry.mutations.length).must_equal 1
      _(entry.retryable?).must_equal true

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.set_cell).wont_be_nil

      set_cell_grpc = mutation.set_cell
      _(set_cell_grpc.family_name).must_equal family
      _(set_cell_grpc.column_qualifier).must_equal qualifier
      _(set_cell_grpc.value).must_equal cell_value
      _(set_cell_grpc.timestamp_micros).must_equal timestamp
    end

    it "add set cell non retyable mutation with server time timestamp" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.set_cell(family, qualifier, cell_value, timestamp: -1)
      _(entry.mutations.length).must_equal 1
      _(entry.retryable?).must_equal false
    end

    it "convert integer value to 64 bit big endian" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.set_cell(family, qualifier, 5)
      _(entry.mutations.length).must_equal 1

      set_cell_grpc = entry.mutations.first.set_cell
      _(set_cell_grpc.value.bytes).must_equal [0, 0, 0, 0, 0, 0, 0, 5]
    end
  end

  describe "#delete_cells" do
    let(:family) { "cf" }
    let(:qualifier) { "field1" }

    it "add delete cells mutation without timestamp range" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_cells(family, qualifier)

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_column).wont_be_nil

      delete_cells_grpc = mutation.delete_from_column
      _(delete_cells_grpc.family_name).must_equal family
      _(delete_cells_grpc.column_qualifier).must_equal qualifier
      _(delete_cells_grpc.time_range).must_be_nil
    end

    it "add delete cells mutation with from timestamp" do
      timestamp_from = timestamp_micros

      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_cells(family, qualifier, timestamp_from: timestamp_from)

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_column).wont_be_nil

      delete_cells_grpc = mutation.delete_from_column
      _(delete_cells_grpc.family_name).must_equal family
      _(delete_cells_grpc.column_qualifier).must_equal qualifier
      _(delete_cells_grpc.time_range).wont_be_nil
      _(delete_cells_grpc.time_range.start_timestamp_micros).must_equal timestamp_from
      _(delete_cells_grpc.time_range.end_timestamp_micros).must_equal 0
    end

    it "add delete cells mutation with to timestamp range" do
      timestamp_to = timestamp_micros

      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_cells(family, qualifier, timestamp_to: timestamp_to)

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_column).wont_be_nil

      delete_cells_grpc = mutation.delete_from_column
      _(delete_cells_grpc.family_name).must_equal family
      _(delete_cells_grpc.column_qualifier).must_equal qualifier
      _(delete_cells_grpc.time_range).wont_be_nil
      _(delete_cells_grpc.time_range.end_timestamp_micros).must_equal timestamp_to
      _(delete_cells_grpc.time_range.start_timestamp_micros).must_equal 0
    end

    it "add delete cells mutation with timestamp range" do
      timestamp_from = timestamp_micros
      timestamp_to = timestamp_micros + 1000000

      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_cells(family, qualifier, timestamp_from: timestamp_from, timestamp_to: timestamp_to)

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_column).wont_be_nil

      delete_cells_grpc = mutation.delete_from_column
      _(delete_cells_grpc.family_name).must_equal family
      _(delete_cells_grpc.column_qualifier).must_equal qualifier
      _(delete_cells_grpc.time_range).wont_be_nil
      _(delete_cells_grpc.time_range.start_timestamp_micros).must_equal timestamp_from
      _(delete_cells_grpc.time_range.end_timestamp_micros).must_equal timestamp_to
    end
  end

  describe "#delete_from_family" do
    let(:family) { "cf" }

    it "add delete all cells from family mutation" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_from_family(family)

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_family).wont_be_nil
      _(mutation.delete_from_family.family_name).must_equal family
    end
  end

  describe "#delete_from_row" do
    it "add delete all cells from row mutation" do
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
      entry.delete_from_row

      grpc = entry.to_grpc
      mutation = grpc.mutations.first
      _(mutation.delete_from_row).wont_be_nil
    end
  end

  it "chain mutations and add to mutations list" do
    entry = Google::Cloud::Bigtable::MutationEntry.new(row_key)
    entry.set_cell("cf1", "field01", "xyz")
      .delete_from_family("cf2")
      .delete_cells("cf3", "field02")
      .delete_from_row

    _(entry.mutations.length).must_equal 4

    grpc = entry.to_grpc
    _(grpc.mutations.length).must_equal 4

    _(entry.mutations[0].set_cell).wont_be_nil
    _(entry.mutations[1].delete_from_family).wont_be_nil
    _(entry.mutations[2].delete_from_column).wont_be_nil
    _(entry.mutations[3].delete_from_row).wont_be_nil
  end
end
