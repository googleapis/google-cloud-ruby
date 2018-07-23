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

    row_set = Google::Bigtable::V2::RowSet.new(row_keys: %w[1 3 2 5])
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")
    chunk_processor.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    rows_reader.last_key.must_equal "3"

    rows_limit, retry_row_set = rows_reader.retry_options(100, row_set)

    rows_limit.must_equal 90
    retry_row_set.row_keys.must_equal ["5"]
  end

  it "add row range if row set row ranges empty" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Bigtable::V2::RowSet.new
    chunk_processor.last_key = "3"

    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    row_ranges.length.must_equal 1
    row_ranges.first.must_equal Google::Bigtable::V2::RowRange.new(start_key_open: "3")
  end

  it "removed already read row ranges" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "3" }, { end_key_closed: "5" }]
    )
    chunk_processor.last_key = "3"
    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    row_ranges.length.must_equal 1
    row_ranges.first.end_key_closed.must_equal "5"
  end

  it "set start key for already read row ranges" do
    rows_reader = Google::Cloud::Bigtable::RowsReader.new("dummy-table-client")
    chunk_processor = rows_reader.instance_variable_get("@chunk_processor")

    row_set = Google::Bigtable::V2::RowSet.new(
      row_ranges: [{ end_key_closed: "5" }]
    )
    chunk_processor.last_key = "3"
    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    row_ranges.length.must_equal 1
    row_ranges.first.must_equal Google::Bigtable::V2::RowRange.new(start_key_open: "3", end_key_closed: "5")
  end
end
