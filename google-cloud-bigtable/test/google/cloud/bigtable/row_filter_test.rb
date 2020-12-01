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

describe Google::Cloud::Bigtable::RowFilter, :row_filter, :mock_bigtable do
  let(:table){
    Google::Cloud::Bigtable::DataClient::Table.new(
      Object.new, "dummy-table-path"
    )
  }
  let(:integer_encoded_1) { "\x00\x00\x00\x00\x00\x00\x00\x01".encode "ASCII-8BIT" }
  let(:integer_encoded_2) { "\x00\x00\x00\x00\x00\x00\x00\x02".encode "ASCII-8BIT" }

  it "creates a sink filter" do
    filter = Google::Cloud::Bigtable::RowFilter.sink

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.sink).must_equal true
  end

  it "creates a pass filter" do
    filter = Google::Cloud::Bigtable::RowFilter.pass

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.pass_all_filter).must_equal true
  end

  it "creates a block filter" do
    filter = Google::Cloud::Bigtable::RowFilter.block

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.block_all_filter).must_equal true
  end

  it "creates a strip_value filter" do
    filter = Google::Cloud::Bigtable::RowFilter.strip_value

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.strip_value_transformer).must_equal true
  end

  it "creates a key filter" do
    regex = "user-*"
    filter = Google::Cloud::Bigtable::RowFilter.key(regex)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.row_key_regex_filter).must_equal regex
  end

  it "creates a family filter" do
    regex = "cf-*"
    filter = Google::Cloud::Bigtable::RowFilter.family(regex)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.family_name_regex_filter).must_equal regex
  end

  it "creates a qualifier filter" do
    regex = "field*"
    filter = Google::Cloud::Bigtable::RowFilter.qualifier(regex)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.column_qualifier_regex_filter).must_equal(regex)
  end

  it "creates a value filter" do
    regex = "abc*"
    filter = Google::Cloud::Bigtable::RowFilter.value(regex)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.value_regex_filter).must_equal regex
  end

  it "creates a value filter with integer" do
    filter = Google::Cloud::Bigtable::RowFilter.value 1

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.value_regex_filter).must_equal integer_encoded_1
  end

  it "creates a label filter" do
    label = "test"
    filter = Google::Cloud::Bigtable::RowFilter.label(label)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.apply_label_transformer).must_equal(label)
  end

  it "creates a cells_per_row_offset filter" do
    offset = 5
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_row_offset(offset)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.cells_per_row_offset_filter).must_equal offset
  end

  it "creates a cells_per_row filter" do
    limit = 10
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_row(limit)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.cells_per_row_limit_filter).must_equal limit
  end

  it "creates a cells_per_column filter" do
    limit = 10
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_column(limit)

    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    _(filter.to_grpc.cells_per_column_limit_filter).must_equal limit
  end

  describe "timestamp_range" do
    it "creates a timestamp_range filter" do
      from = timestamp_micros - 3000000
      to = timestamp_micros

      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(from: from, to: to)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      range_grpc = Google::Cloud::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from, end_timestamp_micros: to
      )
      _(filter.to_grpc.timestamp_range_filter).must_equal range_grpc
    end

    it "creates a timestamp_range filter with only from range" do
      from = timestamp_micros - 3000000
      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(from: from)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      range_grpc = Google::Cloud::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from
      )
      _(filter.to_grpc.timestamp_range_filter).must_equal range_grpc
    end

    it "creates a timestamp_range filter with only to range" do
      to = timestamp_micros
      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(to: to)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

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
      filter = Google::Cloud::Bigtable::RowFilter.value_range(range)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      grpc = filter.to_grpc.value_range_filter
      _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::ValueRange
      _(grpc.start_value_closed).must_equal from_value
      _(grpc.end_value_open).must_equal to_value
    end

    it "creates a value_range filter with integers" do
      range = Google::Cloud::Bigtable::ValueRange.new.from(1).to(2)
      filter = Google::Cloud::Bigtable::RowFilter.value_range(range)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      grpc = filter.to_grpc.value_range_filter
      _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::ValueRange
      _(grpc.start_value_closed).must_equal integer_encoded_1
      _(grpc.end_value_open).must_equal integer_encoded_2
    end

    it "range instance must be type of ValueRange" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.value_range(Object.new)
      end
    end
  end

  describe "#column_range" do
    it "creates a column_range filter" do
      family = "cf"
      from_value = "field0"
      to_value = "field5"

      range = Google::Cloud::Bigtable::ColumnRange.new(family).from(from_value).to(to_value)
      filter = Google::Cloud::Bigtable::RowFilter.column_range(range)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      grpc = filter.to_grpc.column_range_filter
      _(grpc).must_be_kind_of Google::Cloud::Bigtable::V2::ColumnRange
      _(grpc.family_name).must_equal family
      _(grpc.start_qualifier_closed).must_equal from_value
      _(grpc.end_qualifier_open).must_equal to_value
    end

    it "range instance must be type of ColumnRange" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.column_range(Object.new)
      end
    end
  end

  describe "#sample" do
    it "creates a sample probability filter" do
      probability = 0.5
      filter = Google::Cloud::Bigtable::RowFilter.sample(probability)

      _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
      _(filter.to_grpc.row_sample_filter).must_equal probability
    end

    it "probability can not be greather then 1" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.sample(1.1)
      end
    end

    it "probability can not be equal to 1" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.sample(1)
      end
    end

    it "probability can not be equal to 0" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.sample(0)
      end
    end

    it "probability can not be less then 0" do
      assert_raises Google::Cloud::Bigtable::RowFilterError do
        Google::Cloud::Bigtable::RowFilter.sample(-0.1)
      end
    end
  end

  it "creates a chain filter" do
    filter = Google::Cloud::Bigtable::RowFilter.chain
    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::ChainFilter
    filters = filter.filters
    _(filters).must_be_kind_of Array
    _(filters).must_be :frozen?
    _(filters).must_be :empty?

    filter.pass.block.sink.strip_value # Add some filters to the chain.
    _(filter.length).must_equal 4

    filters_grpc = filter.to_grpc.chain.filters
    _(filters_grpc.length).must_equal 4
    _(filters_grpc[0].pass_all_filter).must_equal true
    _(filters_grpc[1].block_all_filter).must_equal true
    _(filters_grpc[2].sink).must_equal true
    _(filters_grpc[3].strip_value_transformer).must_equal true
  end

  it "creates an interleave filter" do
    filter = Google::Cloud::Bigtable::RowFilter.interleave
    _(filter).must_be_kind_of Google::Cloud::Bigtable::RowFilter::InterleaveFilter
    filters = filter.filters
    _(filters).must_be_kind_of Array
    _(filters).must_be :frozen?
    _(filters).must_be :empty?

    filter.pass.block.sink.strip_value # Add some filters to the interleave.
    _(filter.length).must_equal 4

    filters_grpc = filter.to_grpc.interleave.filters
    _(filters_grpc.length).must_equal 4
    _(filters_grpc[0].pass_all_filter).must_equal true
    _(filters_grpc[1].block_all_filter).must_equal true
    _(filters_grpc[2].sink).must_equal true
    _(filters_grpc[3].strip_value_transformer).must_equal true
  end

  it "creates a condition filter" do
    predicate = Google::Cloud::Bigtable::RowFilter.key("user-*")
    condition = Google::Cloud::Bigtable::RowFilter.condition(predicate)
    _(condition).must_be_kind_of Google::Cloud::Bigtable::RowFilter::ConditionFilter

    on_match_filter = Google::Cloud::Bigtable::RowFilter.label("label")
    otherwise_filter = Google::Cloud::Bigtable::RowFilter.strip_value

    condition.on_match(on_match_filter).otherwise(otherwise_filter)

    _(condition.to_grpc.condition).must_be_kind_of Google::Cloud::Bigtable::V2::RowFilter::Condition
    grpc = condition.to_grpc.condition
    _(grpc.predicate_filter).must_be_kind_of Google::Cloud::Bigtable::V2::RowFilter
    _(grpc.predicate_filter.row_key_regex_filter).must_equal "user-*"
    _(grpc.true_filter).must_be_kind_of Google::Cloud::Bigtable::V2::RowFilter
    _(grpc.true_filter.apply_label_transformer).must_equal "label"
    _(grpc.false_filter).must_be_kind_of Google::Cloud::Bigtable::V2::RowFilter
    _(grpc.false_filter.strip_value_transformer).must_equal true
  end
end
