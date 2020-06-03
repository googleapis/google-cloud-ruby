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

require "google/cloud/firestore/v1"
require "google/cloud/firestore/v1/firestore_client"
require "google/firestore/v1/firestore_services_pb"

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

class MockFirestoreCredentials_v1 < Google::Cloud::Firestore::V1::Credentials
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

describe Google::Cloud::Firestore::V1::FirestoreClient do

  describe 'get_document' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#get_document."

    it 'invokes get_document without error' do
      # Create request parameters
      name = ''

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::GetDocumentRequest, request)
        assert_equal(name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("get_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.get_document(name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_document(name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_document with error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::GetDocumentRequest, request)
        assert_equal(name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("get_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_document(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_documents' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#list_documents."

    it 'invokes list_documents without error' do
      # Create request parameters
      parent = ''
      collection_id = ''

      # Create expected grpc response
      next_page_token = ""
      documents_element = {}
      documents = [documents_element]
      expected_response = { next_page_token: next_page_token, documents: documents }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::ListDocumentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::ListDocumentsRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("list_documents")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.list_documents(parent, collection_id)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.documents.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_documents with error' do
      # Create request parameters
      parent = ''
      collection_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::ListDocumentsRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("list_documents")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_documents(parent, collection_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_document' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#create_document."

    it 'invokes create_document without error' do
      # Create request parameters
      parent = ''
      collection_id = ''
      document = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::CreateDocumentRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1::Document), request.document)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("create_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.create_document(
            parent,
            collection_id,
            document
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_document(
            parent,
            collection_id,
            document
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_document with error' do
      # Create request parameters
      parent = ''
      collection_id = ''
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::CreateDocumentRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("create_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_document(
              parent,
              collection_id,
              document
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_document' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#update_document."

    it 'invokes update_document without error' do
      # Create request parameters
      document = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::UpdateDocumentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1::Document), request.document)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("update_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.update_document(document)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_document(document) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_document with error' do
      # Create request parameters
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::UpdateDocumentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("update_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_document(document)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_document' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#delete_document."

    it 'invokes delete_document without error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::DeleteDocumentRequest, request)
        assert_equal(name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("delete_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.delete_document(name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_document(name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_document with error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::DeleteDocumentRequest, request)
        assert_equal(name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_document, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("delete_document")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_document(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_get_documents' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#batch_get_documents."

    it 'invokes batch_get_documents without error' do
      # Create request parameters
      database = ''

      # Create expected grpc response
      missing = "missing1069449574"
      transaction = "-34"
      expected_response = { missing: missing, transaction: transaction }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::BatchGetDocumentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BatchGetDocumentsRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_get_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("batch_get_documents")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.batch_get_documents(database)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes batch_get_documents with error' do
      # Create request parameters
      database = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BatchGetDocumentsRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_get_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("batch_get_documents")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.batch_get_documents(database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'begin_transaction' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#begin_transaction."

    it 'invokes begin_transaction without error' do
      # Create request parameters
      database = ''

      # Create expected grpc response
      transaction = "-34"
      expected_response = { transaction: transaction }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::BeginTransactionResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BeginTransactionRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("begin_transaction")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.begin_transaction(database)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.begin_transaction(database) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes begin_transaction with error' do
      # Create request parameters
      database = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BeginTransactionRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("begin_transaction")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.begin_transaction(database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'commit' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#commit."

    it 'invokes commit without error' do
      # Create request parameters
      database = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::CommitResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::CommitRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("commit")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.commit(database)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.commit(database) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes commit with error' do
      # Create request parameters
      database = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::CommitRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("commit")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.commit(database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'rollback' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#rollback."

    it 'invokes rollback without error' do
      # Create request parameters
      database = ''
      transaction = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::RollbackRequest, request)
        assert_equal(database, request.database)
        assert_equal(transaction, request.transaction)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("rollback")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.rollback(database, transaction)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.rollback(database, transaction) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes rollback with error' do
      # Create request parameters
      database = ''
      transaction = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::RollbackRequest, request)
        assert_equal(database, request.database)
        assert_equal(transaction, request.transaction)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("rollback")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.rollback(database, transaction)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_query' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#run_query."

    it 'invokes run_query without error' do
      # Create request parameters
      parent = ''

      # Create expected grpc response
      transaction = "-34"
      skipped_results = 880286183
      expected_response = { transaction: transaction, skipped_results: skipped_results }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::RunQueryResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::RunQueryRequest, request)
        assert_equal(parent, request.parent)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:run_query, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("run_query")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.run_query(parent)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes run_query with error' do
      # Create request parameters
      parent = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::RunQueryRequest, request)
        assert_equal(parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:run_query, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("run_query")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.run_query(parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'write' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#write."

    it 'invokes write without error' do
      # Create request parameters
      database = ''
      request = { database: database }

      # Create expected grpc response
      stream_id = "streamId-315624902"
      stream_token = "122"
      expected_response = { stream_id: stream_id, stream_token: stream_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::WriteResponse)

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1::WriteRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:write, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("write")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.write([request])

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes write with error' do
      # Create request parameters
      database = ''
      request = { database: database }

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1::WriteRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:write, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("write")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.write([request])
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'listen' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#listen."

    it 'invokes listen without error' do
      # Create request parameters
      database = ''
      request = { database: database }

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::ListenResponse)

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1::ListenRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub_v1.new(:listen, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("listen")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.listen([request])

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes listen with error' do
      # Create request parameters
      database = ''
      request = { database: database }

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1::ListenRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:listen, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("listen")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.listen([request])
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_collection_ids' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#list_collection_ids."

    it 'invokes list_collection_ids without error' do
      # Create request parameters
      parent = ''

      # Create expected grpc response
      next_page_token = ""
      collection_ids_element = "collectionIdsElement1368994900"
      collection_ids = [collection_ids_element]
      expected_response = { next_page_token: next_page_token, collection_ids: collection_ids }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::ListCollectionIdsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::ListCollectionIdsRequest, request)
        assert_equal(parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_collection_ids, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("list_collection_ids")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.list_collection_ids(parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.collection_ids.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_collection_ids with error' do
      # Create request parameters
      parent = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::ListCollectionIdsRequest, request)
        assert_equal(parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_collection_ids, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("list_collection_ids")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_collection_ids(parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'partition_query' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#partition_query."

    it 'invokes partition_query without error' do
      # Create request parameters
      parent = ''

      # Create expected grpc response
      next_page_token = ""
      partitions_element = {}
      partitions = [partitions_element]
      expected_response = { next_page_token: next_page_token, partitions: partitions }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::PartitionQueryResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::PartitionQueryRequest, request)
        assert_equal(parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_query, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("partition_query")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.partition_query(parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.partitions.to_a, response.to_a)
        end
      end
    end

    it 'invokes partition_query with error' do
      # Create request parameters
      parent = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::PartitionQueryRequest, request)
        assert_equal(parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:partition_query, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("partition_query")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.partition_query(parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_write' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Firestore::V1::FirestoreClient#batch_write."

    it 'invokes batch_write without error' do
      # Create request parameters
      database = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1::BatchWriteResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BatchWriteRequest, request)
        assert_equal(database, request.database)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_write, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("batch_write")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          response = client.batch_write(database)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_write(database) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_write with error' do
      # Create request parameters
      database = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1::BatchWriteRequest, request)
        assert_equal(database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:batch_write, mock_method)

      # Mock auth layer
      mock_credentials = MockFirestoreCredentials_v1.new("batch_write")

      Google::Firestore::V1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.batch_write(database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end