# frozen_string_literal: true

# Copyright 2019 Google LLC
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

describe Google::Cloud::Bigtable::RowFilter::ChainFilter, :mock_bigtable do
  let(:table) do
    Google::Cloud::Bigtable::DataClient::Table.new(
      Object.new, "dummy-table-path"
    )
  end
  let(:chain_filter) { Google::Cloud::Bigtable::RowFilter.chain }

  it "knows its attributes" do
    _(chain_filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::ChainFilter
    filters = chain_filter.filters
    _(filters).must_be_kind_of Array
    _(filters).must_be :frozen?
    _(filters).must_be :empty?
  end

  it "creates a sink filter" do
    _(chain_filter.filters).must_be :empty?
    chain_filter.sink
    assert_filter :sink
  end

  it "creates a pass filter" do
    _(chain_filter.filters).must_be :empty?
    chain_filter.pass
    assert_filter :pass_all_filter
  end

  it "creates a block filter" do
    _(chain_filter.filters).must_be :empty?
    chain_filter.block
    assert_filter :block_all_filter
  end

  it "creates a strip_value filter" do
    _(chain_filter.filters).must_be :empty?
    chain_filter.strip_value
    assert_filter :strip_value_transformer
  end

  it "creates a key filter" do
    regex = "user-*"
    _(chain_filter.filters).must_be :empty?
    chain_filter.key(regex)
    filter = assert_filter :row_key_regex_filter
    _(filter.to_grpc.row_key_regex_filter).must_equal regex
  end

  it "creates a family filter" do
    regex = "cf-*"
    _(chain_filter.filters).must_be :empty?
    chain_filter.family(regex)
    filter = assert_filter :family_name_regex_filter
    _(filter.to_grpc.family_name_regex_filter).must_equal regex
  end

  it "creates a qualifier filter" do
    regex = "field*"
    _(chain_filter.filters).must_be :empty?
    chain_filter.qualifier(regex)
    filter = assert_filter :column_qualifier_regex_filter
    _(filter.to_grpc.column_qualifier_regex_filter).must_equal regex
  end

  it "creates a value filter" do
    regex = "abc*"
    _(chain_filter.filters).must_be :empty?
    chain_filter.value(regex)
    filter = assert_filter :value_regex_filter
    _(filter.to_grpc.value_regex_filter).must_equal regex
  end

  it "creates a label filter" do
    label = "test"
    _(chain_filter.filters).must_be :empty?
    chain_filter.label(label)
    filter = assert_filter :apply_label_transformer
    _(filter.to_grpc.apply_label_transformer).must_equal label
  end

  it "creates a cells_per_row_offset filter" do
    offset = 5
    _(chain_filter.filters).must_be :empty?
    chain_filter.cells_per_row_offset(offset)
    filter = assert_filter :cells_per_row_offset_filter
    _(filter.to_grpc.cells_per_row_offset_filter).must_equal offset
  end

  it "creates a cells_per_row filter" do
    limit = 10
    _(chain_filter.filters).must_be :empty?
    chain_filter.cells_per_row(limit)
    filter = assert_filter :cells_per_row_limit_filter
    _(filter.to_grpc.cells_per_row_limit_filter).must_equal limit
  end

  it "creates a cells_per_column filter" do
    limit = 10
    _(chain_filter.filters).must_be :empty?
    chain_filter.cells_per_column(limit)
    filter = assert_filter :cells_per_column_limit_filter
    _(filter.to_grpc.cells_per_column_limit_filter).must_equal limit
  end

  describe "timestamp_range" do
    it "creates a timestamp_range filter" do
      from = timestamp_micros - 3000000
      to = timestamp_micros
      _(chain_filter.filters).must_be :empty?
      chain_filter.timestamp_range(from: from, to: to)
      filter = assert_filter :timestamp_range_filter
      range_grpc = Google::Cloud::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from, end_timestamp_micros: to
      )
      _(filter.to_grpc.timestamp_range_filter).must_equal range_grpc
    end

    it "creates a timestamp_range filter with only from range" do
      from = timestamp_micros - 3000000
      _(chain_filter.filters).must_be :empty?
      chain_filter.timestamp_range(from: from)
      filter = assert_filter :timestamp_range_filter
      range_grpc = Google::Cloud::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from
      )
      _(filter.to_grpc.timestamp_range_filter).must_equal range_grpc
    end

    it "creates a timestamp_range filter with only to range" do
      to = timestamp_micros
      _(chain_filter.filters).must_be :empty?
      chain_filter.timestamp_range(to: to)
      filter = assert_filter :timestamp_range_filter
      range_grpc = Google::Cloud::Bigtable::V2::TimestampRange.new(
        end_timestamp_micros: to
      )
      _(filter.to_grpc.timestamp_range_filter).must_equal range_grpc
    end
  end

  describe "#value_range" do
    it "creates a value_range filter" do
      from_value = "abc"
      to_value = "xyz"
      range = Google::Cloud::Bigtable::ValueRange.new.from(from_value).to(to_value)
      _(chain_filter.filters).must_be :empty?
      chain_filter.value_range(range)
      filter = assert_filter :value_range_filter
      grpc = filter.to_grpc.value_range_filter
      _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::ValueRange
      _(grpc.start_value_closed).must_equal from_value
      _(grpc.end_value_open).must_equal to_value
    end

    it "range instance must be type of ValueRange" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.value_range(Object.new)
      end
    end
  end

  describe "#column_range" do
    it "creates a column_range filter" do
      family = "cf"
      from_value = "field0"
      to_value = "field5"

      range = Google::Cloud::Bigtable::ColumnRange.new(family).from(from_value).to(to_value)
      _(chain_filter.filters).must_be :empty?
      chain_filter.column_range(range)
      filter = assert_filter :column_range_filter
      grpc = filter.to_grpc.column_range_filter
      _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::ColumnRange
      _(grpc.family_name).must_equal family
      _(grpc.start_qualifier_closed).must_equal from_value
      _(grpc.end_qualifier_open).must_equal to_value
    end

    it "range instance must be type of ColumnRange" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.column_range(Object.new)
      end
    end
  end

  describe "#sample" do
    it "creates a sample probability filter" do
      probability = 0.5
      _(chain_filter.filters).must_be :empty?
      chain_filter.sample(probability)
      filter = assert_filter :row_sample_filter
      _(filter.to_grpc.row_sample_filter).must_equal probability
    end

    it "probability can not be greather then 1" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.sample(1.1)
      end
    end

    it "probability can not be equal to 1" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.sample(1)
      end
    end

    it "probability can not be equal to 0" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.sample(0)
      end
    end

    it "probability can not be less then 0" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        chain_filter.sample(-0.1)
      end
    end
  end

  it "creates a chain filter" do
    filter = Google::Cloud::Bigtable::RowFilter.chain
    _(chain_filter.filters).must_be :empty?
    chain_filter.chain filter
    assert_filter :chain, Google::Cloud::Bigtable::RowFilter::ChainFilter
  end

  it "creates an interleave filter" do
    filter = Google::Cloud::Bigtable::RowFilter.interleave
    _(chain_filter.filters).must_be :empty?
    chain_filter.interleave filter
    assert_filter :interleave, Google::Cloud::Bigtable::RowFilter::InterleaveFilter
  end

  it "creates a condition filter" do
    predicate = Google::Cloud::Bigtable::RowFilter.key("user-*")
    filter = Google::Cloud::Bigtable::RowFilter.condition(predicate)
    _(chain_filter.filters).must_be :empty?
    chain_filter.condition filter
    assert_filter :condition, Google::Cloud::Bigtable::RowFilter::ConditionFilter
  end

  def assert_filter method, type = Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(chain_filter.filters.count).must_equal 1
    filter = chain_filter.filters.find do |f|
      t = f.to_grpc.send method
      if t.kind_of? String # may be empty string in protobuf
        !t.empty?
      else
        !t.nil?
      end
    end
    _(filter).must_be_kind_of type
    filter
  end
end
