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

require "google/cloud/firestore"
require "google/cloud/firestore/v1beta1/firestore_client"
require "google/firestore/v1beta1/firestore_services_pb"

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

class MockCredentialsClass < Google::Cloud::Firestore::Credentials
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

describe Google::Cloud::Firestore::V1beta1::FirestoreClient do

  describe 'get_document' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#get_document."

    it 'invokes get_document without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::GetDocumentRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("get_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.get_document(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_document with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::GetDocumentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("get_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_document(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_documents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#list_documents."

    it 'invokes list_documents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
      collection_id = ''

      # Create expected grpc response
      next_page_token = ""
      documents_element = {}
      documents = [documents_element]
      expected_response = { next_page_token: next_page_token, documents: documents }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::ListDocumentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::ListDocumentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("list_documents")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.list_documents(formatted_parent, collection_id)

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
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
      collection_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::ListDocumentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("list_documents")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_documents(formatted_parent, collection_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_document' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#create_document."

    it 'invokes create_document without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
      collection_id = ''
      document_id = ''
      document = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::CreateDocumentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        assert_equal(document_id, request.document_id)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1beta1::Document), request.document)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:create_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("create_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.create_document(
            formatted_parent,
            collection_id,
            document_id,
            document
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_document with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")
      collection_id = ''
      document_id = ''
      document = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::CreateDocumentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(collection_id, request.collection_id)
        assert_equal(document_id, request.document_id)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1beta1::Document), request.document)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("create_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_document(
              formatted_parent,
              collection_id,
              document_id,
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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#update_document."

    it 'invokes update_document without error' do
      # Create request parameters
      document = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      expected_response = { name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::Document)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::UpdateDocumentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1beta1::Document), request.document)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Firestore::V1beta1::DocumentMask), request.update_mask)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:update_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("update_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.update_document(document, update_mask)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_document with error' do
      # Create request parameters
      document = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::UpdateDocumentRequest, request)
        assert_equal(Google::Gax::to_proto(document, Google::Firestore::V1beta1::Document), request.document)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Firestore::V1beta1::DocumentMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("update_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_document(document, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_document' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#delete_document."

    it 'invokes delete_document without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::DeleteDocumentRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("delete_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.delete_document(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_document with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::DeleteDocumentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_document, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("delete_document")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_document(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_get_documents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#batch_get_documents."

    it 'invokes batch_get_documents without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      documents = []

      # Create expected grpc response
      missing = "missing1069449574"
      transaction = "-34"
      expected_response = { missing: missing, transaction: transaction }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::BatchGetDocumentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::BatchGetDocumentsRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(documents, request.documents)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:batch_get_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("batch_get_documents")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.batch_get_documents(formatted_database, documents)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes batch_get_documents with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      documents = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::BatchGetDocumentsRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(documents, request.documents)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:batch_get_documents, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("batch_get_documents")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_get_documents(formatted_database, documents)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'begin_transaction' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#begin_transaction."

    it 'invokes begin_transaction without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")

      # Create expected grpc response
      transaction = "-34"
      expected_response = { transaction: transaction }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::BeginTransactionResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::BeginTransactionRequest, request)
        assert_equal(formatted_database, request.database)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("begin_transaction")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.begin_transaction(formatted_database)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes begin_transaction with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::BeginTransactionRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:begin_transaction, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("begin_transaction")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.begin_transaction(formatted_database)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'commit' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#commit."

    it 'invokes commit without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      writes = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::CommitResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::CommitRequest, request)
        assert_equal(formatted_database, request.database)
        writes = writes.map do |req|
          Google::Gax::to_proto(req, Google::Firestore::V1beta1::Write)
        end
        assert_equal(writes, request.writes)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("commit")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.commit(formatted_database, writes)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes commit with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      writes = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::CommitRequest, request)
        assert_equal(formatted_database, request.database)
        writes = writes.map do |req|
          Google::Gax::to_proto(req, Google::Firestore::V1beta1::Write)
        end
        assert_equal(writes, request.writes)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:commit, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("commit")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.commit(formatted_database, writes)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'rollback' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#rollback."

    it 'invokes rollback without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      transaction = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::RollbackRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(transaction, request.transaction)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("rollback")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.rollback(formatted_database, transaction)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes rollback with error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      transaction = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::RollbackRequest, request)
        assert_equal(formatted_database, request.database)
        assert_equal(transaction, request.transaction)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:rollback, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("rollback")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.rollback(formatted_database, transaction)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_query' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#run_query."

    it 'invokes run_query without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Create expected grpc response
      transaction = "-34"
      skipped_results = 880286183
      expected_response = { transaction: transaction, skipped_results: skipped_results }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::RunQueryResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::RunQueryRequest, request)
        assert_equal(formatted_parent, request.parent)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:run_query, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("run_query")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.run_query(formatted_parent)

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes run_query with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::RunQueryRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:run_query, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("run_query")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.run_query(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'write' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#write."

    it 'invokes write without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      request = { database: formatted_database }

      # Create expected grpc response
      stream_id = "streamId-315624902"
      stream_token = "122"
      expected_response = { stream_id: stream_id, stream_token: stream_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::WriteResponse)

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1beta1::WriteRequest, request)
        assert_equal(formatted_database, request.database)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:write, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("write")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

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
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      request = { database: formatted_database }

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1beta1::WriteRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:write, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("write")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.write([request])
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'listen' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#listen."

    it 'invokes listen without error' do
      # Create request parameters
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      request = { database: formatted_database }

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::ListenResponse)

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1beta1::ListenRequest, request)
        assert_equal(formatted_database, request.database)
        [expected_response]
      end
      mock_stub = MockGrpcClientStub.new(:listen, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("listen")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

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
      formatted_database = Google::Cloud::Firestore::V1beta1::FirestoreClient.database_root_path("[PROJECT]", "[DATABASE]")
      request = { database: formatted_database }

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Firestore::V1beta1::ListenRequest, request)
        assert_equal(formatted_database, request.database)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:listen, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("listen")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.listen([request])
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_collection_ids' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Firestore::V1beta1::FirestoreClient#list_collection_ids."

    it 'invokes list_collection_ids without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Create expected grpc response
      next_page_token = ""
      collection_ids_element = "collectionIdsElement1368994900"
      collection_ids = [collection_ids_element]
      expected_response = { next_page_token: next_page_token, collection_ids: collection_ids }
      expected_response = Google::Gax::to_proto(expected_response, Google::Firestore::V1beta1::ListCollectionIdsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::ListCollectionIdsRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_collection_ids, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("list_collection_ids")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          response = client.list_collection_ids(formatted_parent)

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
      formatted_parent = Google::Cloud::Firestore::V1beta1::FirestoreClient.any_path_path("[PROJECT]", "[DATABASE]", "[DOCUMENT]", "[ANY_PATH]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Firestore::V1beta1::ListCollectionIdsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_collection_ids, mock_method)

      # Mock auth layer
      mock_credentials = MockCredentialsClass.new("list_collection_ids")

      Google::Firestore::V1beta1::Firestore::Stub.stub(:new, mock_stub) do
        Google::Cloud::Firestore::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Firestore::V1beta1.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_collection_ids(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
