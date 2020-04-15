# Copyright 2020 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/bigtable/admin"
require "google/cloud/bigtable/admin/v2/bigtable_table_admin_client"
require "google/bigtable/admin/v2/bigtable_table_admin_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError_v2 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v2

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

class MockBigtableTableAdminCredentials_v2 < Google::Cloud::Bigtable::Admin::V2::Credentials
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

describe Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient do

  describe 'create_table' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_table."

    it 'invokes create_table without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      table_id = ''
      table = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Google::Bigtable::Admin::V2::Table), request.table)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_table(
            formatted_parent,
            table_id,
            table
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_table(
            formatted_parent,
            table_id,
            table
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_table with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      table_id = ''
      table = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(Google::Gax::to_proto(table, Google::Bigtable::Admin::V2::Table), request.table)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.create_table(
              formatted_parent,
              table_id,
              table
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_table_from_snapshot' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_table_from_snapshot."

    it 'invokes create_table_from_snapshot without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      table_id = ''
      formatted_source_snapshot = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_table_from_snapshot_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(formatted_source_snapshot, request.source_snapshot)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_table_from_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_table_from_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_table_from_snapshot(
            formatted_parent,
            table_id,
            formatted_source_snapshot
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_table_from_snapshot and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      table_id = ''
      formatted_source_snapshot = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_table_from_snapshot.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_table_from_snapshot_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(formatted_source_snapshot, request.source_snapshot)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_table_from_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_table_from_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_table_from_snapshot(
            formatted_parent,
            table_id,
            formatted_source_snapshot
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_table_from_snapshot with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      table_id = ''
      formatted_source_snapshot = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateTableFromSnapshotRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(table_id, request.table_id)
        assert_equal(formatted_source_snapshot, request.source_snapshot)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_table_from_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_table_from_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.create_table_from_snapshot(
              formatted_parent,
              table_id,
              formatted_source_snapshot
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_tables' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#list_tables."

    it 'invokes list_tables without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      next_page_token = ""
      tables_element = {}
      tables = [tables_element]
      expected_response = { next_page_token: next_page_token, tables: tables }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListTablesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListTablesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_tables, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_tables")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.list_tables(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.tables.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_tables with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListTablesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_tables, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_tables")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.list_tables(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_table' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#get_table."

    it 'invokes get_table without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.get_table(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_table(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_table with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetTableRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.get_table(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_table' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#delete_table."

    it 'invokes delete_table without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.delete_table(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_table(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_table with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.delete_table(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'modify_column_families' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#modify_column_families."

    it 'invokes modify_column_families without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      modifications = []

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(formatted_name, request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:modify_column_families, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("modify_column_families")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.modify_column_families(formatted_name, modifications)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.modify_column_families(formatted_name, modifications) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes modify_column_families with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      modifications = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest, request)
        assert_equal(formatted_name, request.name)
        modifications = modifications.map do |req|
          Google::Gax::to_proto(req, Google::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification)
        end
        assert_equal(modifications, request.modifications)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:modify_column_families, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("modify_column_families")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.modify_column_families(formatted_name, modifications)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'drop_row_range' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#drop_row_range."

    it 'invokes drop_row_range without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:drop_row_range, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("drop_row_range")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.drop_row_range(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.drop_row_range(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes drop_row_range with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:drop_row_range, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("drop_row_range")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.drop_row_range(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'generate_consistency_token' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#generate_consistency_token."

    it 'invokes generate_consistency_token without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Create expected grpc response
      consistency_token = "consistencyToken-1090516718"
      expected_response = { consistency_token: consistency_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::GenerateConsistencyTokenResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GenerateConsistencyTokenRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:generate_consistency_token, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("generate_consistency_token")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.generate_consistency_token(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.generate_consistency_token(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes generate_consistency_token with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GenerateConsistencyTokenRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:generate_consistency_token, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("generate_consistency_token")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.generate_consistency_token(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'check_consistency' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#check_consistency."

    it 'invokes check_consistency without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      consistency_token = ''

      # Create expected grpc response
      consistent = true
      expected_response = { consistent: consistent }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::CheckConsistencyResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CheckConsistencyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(consistency_token, request.consistency_token)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:check_consistency, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("check_consistency")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.check_consistency(formatted_name, consistency_token)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.check_consistency(formatted_name, consistency_token) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes check_consistency with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      consistency_token = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CheckConsistencyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(consistency_token, request.consistency_token)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:check_consistency, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("check_consistency")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.check_consistency(formatted_name, consistency_token)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      resource = ''

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_iam_policy")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.get_iam_policy(resource)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_iam_policy(resource) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      resource = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_iam_policy")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.get_iam_policy(resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      resource = ''
      policy = {}

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("set_iam_policy")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.set_iam_policy(resource, policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_iam_policy(resource, policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      resource = ''
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("set_iam_policy")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.set_iam_policy(resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      resource = ''
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(permissions, request.permissions)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("test_iam_permissions")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.test_iam_permissions(resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.test_iam_permissions(resource, permissions) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      resource = ''
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("test_iam_permissions")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.test_iam_permissions(resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'snapshot_table' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#snapshot_table."

    it 'invokes snapshot_table without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      formatted_cluster = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      snapshot_id = ''

      # Create expected grpc response
      name_2 = "name2-1052831874"
      data_size_bytes = 2110122398
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        data_size_bytes: data_size_bytes,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Snapshot)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/snapshot_table_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::SnapshotTableRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(formatted_cluster, request.cluster)
        assert_equal(snapshot_id, request.snapshot_id)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:snapshot_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("snapshot_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.snapshot_table(
            formatted_name,
            formatted_cluster,
            snapshot_id
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes snapshot_table and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      formatted_cluster = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      snapshot_id = ''

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#snapshot_table.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/snapshot_table_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::SnapshotTableRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(formatted_cluster, request.cluster)
        assert_equal(snapshot_id, request.snapshot_id)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:snapshot_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("snapshot_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.snapshot_table(
            formatted_name,
            formatted_cluster,
            snapshot_id
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes snapshot_table with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")
      formatted_cluster = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      snapshot_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::SnapshotTableRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(formatted_cluster, request.cluster)
        assert_equal(snapshot_id, request.snapshot_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:snapshot_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("snapshot_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.snapshot_table(
              formatted_name,
              formatted_cluster,
              snapshot_id
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_snapshot' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#get_snapshot."

    it 'invokes get_snapshot without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      data_size_bytes = 2110122398
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        data_size_bytes: data_size_bytes,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Snapshot)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetSnapshotRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.get_snapshot(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_snapshot(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_snapshot with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetSnapshotRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.get_snapshot(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_snapshots' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#list_snapshots."

    it 'invokes list_snapshots without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Create expected grpc response
      next_page_token = ""
      snapshots_element = {}
      snapshots = [snapshots_element]
      expected_response = { next_page_token: next_page_token, snapshots: snapshots }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListSnapshotsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListSnapshotsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_snapshots, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_snapshots")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.list_snapshots(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.snapshots.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_snapshots with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListSnapshotsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_snapshots, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_snapshots")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.list_snapshots(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_snapshot' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#delete_snapshot."

    it 'invokes delete_snapshot without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteSnapshotRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.delete_snapshot(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_snapshot(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_snapshot with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.snapshot_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[SNAPSHOT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteSnapshotRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_snapshot, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_snapshot")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.delete_snapshot(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_backup' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_backup."

    it 'invokes create_backup without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      backup_id = ''
      backup = {}

      # Create expected grpc response
      name = "name3373707"
      source_table = "sourceTable1670858410"
      size_bytes = 1796325715
      expected_response = {
        name: name,
        source_table: source_table,
        size_bytes: size_bytes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Backup)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_backup_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateBackupRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(backup_id, request.backup_id)
        assert_equal(Google::Gax::to_proto(backup, Google::Bigtable::Admin::V2::Backup), request.backup)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_backup(
            formatted_parent,
            backup_id,
            backup
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_backup and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      backup_id = ''
      backup = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_backup.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_backup_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateBackupRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(backup_id, request.backup_id)
        assert_equal(Google::Gax::to_proto(backup, Google::Bigtable::Admin::V2::Backup), request.backup)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_backup(
            formatted_parent,
            backup_id,
            backup
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_backup with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      backup_id = ''
      backup = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateBackupRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(backup_id, request.backup_id)
        assert_equal(Google::Gax::to_proto(backup, Google::Bigtable::Admin::V2::Backup), request.backup)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("create_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.create_backup(
              formatted_parent,
              backup_id,
              backup
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_backup' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#get_backup."

    it 'invokes get_backup without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.backup_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[BACKUP]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      source_table = "sourceTable1670858410"
      size_bytes = 1796325715
      expected_response = {
        name: name_2,
        source_table: source_table,
        size_bytes: size_bytes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Backup)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetBackupRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.get_backup(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_backup(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_backup with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.backup_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[BACKUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetBackupRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("get_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.get_backup(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_backups' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#list_backups."

    it 'invokes list_backups without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Create expected grpc response
      next_page_token = ""
      backups_element = {}
      backups = [backups_element]
      expected_response = { next_page_token: next_page_token, backups: backups }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListBackupsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListBackupsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_backups, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_backups")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.list_backups(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.backups.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_backups with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListBackupsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_backups, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("list_backups")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.list_backups(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_backup' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#update_backup."

    it 'invokes update_backup without error' do
      # Create request parameters
      backup = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      source_table = "sourceTable1670858410"
      size_bytes = 1796325715
      expected_response = {
        name: name,
        source_table: source_table,
        size_bytes: size_bytes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Backup)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::UpdateBackupRequest, request)
        assert_equal(Google::Gax::to_proto(backup, Google::Bigtable::Admin::V2::Backup), request.backup)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("update_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.update_backup(backup, update_mask)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_backup(backup, update_mask) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_backup with error' do
      # Create request parameters
      backup = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::UpdateBackupRequest, request)
        assert_equal(Google::Gax::to_proto(backup, Google::Bigtable::Admin::V2::Backup), request.backup)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("update_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.update_backup(backup, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_backup' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#delete_backup."

    it 'invokes delete_backup without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.backup_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[BACKUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteBackupRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.delete_backup(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_backup(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_backup with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.backup_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]", "[BACKUP]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteBackupRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_backup, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("delete_backup")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.delete_backup(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'restore_table' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#restore_table."

    it 'invokes restore_table without error' do
      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Table)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/restore_table_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:restore_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("restore_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.restore_table

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes restore_table and returns an operation error.' do
      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#restore_table.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/restore_table_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:restore_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("restore_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.restore_table

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes restore_table with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:restore_table, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableTableAdminCredentials_v2.new("restore_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v2 do
            client.restore_table
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end