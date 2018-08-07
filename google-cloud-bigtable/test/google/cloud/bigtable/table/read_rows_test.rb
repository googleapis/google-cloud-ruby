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

describe Google::Cloud::Bigtable::Table, :read_rows, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:row_key) { "rk" }
  let(:family) {  "cf" }
  let(:qualifier) {  "field1" }
  let(:cell_value) { "xyz" }
  let(:timestamp) { Time.now.to_i * 1000 }

  it "read rows" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    chunks_base64 = [
      "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzFIAA==",
      "IGIyC3ZhbHVlLVZBTF8ySAA=",
      "QAE=",
      "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzJIAQ=="
    ]
    chunks = chunks_base64.map do |chunk|
      Google::Bigtable::V2::ReadRowsResponse::CellChunk.decode(Base64.decode64(chunk))
    end
    get_res = [Google::Bigtable::V2::ReadRowsResponse.new(chunks: chunks)]

    mock.expect :read_rows, get_res, [
      table_path(instance_id, table_id),
      rows: Google::Bigtable::V2::RowSet.new,
      filter: nil,
      rows_limit: nil,
      app_profile_id: nil
    ]

    expected_row = Google::Cloud::Bigtable::Row.new("RK")
    expected_row.cells["A"] << Google::Cloud::Bigtable::Row::Cell.new(
      "A", "C", 100, "value-VAL_2"
    )
    rows = table.read_rows.map {|v| v}

    mock.verify

    rows.length.must_equal 1
    rows.first.column_families.must_equal ["A"]
    rows.first.must_equal expected_row
  end

  it "retry on retyable error" do
    chunks_base64 = [
      "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzFIAA==",
      "IGIyC3ZhbHVlLVZBTF8ySAA=",
      "QAE=",
      "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzJIAQ=="
    ]
    chunks = chunks_base64.map do |chunk|
      Google::Bigtable::V2::ReadRowsResponse::CellChunk.decode(Base64.decode64(chunk))
    end

    mock = OpenStruct.new(
      retry_count: 0,
      read_response: [Google::Bigtable::V2::ReadRowsResponse.new(chunks: chunks)]
    )

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      if retry_count == 0
        self.retry_count += 1
        raise GRPC::DeadlineExceeded, "Dead line exceeded"
      else
        read_response
      end
    end

    expected_row = Google::Cloud::Bigtable::Row.new("RK")
    expected_row.cells["A"] << Google::Cloud::Bigtable::Row::Cell.new(
      "A", "C", 100, "value-VAL_2"
    )

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    rows = table.read_rows.map {|v| v}

    mock.retry_count.must_equal 1
    rows.length.must_equal 1
    rows.first.column_families.must_equal ["A"]
    rows.first.must_equal expected_row
  end

  it "do not retry on successive 3 failure" do
    mock = OpenStruct.new(retry_count: 0)

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      self.retry_count += 1
      raise GRPC::DeadlineExceeded, "Dead line exceeded"
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    proc { table.read_rows.to_a }.must_raise Google::Cloud::Error
    mock.retry_count.must_equal 3
  end

  it "reads rows with not successive faliure errors" do
    read_resp_base64 = "ChwKBXRlc3QxEgQKAmNmGggKBmZpZWxkMTIBQUgBChwKBXRlc3QyEgQKAmNm\nGggKBmZpZWxkMTIBQkgBChwKBXRlc3QzEgQKAmNmGggKBmZpZWxkMTIBQ0gB\n"
    read_response = Google::Bigtable::V2::ReadRowsResponse.decode(Base64.decode64(read_resp_base64))

    mock_itr = OpenStruct.new(
      read_response: read_response,
      counter: 0,
    )

    def mock_itr.each
      if counter < 2
        self.counter += 1
        raise GRPC::DeadlineExceeded, "Dead line exceeded"
      end

      yield read_response if self.counter == 2

      if counter == 3
        self.counter += 1
        raise GRPC::DeadlineExceeded, "Dead line exceeded"
      end
    end

    mock = OpenStruct.new(
      mock_itr: mock_itr,
      retry_count: 0
    )
    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      mock_itr
    end

    value = "A"
    expected_rows = 3.times.map do |i|
      row = Google::Cloud::Bigtable::Row.new("test#{i+1}")
      row.cells["cf"] << Google::Cloud::Bigtable::Row::Cell.new(
        "cf", "field1", 0,  value
      )
      value.next!
      row
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    rows = table.read_rows.to_a

    mock_itr.counter.must_equal 2
    rows.length.must_equal 3

    expected_rows.each_with_index do |r, i|
      rows[i].key.must_equal r.key
    end
  end

  it "raise error if retry limit reached" do
    mock = OpenStruct.new(retry_count: 0)

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      self.retry_count += 1
      raise GRPC::DeadlineExceeded, "Dead line exceeded"
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    proc {
      table.read_rows.map {|v| v}
    }.must_raise Google::Cloud::Error
    mock.retry_count.must_equal 3
  end

  it "read rows using row keys" do
    mock = OpenStruct.new

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      rows.row_keys.must_equal ["A", "B"]
      return []
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)
    table.read_rows(keys: ["A", "B"]).map {|v| v}
  end

  it "read rows using single row range" do
    mock = OpenStruct.new

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      rows.row_ranges.length.must_equal 1
      rows.row_ranges.each do |r|
        r.must_be_kind_of Google::Bigtable::V2::RowRange
      end
      return []
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    range = table.new_row_range.from("user-1")
    table.read_rows(ranges: range).map {|v| v}
  end

  it "read rows using multiple row ranges" do
    mock = OpenStruct.new

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      rows.row_ranges.length.must_equal 2
      rows.row_ranges.each do |r|
        r.must_be_kind_of Google::Bigtable::V2::RowRange
      end
      return []
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    range1 = table.new_row_range.from("user-1").to("user-10")
    range2 = table.new_row_range.between("user-100", "user-110")
    table.read_rows(ranges: [range1, range2]).map {|v| v}
  end

  it "read rows using rows limit" do
    mock = OpenStruct.new

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      rows_limit.must_equal 100
      return []
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)
    table.read_rows(limit: 100).map {|v| v}
  end

  it "read rows using rows filter" do
    mock = OpenStruct.new

    def mock.read_rows(parent, rows: nil, filter: nil, rows_limit: nil, app_profile_id: nil)
      filter.must_be_kind_of Google::Bigtable::V2::RowFilter
      return []
    end

    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id)

    filter = table.filter.key("user-*")
    table.read_rows(filter: filter).map {|v| v}
  end
end
