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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/dialogflow"
require "google/cloud/dialogflow/v2/contexts_client"
require "google/cloud/dialogflow/v2/context_services_pb"

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

class MockContextsCredentials < Google::Cloud::Dialogflow::V2::Credentials
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

describe Google::Cloud::Dialogflow::V2::ContextsClient do

  describe 'list_contexts' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#list_contexts."

    it 'invokes list_contexts without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")

      # Create expected grpc response
      next_page_token = ""
      contexts_element = {}
      contexts = [contexts_element]
      expected_response = { next_page_token: next_page_token, contexts: contexts }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::ListContextsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListContextsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_contexts, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("list_contexts")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.list_contexts(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.contexts.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_contexts with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListContextsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_contexts, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("list_contexts")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_contexts(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_context' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#get_context."

    it 'invokes get_context without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      lifespan_count = 1178775510
      expected_response = { name: name_2, lifespan_count: lifespan_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Context)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetContextRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("get_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.get_context(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_context(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_context with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetContextRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("get_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_context(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_context' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#create_context."

    it 'invokes create_context without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")
      context = {}

      # Create expected grpc response
      name = "name3373707"
      lifespan_count = 1178775510
      expected_response = { name: name, lifespan_count: lifespan_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Context)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateContextRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(context, Google::Cloud::Dialogflow::V2::Context), request.context)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("create_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.create_context(formatted_parent, context)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_context(formatted_parent, context) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_context with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")
      context = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateContextRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(context, Google::Cloud::Dialogflow::V2::Context), request.context)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("create_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_context(formatted_parent, context)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_context' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#update_context."

    it 'invokes update_context without error' do
      # Create request parameters
      context = {}

      # Create expected grpc response
      name = "name3373707"
      lifespan_count = 1178775510
      expected_response = { name: name, lifespan_count: lifespan_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Context)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateContextRequest, request)
        assert_equal(Google::Gax::to_proto(context, Google::Cloud::Dialogflow::V2::Context), request.context)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("update_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.update_context(context)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_context(context) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_context with error' do
      # Create request parameters
      context = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateContextRequest, request)
        assert_equal(Google::Gax::to_proto(context, Google::Cloud::Dialogflow::V2::Context), request.context)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("update_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_context(context)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_context' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#delete_context."

    it 'invokes delete_context without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteContextRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("delete_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.delete_context(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_context(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_context with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::ContextsClient.context_path("[PROJECT]", "[SESSION]", "[CONTEXT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteContextRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_context, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("delete_context")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_context(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_all_contexts' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::ContextsClient#delete_all_contexts."

    it 'invokes delete_all_contexts without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteAllContextsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_all_contexts, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("delete_all_contexts")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          response = client.delete_all_contexts(formatted_parent)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_all_contexts(formatted_parent) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_all_contexts with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::ContextsClient.session_path("[PROJECT]", "[SESSION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteAllContextsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_all_contexts, mock_method)

      # Mock auth layer
      mock_credentials = MockContextsCredentials.new("delete_all_contexts")

      Google::Cloud::Dialogflow::V2::Contexts::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Contexts.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_all_contexts(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end