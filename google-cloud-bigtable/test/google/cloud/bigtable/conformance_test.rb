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

      resp = Google::Cloud::Bigtable::V2::ReadRowsResponse.new chunks: test.chunks.to_a
      mock.expect :read_rows, [resp], [
        table_name: table_path(instance_id, table_id),
          rows: Google::Cloud::Bigtable::V2::RowSet.new,
          filter: nil,
          rows_limit: nil,
          app_profile_id: nil
        ]
      rows = table.read_rows
      if test.results.empty? # "no data after reset"
        expect do
          rows.next
        end.must_raise StopIteration
      else
        cells = []
        # Iterate over `results`, fetching rows and cells until each result has been used in assertions
        test.results.each do |result|
          if result.error
            expect do
              rows.next
            end.must_raise Google::Cloud::Bigtable::InvalidRowStateError
          else
            if cells.empty?
              # If cells is empty, either we are just starting, or else we have emptied `cells` from the previous row.
              # We need to fetch a row and cells against which to test the remaining `results`
              row = rows.next
              _(row.key).must_equal result.row_key
              # The cells in a row are in a map, but the corresponding expected
              # results are in a simple array, so convert cells to array.
              cells = row.cells.values.flatten
            end

            cell = cells.shift # take a cell from `cells` against which to test the current `result`
            _(cell.family).must_equal result.family_name
            _(cell.qualifier).must_equal result.qualifier
            _(cell.timestamp).must_equal result.timestamp_micros
            _(cell.value).must_equal result.value
            _(cell.labels.first).must_equal result.label unless result.label.empty?
          end
        end
      end

      # This should be the end of the Enumerator. However, if InvalidRowStateError was raised,
      # another RPC call to read_rows will be attempted.
      expect do
        rows.next
      end.must_raise StopIteration unless test.results.any?(&:error)

      mock.verify
      # end: test method body
    end
  end
end

file_path = File.expand_path "../../../../conformance/v2/readrows.json", __dir__
test_file = Google::Cloud::Conformance::Bigtable::V2::TestFile.decode_json File.read(file_path)
test_file.read_rows_tests.each_with_index do |test, index|
  ReadRowsTest.build_test_for test, index
end
