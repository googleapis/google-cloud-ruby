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

describe Google::Cloud::Bigtable::RowsReader, :row_reader, :mock_bigtable do
  it "removed already read row keys from row set row_keys" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(row_keys: %w[1 3 2 5])
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    _(rows_reader.last_key).must_equal "3"

    resumption_option = rows_reader.retry_options(100, row_set)

    _(resumption_option.rows_limit).must_equal 90
    _(resumption_option.row_set.row_keys).must_equal ["5"]
  end

  it "add row range if row set row ranges empty" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(row_ranges: [{}])
    
    chunk_processor.last_key = "3"

    resumption_option = rows_reader.retry_options(100, row_set)
    row_ranges = resumption_option.row_set.row_ranges

    _(row_ranges.length).must_equal 1
    _(row_ranges.first).must_equal Google::Cloud::Bigtable::V2::RowRange.new(start_key_open: "3")
  end

  it "removed already read row ranges" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "3" }, { end_key_closed: "5" }]
    )
    chunk_processor.last_key = "3"
    resumption_option = rows_reader.retry_options(100, row_set)
    row_ranges = resumption_option.row_set.row_ranges

    _(row_ranges.length).must_equal 1
    _(row_ranges.first.end_key_closed).must_equal "5"
  end

  it "set start key for already read row ranges" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "5" }]
    )
    chunk_processor.last_key = "3"
    resumption_option = rows_reader.retry_options(100, row_set)
    row_ranges = resumption_option.row_set.row_ranges

    _(row_ranges.length).must_equal 1
    _(row_ranges.first).must_equal Google::Cloud::Bigtable::V2::RowRange.new(start_key_open: "3", end_key_closed: "5")
  end

  it "start key is updated correctly" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ start_key_closed: "3" }]
    )
    chunk_processor.last_key = "3"
    resumption_option = rows_reader.retry_options(100, row_set)
    row_ranges = resumption_option.row_set.row_ranges

    _(row_ranges.length).must_equal 1
    _(row_ranges.first).must_equal Google::Cloud::Bigtable::V2::RowRange.new(start_key_open: "3")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ start_key_open: "3" }]
    )
    resumption_option = rows_reader.retry_options(100, row_set)

    row_ranges = resumption_option.row_set.row_ranges
    _(row_ranges.length).must_equal 1
    _(row_ranges.first).must_equal Google::Cloud::Bigtable::V2::RowRange.new(start_key_open: "3")
  end

  it "increment and check read is retryable" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    _(rows_reader.retryable?).must_equal true

    [true, true, false].each do |expected_value|
      rows_reader.retry_count += 1
      _(rows_reader.retryable?).must_equal expected_value
    end
  end

  it "resumption option is complete after limit number of rows are read" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    _(rows_reader.last_key).must_equal "3"

    resumption_option = rows_reader.retry_options(10, Google::Cloud::Bigtable::V2::RowSet.new())

    _(resumption_option.complete?).must_equal true
  end

  it "resumption option is complete after all the row ranges are read" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "3" }]
    )

    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    _(rows_reader.last_key).must_equal "3"

    resumption_option = rows_reader.retry_options(100, Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "3" }]
    ))
    _(resumption_option.complete?).must_equal true

    resumption_option = rows_reader.retry_options(100, Google::Cloud::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_open: "3" }]
    ))
    _(resumption_option.complete?).must_equal true
  end

  it "resumption option is complete after all the row set are read" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new(row_keys: %w[1 2 3])

    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    _(rows_reader.last_key).must_equal "3"

    resumption_option = rows_reader.retry_options(100, row_set)

    _(resumption_option.complete?).must_equal true
  end

  it "empty read row range is updated correctly" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")

    row_set = Google::Cloud::Bigtable::V2::RowSet.new row_ranges: [Google::Cloud::Bigtable::V2::RowRange.new]

    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    _(rows_reader.last_key).must_equal "3"

    resumption_option = rows_reader.retry_options(100, row_set)

    row_ranges = resumption_option.row_set.row_ranges

    _(resumption_option.complete?).must_equal false
    _(row_ranges.length).must_equal 1
    _(row_ranges.first).must_equal Google::Cloud::Bigtable::V2::RowRange.new(start_key_open: "3")
  end

end
