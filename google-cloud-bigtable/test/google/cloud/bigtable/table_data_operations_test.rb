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


require "test_helper"

class DataClientTestError < StandardError
  def initialize(operation_name)
    super("Custom test error for Google::Cloud::Bigtable::V2::BigtableClient##{operation_name}.")
  end
end

def stub_table_data_ops_grpc service_name, mock_method
  mock_stub = MockGrpcClientStub.new(service_name, mock_method)

  # Mock auth layer
  mock_credentials = MockBigtableCredentials.new(service_name.to_s)

  Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
    Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
      yield
    end
  end
end

describe Google::Cloud::Bigtable::TableDataOperations do
  BigtableClient = Google::Cloud::Bigtable::V2::BigtableClient

  let(:project_id) { "test-project-id" }
  let(:instance_id) { "test-instance-id" }
  let(:table_id) { "test-table" }
  let(:instance_path) {
    Google::Cloud::Bigtable::V2::BigtableClient.instance_path(
      project_id,
      instance_id
    )
  }
  let(:table_path) {
    Google::Cloud::Bigtable::V2::BigtableClient.table_path(
      project_id,
      instance_id,
      table_id
    )
  }
  let(:client) {
    Google::Cloud::Bigtable::DataClient.new(
      project_id,
      instance_id
    )
  }

  describe 'read_rows' do
    it 'invokes read_rows without error' do
      # Create expected grpc response
      chunks_base64 = [
        "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzFIAA==",
        "IGIyC3ZhbHVlLVZBTF8ySAA=",
        "QAE=",
        "CgJSSxIDCgFBGgMKAUMgZDILdmFsdWUtVkFMXzJIAQ=="
      ]

      expected_response = Google::Cloud::Bigtable::FlatRow.new("RK")
      expected_response.cells["A"] << Google::Cloud::Bigtable::FlatRow::Cell.new("A", "C", 100, "value-VAL_2")

      chunks = chunks_base64.map do |chunk|
        Google::Bigtable::V2::ReadRowsResponse::CellChunk.decode(
          Base64.decode64(chunk)
        )
      end

      response_chunks = [
        Google::Bigtable::V2::ReadRowsResponse.new(chunks: chunks)
      ]
      # expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::ReadRowsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadRowsRequest, request)
        assert_equal(table_path, request.table_name)
        response_chunks
      end

      stub_table_data_ops_grpc(:read_rows, mock_method) do
        table = client.table(table_id)
        response = table.read_rows

        assert_equal(1, response.count)
        assert_equal(expected_response, response.first)
      end
    end

    it 'invokes read_rows with error' do
      # Create request parameters
      custom_error = DataClientTestError.new("read_rows")
      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadRowsRequest, request)
        assert_equal(table_path, request.table_name)
        raise custom_error
      end

      stub_table_data_ops_grpc(:read_rows, mock_method) do
        table = client.table(table_id)

        err = assert_raises Google::Gax::GaxError do
          table.read_rows
          client.read_rows(formatted_table_name)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'sample_row_keys' do
    it 'invokes sample_row_keys without error' do
      # Create expected grpc response
      row_key = "122"
      offset_bytes = 889884095
      expected_response = { row_key: row_key, offset_bytes: offset_bytes }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::SampleRowKeysResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::SampleRowKeysRequest, request)
        assert_equal(table_path, request.table_name)
        [expected_response]
      end

      stub_table_data_ops_grpc(:sample_row_keys, mock_method) do
        table = client.table(table_id)
        response = table.sample_row_keys

        # Verify the response
        assert_equal(1, response.count)
        assert_equal(expected_response, response.first)
      end
    end

    it 'invokes sample_row_keys with error' do
      custom_error = DataClientTestError.new "sample_row_keys"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::SampleRowKeysRequest, request)
        assert_equal(table_path, request.table_name)
        raise custom_error
      end

      stub_table_data_ops_grpc(:sample_row_keys, mock_method) do
        table = client.table(table_id)

        err = assert_raises Google::Gax::GaxError do
          table.sample_row_keys
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'mutate_row' do
    it 'invokes mutate_row without error' do
      # Create request parameters
      row_key = "RK"

      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key: row_key)
      entry.set_cell({
        family_name: "cf1",
        column_qualifier: "field01",
        timestamp_micros: Time.now.to_i * 1000,
        value: "XYZ"
      })

      # Create expected grpc response
      expected_response = Google::Gax::to_proto({}, Google::Bigtable::V2::MutateRowResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        mutations = entry.mutations.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::Mutation)
        end
        assert_equal(mutations, request.mutations)
        expected_response
      end

      stub_table_data_ops_grpc(:mutate_row, mock_method) do
        table = client.table(table_id)
        response = table.mutate_row(entry)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes mutate_row with error' do
      custom_error = DataClientTestError.new "mutate_row"

      # Create request parameters
      row_key = "RK"
      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key: row_key)
      entry.delete_from_family("cf")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        mutations = entry.mutations.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::Mutation)
        end
        assert_equal(mutations, request.mutations)
        raise custom_error
      end

      stub_table_data_ops_grpc(:mutate_row, mock_method) do
        table = client.table(table_id)
        err = assert_raises Google::Gax::GaxError do
          table.mutate_row(entry)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'mutate_rows' do
    it 'invokes mutate_rows without error' do
      # Create request parameters
      row_key = "RK"

      entry = Google::Cloud::Bigtable::MutationEntry.new(row_key: row_key)
      entry.set_cell({
        family_name: "cf1",
        column_qualifier: "field01",
        timestamp_micros: Time.now.to_i * 1000,
        value: "XYZ"
      })

      entries = [entry]

      # Create expected grpc response
      expected_response = {
        entries: [
          index: 0,
          status: {code: 0, message: "success", details: []}
        ]
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::MutateRowsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowsRequest, request)
        assert_equal(table_path, request.table_name)
        entries = entries.map do |req|
          e = { row_key: req.row_key, mutations: req.mutations }
          Google::Gax::to_proto(e, Google::Bigtable::V2::MutateRowsRequest::Entry)
        end
        assert_equal(entries, request.entries)
        [expected_response]
      end

      stub_table_data_ops_grpc(:mutate_rows, mock_method) do
        table = client.table(table_id)

        response = table.mutate_rows(entries)

        assert_equal(1, response.count)
        assert_equal(expected_response, response.first)
      end
    end

    it 'invokes mutate_rows with error' do
      custom_error = DataClientTestError.new "mutate_rows"
      entries = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowsRequest, request)
        assert_equal(table_path, request.table_name)
        entries = entries.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::MutateRowsRequest::Entry)
        end
        assert_equal(entries, request.entries)
        raise custom_error
      end


      stub_table_data_ops_grpc(:mutate_rows, mock_method) do
        table = client.table(table_id)

        err = assert_raises Google::Gax::GaxError do
          table.mutate_rows(entries)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'check_and_mutate_row' do
    it 'invokes check_and_mutate_row without error' do
      # Create request parameters
      row_key = 'RK1'
      predicate_filter = Google::Bigtable::V2::RowFilter.new

      true_mutation_entry = Google::Cloud::Bigtable::MutationEntry.new
      true_mutation_entry.delete_from_family("cf1")

      false_mutation_entry = Google::Cloud::Bigtable::MutationEntry.new
      false_mutation_entry.delete_from_family("cf2")

      # Create expected grpc response
      predicate_matched = true
      expected_response = { predicate_matched: predicate_matched }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::CheckAndMutateRowResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::CheckAndMutateRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        expected_response
      end

      stub_table_data_ops_grpc(:check_and_mutate_row, mock_method) do
        table = client.table(table_id)

        response = table.check_and_mutate_row(
          row_key,
          predicate_filter: predicate_filter,
          true_mutations: true_mutation_entry,
          false_mutations: false_mutation_entry
        )
        assert_equal(expected_response.predicate_matched, response)
      end
    end

    it 'invokes check_and_mutate_row with error' do
      custom_error = DataClientTestError.new "check_and_mutate_row"

      # Create request parameters
      row_key = 'RK1'

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::CheckAndMutateRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        raise custom_error
      end

      stub_table_data_ops_grpc(:check_and_mutate_row, mock_method) do
        table = client.table(table_id)

        err = assert_raises Google::Gax::GaxError do
          table.check_and_mutate_row(row_key)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'read_modify_write_row' do
    it 'invokes read_modify_write_row without error' do
      # Create request parameters
      row_key = "rk"
      rules = [
        Google::Bigtable::V2::ReadModifyWriteRule.new(
          family_name: "cf",
          column_qualifier: "cq",
          increment_amount: 1
        )
      ]

      # Create expected grpc response
      expected_response_row = {
        key: "rk",
        families:[
          { name:"cf",
            columns: [
              {qualifier: "cq",
                cells:[
                  {
                    timestamp_micros: 100,
                    value: "VAL-1",
                    labels:[]
                  }
                ]
              }
            ]
          }
        ]
      }

      expected_response = Google::Gax::to_proto(
        { row: expected_response_row },
        Google::Bigtable::V2::ReadModifyWriteRowResponse
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadModifyWriteRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        rules = rules.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::ReadModifyWriteRule)
        end
        assert_equal(rules, request.rules)
        expected_response
      end

      stub_table_data_ops_grpc(:read_modify_write_row, mock_method) do
        table = client.table(table_id)
        response = table.read_modify_write_row(row_key, rules)

        assert_instance_of(Google::Cloud::Bigtable::FlatRow, response)
        assert_equal(expected_response.row.key, response.key)

        expected_response.row.families.each do |fm|
          assert_equal(true, response.cells.key?(fm.name))

          # family, qualifier, timestamp_micros, value, labels = []
          cells = fm.columns.map do |col|
            col.cells.map do |c|
              Google::Cloud::Bigtable::FlatRow::Cell.new(
                fm.name,
                col.qualifier,
                c.timestamp_micros,
                c.value,
                c.labels
              )
            end
          end

          cells.flatten!
          assert_equal(cells, response.cells[fm.name])
        end
      end
    end

    it 'invokes read_modify_write_row with error' do
      custom_error = DataClientTestError.new "read_modify_write_row"

      # Create request parameters
      row_key = "RK"
      rules = [
        Google::Bigtable::V2::ReadModifyWriteRule.new(
          family_name: "cf",
          column_qualifier: "CQ",
          increment_amount: 1
        )
      ]

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadModifyWriteRowRequest, request)
        assert_equal(table_path, request.table_name)
        assert_equal(row_key, request.row_key)
        rules = rules.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::ReadModifyWriteRule)
        end
        assert_equal(rules, request.rules)
        raise custom_error
      end

      stub_table_data_ops_grpc(:read_modify_write_row, mock_method) do
        table = client.table(table_id)

        err = assert_raises Google::Gax::GaxError do
          table.read_modify_write_row(row_key, rules)
        end
        assert_match(custom_error.message, err.message)
      end
    end
  end
end
