# Copyright 2017, Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/bigtable"
require "google/cloud/bigtable/v2/bigtable_client"
require "google/bigtable/v2/bigtable_services_pb"

class CustomTestError < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub

  # @param expected_symbol [Symbol] the symbol of the grpc method to be mocked.
  # @param mock_method [Proc] The method that is being mocked.
  def initialize(expected_symbol, mock_method)
    @expected_symbol = expected_symbol
    @mock_method = mock_method
  end

  # This overrides the Object#method method to return the mocked method when the mocked method
  # is being requested. For methods that aren't being tested, this method returns a proc that
  # will raise an error when called. This is to assure that only the mocked grpc method is being
  # called.
  #
  # @param symbol [Symbol] The symbol of the method being requested.
  # @return [Proc] The proc of the requested method. If the requested method is not being mocked
  #   the proc returned will raise when called.
  def method(symbol)
    return @mock_method if symbol == @expected_symbol

    # The requested method is not being tested, raise if it called.
    proc do
      raise "The method #{symbol} was unexpectedly called during the " \
        "test for #{@expected_symbol}."
    end
  end
end

class BigtableMockCredentialsClass < Google::Cloud::Bigtable::Credentials
  def initialize(method_name)
    @method_name = method_name
  end

  def updater_proc
    proc do
      raise "The method `#{@method_name}` was trying to make a grpc request. This should not " \
          "happen since the grpc layer is being mocked."
    end
  end
end

describe Google::Cloud::Bigtable::V2::BigtableClient do

  describe 'read_rows' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#read_rows."

    it 'invokes read_rows without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Create expected grpc response
      last_scanned_row_key = "-126"
      expected_response = { last_scanned_row_key: last_scanned_row_key }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::ReadRowsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadRowsRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:read_rows, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("read_rows")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.read_rows(formatted_table_name)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes read_rows with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadRowsRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:read_rows, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("read_rows")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.read_rows(formatted_table_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'sample_row_keys' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#sample_row_keys."

    it 'invokes sample_row_keys without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Create expected grpc response
      row_key = "122"
      offset_bytes = 889884095
      expected_response = { row_key: row_key, offset_bytes: offset_bytes }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::SampleRowKeysResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::SampleRowKeysRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:sample_row_keys, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("sample_row_keys")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.sample_row_keys(formatted_table_name)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes sample_row_keys with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::SampleRowKeysRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:sample_row_keys, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("sample_row_keys")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.sample_row_keys(formatted_table_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'mutate_row' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#mutate_row."

    it 'invokes mutate_row without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''
      mutations = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::MutateRowResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        mutations = mutations.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::Mutation)
        end
        assert_equal(mutations, request.mutations)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:mutate_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("mutate_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.mutate_row(
            formatted_table_name,
            row_key,
            mutations
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes mutate_row with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''
      mutations = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        mutations = mutations.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::Mutation)
        end
        assert_equal(mutations, request.mutations)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:mutate_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("mutate_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.mutate_row(
              formatted_table_name,
              row_key,
              mutations
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'mutate_rows' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#mutate_rows."

    it 'invokes mutate_rows without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      entries = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::MutateRowsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowsRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        entries = entries.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::MutateRowsRequest::Entry)
        end
        assert_equal(entries, request.entries)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:mutate_rows, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("mutate_rows")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.mutate_rows(formatted_table_name, entries)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes mutate_rows with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      entries = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::MutateRowsRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        entries = entries.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::MutateRowsRequest::Entry)
        end
        assert_equal(entries, request.entries)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:mutate_rows, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("mutate_rows")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.mutate_rows(formatted_table_name, entries)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'check_and_mutate_row' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#check_and_mutate_row."

    it 'invokes check_and_mutate_row without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''

      # Create expected grpc response
      predicate_matched = true
      expected_response = { predicate_matched: predicate_matched }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::CheckAndMutateRowResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::CheckAndMutateRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:check_and_mutate_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("check_and_mutate_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.check_and_mutate_row(formatted_table_name, row_key)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes check_and_mutate_row with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::CheckAndMutateRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:check_and_mutate_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("check_and_mutate_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.check_and_mutate_row(formatted_table_name, row_key)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'read_modify_write_row' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::V2::BigtableClient#read_modify_write_row."

    it 'invokes read_modify_write_row without error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''
      rules = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::V2::ReadModifyWriteRowResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadModifyWriteRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        rules = rules.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::ReadModifyWriteRule)
        end
        assert_equal(rules, request.rules)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:read_modify_write_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("read_modify_write_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          response = client.read_modify_write_row(
            formatted_table_name,
            row_key,
            rules
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes read_modify_write_row with error' do
      # Create request parameters
      formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      row_key = ''
      rules = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::V2::ReadModifyWriteRowRequest, request)
        assert_equal(formatted_table_name, request.table_name)
        assert_equal(row_key, request.row_key)
        rules = rules.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::V2::ReadModifyWriteRule)
        end
        assert_equal(rules, request.rules)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:read_modify_write_row, mock_method)

      # Mock auth layer
      mock_credentials = BigtableMockCredentialsClass.new("read_modify_write_row")

      Google::Bigtable::V2::Bigtable::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.read_modify_write_row(
              formatted_table_name,
              row_key,
              rules
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
