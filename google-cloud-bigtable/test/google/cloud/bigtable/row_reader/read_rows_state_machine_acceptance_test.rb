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

describe Google::Cloud::Bigtable::RowsReader, :read_state_machine_acceptance, :mock_bigtable do
  class TestResult
    attr_accessor :rk, :fm, :qual, :ts, :value, :label, :error

    def initialize(data)
      data.each do |field, value|
        self.send("#{field}=", value) unless field.to_s == "label"
      end

      if label.nil? || label.empty?
        self.label = []
      elsif !label.is_a?(Array)
        self.label = [label]
      end
    end

    def self.build(results)
      return [] unless results
      results = [results] unless results.is_a?(Array)
      results.map{|data| self.new(data) }
    end

    def == other
      return false if other.nil?

      instance_variables.all? do |var|
        instance_variable_get(var) == other.instance_variable_get(var)
      end
    end
  end

  def chunk_data_to_read_res data
    chunks = data.map do |chunk|
      Google::Bigtable::V2::ReadRowsResponse::CellChunk.decode(Base64.decode64(chunk))
    end

    [Google::Bigtable::V2::ReadRowsResponse.new(chunks: chunks)]
  end

  def convert_rows_to_test_result(rows, error = false)
    test_results = []

    rows.each do |row|
      cells = row.cells.values.flatten
      cells.each do |cell|
        test_results << TestResult.new(
          rk: row.key,
          fm: cell.family,
          qual: cell.qualifier,
          ts: cell.timestamp,
          value: cell.value,
          label: cell.labels,
          error: error
        )
      end
    end

    test_results
  end

  let(:instance_id) { "test-instance" }
  let(:table_id) { "table-id" }

  read_rows_acceptance_test_data[:with_errors].each do |test_data|
    it test_data["name"] do
      mock = Minitest::Mock.new
      bigtable.service.mocked_client = mock

      table = bigtable.table(instance_id, table_id)

      get_res = chunk_data_to_read_res(test_data["chunks_base64"])
      mock.expect :read_rows, get_res, [table_path(instance_id, table_id), Hash]
      proc {
        table.read_rows.each{|v| v}
      }.must_raise Google::Cloud::Bigtable::InvalidRowStateError

      mock.verify
    end
  end

  read_rows_acceptance_test_data[:without_errors].each do |test_data|
    it test_data["name"] do
      mock = Minitest::Mock.new
      bigtable.service.mocked_client = mock
      table = bigtable.table(instance_id, table_id)

      get_res = chunk_data_to_read_res(test_data["chunks_base64"])
      mock.expect :read_rows, get_res, [table_path(instance_id, table_id), Hash]

      expected_result = TestResult.build(test_data["results"])
      expected_families = expected_result.map(&:fm).uniq.sort

      rows = table.read_rows.map{|r| r}
      families = rows.map(&:column_families).flatten.uniq.sort

      families.must_equal expected_families
      result = convert_rows_to_test_result(rows)
      result.length.must_equal expected_result.length

      result.each_with_index do |r, i|
        r.must_equal expected_result[i]
      end
    end
  end
end
