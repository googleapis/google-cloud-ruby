# frozen_string_literal: true

require "test_helper"

def read_rows_acceptance_test_data
  @tests if @tests

  @tests = { with_errors: [], without_errors: [] }
  data = load_test_json_data("read-rows-acceptance-test")
  data["tests"].each do |t|

    if t["results"] && t["results"].any? { |r| r["error"] }
      @tests[:with_errors] << t
    else
      @tests[:without_errors] << t
    end
  end

  @tests
end

describe "Read rows state machine acceptance tests" do
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

  def stub_client_grpc service_name, mock_method
    mock_stub = MockGrpcClientStub.new(service_name, mock_method)
    mock_credentials = MockBigtableCredentials.new(service_name.to_s)

    Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
      Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
        client = Google::Cloud::Bigtable::DataClient.new("project-id", "instance-id")
        table = client.table('test-table')
        yield table
      end
    end
  end

  def chunk_data_to_read_res data
    chunks = data.map do |chunk|
      Google::Bigtable::V2::ReadRowsResponse::CellChunk.decode(
        Base64.decode64(chunk)
      )
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
          ts: cell.timestamp_micros,
          value: cell.value,
          label: cell.labels,
          error: error
        )
      end
    end

    test_results
  end

  read_rows_acceptance_test_data[:with_errors].each do |test_data|
    it test_data["name"] do
      mock_method = proc do |_request|
        chunk_data_to_read_res(test_data["chunks_base64"])
      end

      assert_raises Google::Cloud::Bigtable::InvalidRowStateError do
        stub_client_grpc(:read_rows, mock_method, &:read_rows)
      end
    end
  end

  read_rows_acceptance_test_data[:without_errors].each do |test_data|
    it test_data["name"] do
      mock_method = proc do |_request|
        chunk_data_to_read_res(test_data["chunks_base64"])
      end

      expected_result = TestResult.build(test_data["results"])
      expected_families = expected_result.map(&:fm).uniq.sort

      stub_client_grpc(:read_rows, mock_method) do |table|
        rows = table.read_rows

        families = rows.map(&:column_families).flatten.uniq.sort
        assert_equal(expected_families, families)

        result = convert_rows_to_test_result(rows)

        assert_equal(expected_result.length, result.length)
        expected_result.each_with_index do |expected_value, i|
          assert_equal(expected_value, result[i])
        end
      end
    end
  end
end
