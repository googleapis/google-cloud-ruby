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

require "helper"

require "google/gax"

require "google/cloud/firestore/admin"
require "google/cloud/firestore/admin/v1/firestore_admin_client"
require "google/firestore/admin/v1/firestore_admin_services_pb"

class CustomTestError_v1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1

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

class MockFirestoreAdminCredentials_v1 < Google::Cloud::Firestore::Admin::V1::Credentials
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

describe Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient do

  describe 'create_index' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#create_index."

    it 'invokes create_index without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")
      index = {}

      # Create expected grpc response
      name = "name3373707"
      done = true
      expected_response = { name: name, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::CreateIndexRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(index, Google::Firestore::Admin::V1::Index), request.index)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("create_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.create_index(formatted_parent, index)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_index(formatted_parent, index) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_index with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")
      index = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::CreateIndexRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(index, Google::Firestore::Admin::V1::Index), request.index)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("create_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_index(formatted_parent, index)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_indexes' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#list_indexes."

    it 'invokes list_indexes without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")

      # Create expected grpc response
      next_page_token = ""
      indexes_element = {}
      indexes = [indexes_element]
      expected_response = { next_page_token: next_page_token, indexes: indexes }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::Admin::V1::ListIndexesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ListIndexesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_indexes, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("list_indexes")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.list_indexes(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.indexes.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_indexes with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ListIndexesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_indexes, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("list_indexes")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_indexes(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_index' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#get_index."

    it 'invokes get_index without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[INDEX_ID]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::Admin::V1::Index)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::GetIndexRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("get_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.get_index(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_index(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_index with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[INDEX_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::GetIndexRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("get_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_index(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_index' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#delete_index."

    it 'invokes delete_index without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[INDEX_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::DeleteIndexRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("delete_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.delete_index(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_index(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_index with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.index_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[INDEX_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::DeleteIndexRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_index, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("delete_index")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_index(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'import_documents' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#import_documents."

    it 'invokes import_documents without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      done = true
      expected_response = { name: name_2, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ImportDocumentsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("import_documents")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.import_documents(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.import_documents(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes import_documents with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ImportDocumentsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:import_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("import_documents")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.import_documents(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'export_documents' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#export_documents."

    it 'invokes export_documents without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      done = true
      expected_response = { name: name_2, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ExportDocumentsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:export_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("export_documents")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.export_documents(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.export_documents(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes export_documents with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.database_path("[PROJECT]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ExportDocumentsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:export_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("export_documents")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.export_documents(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_field' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#get_field."

    it 'invokes get_field without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.field_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[FIELD_ID]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::Admin::V1::Field)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::GetFieldRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_field, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("get_field")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.get_field(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_field(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_field with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.field_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]", "[FIELD_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::GetFieldRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_field, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("get_field")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_field(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_fields' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#list_fields."

    it 'invokes list_fields without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")

      # Create expected grpc response
      next_page_token = ""
      fields_element = {}
      fields = [fields_element]
      expected_response = { next_page_token: next_page_token, fields: fields }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::Admin::V1::ListFieldsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ListFieldsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_fields, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("list_fields")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.list_fields(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.fields.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_fields with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient.parent_path("[PROJECT]", "[DATABASE]", "[COLLECTION_ID]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::ListFieldsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_fields, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("list_fields")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_fields(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_field' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient#update_field."

    it 'invokes update_field without error' do
      # Create request parameters
      field = {}

      # Create expected grpc response
      name = "name3373707"
      done = true
      expected_response = { name: name, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::UpdateFieldRequest, request)
        assert_equal(Google::Gax::to_proto(field, Google::Firestore::Admin::V1::Field), request.field)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_field, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("update_field")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          response = client.update_field(field)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_field(field) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_field with error' do
      # Create request parameters
      field = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::Admin::V1::UpdateFieldRequest, request)
        assert_equal(Google::Gax::to_proto(field, Google::Firestore::Admin::V1::Field), request.field)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_field, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreAdminCredentials_v1.new("update_field")

      Google::Firestore::Admin::V1::FirestoreAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Admin::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::Admin.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_field(field)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
