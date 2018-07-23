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
  it "create sink filter" do
    filter = Google::Cloud::Bigtable::RowFilter.sink

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.sink.must_equal true
  end

  it "create pass filter" do
    filter = Google::Cloud::Bigtable::RowFilter.pass

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.pass_all_filter.must_equal true
  end

  it "create block filter" do
    filter = Google::Cloud::Bigtable::RowFilter.block

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.block_all_filter.must_equal true
  end

  it "create strip_value filter" do
    filter = Google::Cloud::Bigtable::RowFilter.strip_value

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.strip_value_transformer.must_equal true
  end

  it "create key filter" do
    regex = "user-*"
    filter = Google::Cloud::Bigtable::RowFilter.key(regex)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.row_key_regex_filter.must_equal regex
  end

  it "create family filter" do
    regex = "cf-*"
    filter = Google::Cloud::Bigtable::RowFilter.family(regex)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.family_name_regex_filter.must_equal regex
  end

  it "create qualifier filter" do
    regex = "field*"
    filter = Google::Cloud::Bigtable::RowFilter.qualifier(regex)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.column_qualifier_regex_filter.must_equal(regex)
  end

  it "create value filter" do
    regex = "abc*"
    filter = Google::Cloud::Bigtable::RowFilter.value(regex)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.value_regex_filter.must_equal regex
  end

  it "create label filter" do
    label = "test"
    filter = Google::Cloud::Bigtable::RowFilter.label(label)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.apply_label_transformer.must_equal(label)
  end

  it "create cells_per_row_offset filter" do
    offset = 5
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_row_offset(offset)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.cells_per_row_offset_filter.must_equal offset
  end

  it "create cells_per_row filter" do
    limit = 10
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_row(limit)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.cells_per_row_limit_filter.must_equal limit
  end

  it "create cells_per_column filter" do
    limit = 10
    filter = Google::Cloud::Bigtable::RowFilter.cells_per_column(limit)

    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
    filter.to_grpc.cells_per_column_limit_filter.must_equal limit
  end

  describe "timestamp_range" do
    it "create timestamp_range filter" do
      from = (Time.now.to_i - 300) * 1000
      to = Time.now.to_i * 1000

      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(from: from, to: to)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      range_grpc = Google::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from, end_timestamp_micros: to
      )
      filter.to_grpc.timestamp_range_filter.must_equal range_grpc
    end

    it "create timestamp_range filter with only from range" do
      from = (Time.now.to_i - 300) * 1000
      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(from: from)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      range_grpc = Google::Bigtable::V2::TimestampRange.new(
        start_timestamp_micros: from
      )
      filter.to_grpc.timestamp_range_filter.must_equal range_grpc
    end

    it "create timestamp_range filter with only to range" do
      to = Time.now.to_i * 1000
      filter = Google::Cloud::Bigtable::RowFilter.timestamp_range(to: to)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      range_grpc = Google::Bigtable::V2::TimestampRange.new(
        end_timestamp_micros: to
      )
      filter.to_grpc.timestamp_range_filter.must_equal range_grpc
    end
  end

  describe "#value_range" do
    it "create value_range filter" do
      from_value = "abc"
      to_value = "xyz"
      range = Google::Cloud::Bigtable::ValueRange.new.from(from_value).to(to_value)
      filter = Google::Cloud::Bigtable::RowFilter.value_range(range)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      grpc = filter.to_grpc.value_range_filter
      grpc.must_be_kind_of Google::Bigtable::V2::ValueRange
      grpc.start_value_closed.must_equal from_value
      grpc.end_value_open.must_equal to_value
    end

    it "range instance must be type of ValueRange" do
      proc {
        Google::Cloud::Bigtable::RowFilter.value_range(Object.new)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end
  end

  describe "#column_range" do
    it "create column_range filter" do
      family = "cf"
      from_value = "field0"
      to_value = "field5"

      range = Google::Cloud::Bigtable::ColumnRange.new(family).from(from_value).to(to_value)
      filter = Google::Cloud::Bigtable::RowFilter.column_range(range)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter

      grpc = filter.to_grpc.column_range_filter
      grpc.must_be_kind_of Google::Bigtable::V2::ColumnRange
      grpc.family_name.must_equal family
      grpc.start_qualifier_closed.must_equal from_value
      grpc.end_qualifier_open.must_equal to_value
    end

    it "range instance must be type of ColumnRange" do
      proc {
        Google::Cloud::Bigtable::RowFilter.column_range(Object.new)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end
  end

  describe "#smaple" do
    it "create sample probability filter" do
      probability = 0.5
      filter = Google::Cloud::Bigtable::RowFilter.sample(probability)

      filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::SimpleFilter
      filter.to_grpc.row_sample_filter.must_equal probability
    end

    it "probability can not be greather then 1" do
      proc {
        Google::Cloud::Bigtable::RowFilter.sample(1.1)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end

    it "probability can not be equal to 1" do
      proc {
        Google::Cloud::Bigtable::RowFilter.sample(1)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end

    it "probability can not be equal to 0" do
      proc {
        Google::Cloud::Bigtable::RowFilter.sample(0)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end

    it "probability can not be less then 0" do
      proc {
        Google::Cloud::Bigtable::RowFilter.sample(-0.1)
      }.must_raise Google::Cloud::Bigtable::RowFilterError
    end
  end

  it "create chain filter" do
    filter = Google::Cloud::Bigtable::RowFilter.chain
    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::ChainFilter
    filter.to_grpc.chain.must_be_kind_of Google::Bigtable::V2::RowFilter::Chain
  end

  it "create interleave filter" do
    filter = Google::Cloud::Bigtable::RowFilter.interleave
    filter.must_be_kind_of Google::Cloud::Bigtable::RowFilter::InterleaveFilter
    filter.to_grpc.interleave.must_be_kind_of Google::Bigtable::V2::RowFilter::Interleave
  end

  it "create condition filter" do
    predicate = Google::Cloud::Bigtable::RowFilter.key("user-*")
    condition = Google::Cloud::Bigtable::RowFilter.condition(predicate)
    condition.must_be_kind_of Google::Cloud::Bigtable::RowFilter::ConditionFilter

    on_match_filter = Google::Cloud::Bigtable::RowFilter.label("label")
    otherwise_filter = Google::Cloud::Bigtable::RowFilter.strip_value

    condition.on_match(on_match_filter).otherwise(otherwise_filter)

    condition.to_grpc.condition.must_be_kind_of Google::Bigtable::V2::RowFilter::Condition
    grpc = condition.to_grpc.condition
    grpc.predicate_filter.must_be_kind_of Google::Bigtable::V2::RowFilter
    grpc.predicate_filter.row_key_regex_filter.must_equal "user-*"
    grpc.true_filter.must_be_kind_of Google::Bigtable::V2::RowFilter
    grpc.true_filter.apply_label_transformer.must_equal "label"
    grpc.false_filter.must_be_kind_of Google::Bigtable::V2::RowFilter
    grpc.false_filter.strip_value_transformer.must_equal true
  end
end
