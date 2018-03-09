# frozen_string_literal: true

require "test_helper"

describe Google::Cloud::Bigtable::RowsReader do
  let(:rows_reader) {
    Google::Cloud::Bigtable::RowsReader.new("fake-client", "table-path", "app_id", {})
  }

  it "removed already read row keys from row set row_keys" do
    row_set = Google::Bigtable::V2::RowSet.new(row_keys: ["1", "3", "2", "5"])
    rows_reader.chunk_reader.last_key = "3"
    rows_reader.instance_variable_set("@rows_count", 10)

    assert_equal("3", rows_reader.last_key)

    rows_limit, retry_row_set = rows_reader.retry_options(100, row_set)

    assert_equal(90, rows_limit)
    assert_equal(["5"], retry_row_set.row_keys)
  end

  it "add row range if row set row ranges empty" do
    row_set = Google::Bigtable::V2::RowSet.new
    rows_reader.chunk_reader.last_key = "3"

    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    assert_equal(1, row_ranges.length)
    assert_equal(
      Google::Bigtable::V2::RowRange.new({ start_key_open: "3" }),
      row_ranges.first
    )
  end

  it "removed already read row ranges" do
    row_set = Google::Bigtable::V2::RowSet.new(
      row_ranges: [ { end_key_closed: "3" }, { end_key_closed: "5" } ]
    )
    rows_reader.chunk_reader.last_key = "3"
    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    assert_equal(1, row_ranges.length)
    assert_equal("5", row_ranges.first.end_key_closed)
    refute_equal(
      Google::Bigtable::V2::RowRange.new({ end_key_closed: "3"}),
      row_ranges.first
    )
  end

  it "set start key for already read row ranges" do
    row_set = Google::Bigtable::V2::RowSet.new(
      row_ranges: [ { end_key_closed: "5" } ]
    )
    rows_reader.chunk_reader.last_key = "3"
    _, retry_row_set = rows_reader.retry_options(100, row_set)
    row_ranges = retry_row_set.row_ranges

    assert_equal(1, row_ranges.length)
    assert_equal(
      Google::Bigtable::V2::RowRange.new({ start_key_open: "3", end_key_closed: "5"}),
      row_ranges.first
    )
  end
end
