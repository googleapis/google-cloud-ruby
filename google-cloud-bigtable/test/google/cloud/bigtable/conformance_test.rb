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

require "helper.rb"
require_relative "../../../../conformance/v2/proto/google/cloud/conformance/bigtable/v2/tests_pb.rb"

##
# This suite of unit tests is dynamically generated from the contents of
# `conformance/v2/*.json`, using the protobuf types defined in
# `conformance/v2/proto/google/cloud/conformance/bigtable/v2/tests_pb.rb`, which
# was manually generated from
# `conformance/v2/proto/google/cloud/conformance/bigtable/v2/tests.proto`.
#
# The `conformance/v2` directory was manually imported (copied) from
# https://github.com/googleapis/conformance-tests/tree/master/bigtable/v2.
#
# See [Protocol Buffers - Ruby Generated
# Code](https://developers.google.com/protocol-buffers/docs/reference/ruby-generated)
# for instructions in case `tests.proto` is updated.
#
class ReadRowsTest < MockBigtable
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  def self.build_test_for test, index
    define_method("test_#{index}: #{test.description}") do
      # start: test method body
      mock = Minitest::Mock.new
      bigtable.service.mocked_client = mock

      table = bigtable.table(instance_id, table_id)

      resp = Google::Bigtable::V2::ReadRowsResponse.new(chunks: test.chunks.to_a)

      mock.expect :read_rows, [resp], [
                              table_path(instance_id, table_id),
                              rows: Google::Bigtable::V2::RowSet.new,
                              filter: nil,
                              rows_limit: nil,
                              app_profile_id: nil
                            ]

      results = test.results.to_a
      if results.map(&:error).include? true
        expect do
          table.read_rows.to_a # to_a is needed because Enum lazily invokes read_rows
        end.must_raise Google::Cloud::Bigtable::InvalidRowStateError
      else
        rows = table.read_rows.to_a  # to_a is needed because Enum lazily invokes read_rows
        rows.map(&:key).must_equal results.map(&:row_key).uniq

        # The actual rows and cells in `rows` are nested, but the corresponding
        # expected results are in a simple array, so flatten all cells in `rows`.
        cells = rows.map do |row|
          row.cells.values.flatten
        end.flatten

        cells.size.must_equal results.size
        cells.each_with_index do |cell, index|
          expected = results[index]
          cell.family.must_equal expected.family_name
          cell.qualifier.must_equal expected.qualifier
          cell.timestamp.must_equal expected.timestamp_micros
          cell.value.must_equal expected.value
          cell.labels.first.must_equal expected.label unless expected.label.empty?
        end
      end

      mock.verify
      # end: test method body
    end
  end
end

file_path = "conformance/v2/readrows.json"
test_file = Google::Cloud::Conformance::Bigtable::V2::TestFile.decode_json File.read(file_path)
test_file.read_rows_tests.each_with_index do |test, index|
  ReadRowsTest.build_test_for test, index
end
