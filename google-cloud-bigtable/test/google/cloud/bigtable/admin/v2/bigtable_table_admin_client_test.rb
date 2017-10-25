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

require "google/cloud/bigtable/admin"
require "google/cloud/bigtable/admin/v2/bigtable_table_admin_client"
require "google/bigtable/admin/v2/bigtable_table_admin_services_pb"

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

class AdminMockCredentialsClass < Google::Cloud::Bigtable::Admin::Credentials
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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#create_table."

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
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:create_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("create_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.create_table(
            formatted_parent,
            table_id,
            table
          )

          # Verify the response
          assert_equal(expected_response, response)
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
      mock_stub = MockGrpcClientStub.new(:create_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("create_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
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

  describe 'list_tables' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#list_tables."

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
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_tables, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("list_tables")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
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
      mock_stub = MockGrpcClientStub.new(:list_tables, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("list_tables")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_tables(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_table' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#get_table."

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
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("get_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.get_table(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
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
      mock_stub = MockGrpcClientStub.new(:get_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("get_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_table(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_table' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#delete_table."

    it 'invokes delete_table without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteTableRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("delete_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.delete_table(formatted_name)

          # Verify the response
          assert_nil(response)
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
      mock_stub = MockGrpcClientStub.new(:delete_table, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("delete_table")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_table(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'modify_column_families' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#modify_column_families."

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
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:modify_column_families, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("modify_column_families")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.modify_column_families(formatted_name, modifications)

          # Verify the response
          assert_equal(expected_response, response)
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
      mock_stub = MockGrpcClientStub.new(:modify_column_families, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("modify_column_families")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.modify_column_families(formatted_name, modifications)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'drop_row_range' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient#drop_row_range."

    it 'invokes drop_row_range without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableTableAdminClient.table_path("[PROJECT]", "[INSTANCE]", "[TABLE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DropRowRangeRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:drop_row_range, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("drop_row_range")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          response = client.drop_row_range(formatted_name)

          # Verify the response
          assert_nil(response)
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
      mock_stub = MockGrpcClientStub.new(:drop_row_range, mock_method)

      # Mock auth layer
      mock_credentials = AdminMockCredentialsClass.new("drop_row_range")

      Google::Bigtable::Admin::V2::BigtableTableAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableTableAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.drop_row_range(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
