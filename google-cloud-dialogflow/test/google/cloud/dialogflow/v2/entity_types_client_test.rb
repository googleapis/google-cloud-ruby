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
require "google/cloud/dialogflow/v2/entity_types_client"
require "google/cloud/dialogflow/v2/entity_type_services_pb"
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

class MockEntityTypesCredentials_v2 < Google::Cloud::Dialogflow::V2::Credentials
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

describe Google::Cloud::Dialogflow::V2::EntityTypesClient do

  describe 'list_entity_types' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#list_entity_types."

    it 'invokes list_entity_types without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      entity_types_element = {}
      entity_types = [entity_types_element]
      expected_response = { next_page_token: next_page_token, entity_types: entity_types }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::ListEntityTypesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("list_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.list_entity_types(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.entity_types.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_entity_types with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:list_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("list_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_entity_types(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_entity_type' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#get_entity_type."

    it 'invokes get_entity_type without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::EntityType)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetEntityTypeRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("get_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.get_entity_type(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_entity_type(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_entity_type with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetEntityTypeRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:get_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("get_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_entity_type(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_entity_type' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#create_entity_type."

    it 'invokes create_entity_type without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")
      entity_type = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::EntityType)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateEntityTypeRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(entity_type, Google::Cloud::Dialogflow::V2::EntityType), request.entity_type)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("create_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.create_entity_type(formatted_parent, entity_type)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_entity_type(formatted_parent, entity_type) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_entity_type with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")
      entity_type = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateEntityTypeRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(entity_type, Google::Cloud::Dialogflow::V2::EntityType), request.entity_type)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:create_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("create_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_entity_type(formatted_parent, entity_type)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_entity_type' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#update_entity_type."

    it 'invokes update_entity_type without error' do
      # Create request parameters
      entity_type = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::EntityType)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateEntityTypeRequest, request)
        assert_equal(Google::Gax::to_proto(entity_type, Google::Cloud::Dialogflow::V2::EntityType), request.entity_type)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("update_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.update_entity_type(entity_type)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_entity_type(entity_type) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_entity_type with error' do
      # Create request parameters
      entity_type = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateEntityTypeRequest, request)
        assert_equal(Google::Gax::to_proto(entity_type, Google::Cloud::Dialogflow::V2::EntityType), request.entity_type)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:update_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("update_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_entity_type(entity_type)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_entity_type' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#delete_entity_type."

    it 'invokes delete_entity_type without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteEntityTypeRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("delete_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.delete_entity_type(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_entity_type(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_entity_type with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteEntityTypeRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:delete_entity_type, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("delete_entity_type")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_entity_type(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_update_entity_types' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_update_entity_types."

    it 'invokes batch_update_entity_types without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::BatchUpdateEntityTypesResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_entity_types_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_update_entity_types(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_update_entity_types and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_update_entity_types.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_entity_types_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_update_entity_types(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_update_entity_types with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_update_entity_types(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_delete_entity_types' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_delete_entity_types."

    it 'invokes batch_delete_entity_types without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")
      entity_type_names = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_entity_types_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_type_names, request.entity_type_names)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_delete_entity_types(formatted_parent, entity_type_names)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_delete_entity_types and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")
      entity_type_names = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_delete_entity_types.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_entity_types_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_type_names, request.entity_type_names)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_delete_entity_types(formatted_parent, entity_type_names)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_delete_entity_types with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.project_agent_path("[PROJECT]")
      entity_type_names = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntityTypesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_type_names, request.entity_type_names)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entity_types, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entity_types")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_delete_entity_types(formatted_parent, entity_type_names)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_create_entities' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_create_entities."

    it 'invokes batch_create_entities without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_create_entities_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchCreateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_create_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_create_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_create_entities(formatted_parent, entities)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_create_entities and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_create_entities.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_create_entities_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchCreateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_create_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_create_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_create_entities(formatted_parent, entities)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_create_entities with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchCreateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_create_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_create_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_create_entities(formatted_parent, entities)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_update_entities' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_update_entities."

    it 'invokes batch_update_entities without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_entities_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_update_entities(formatted_parent, entities)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_update_entities and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_update_entities.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_entities_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_update_entities(formatted_parent, entities)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_update_entities with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entities = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        entities = entities.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::EntityType::Entity)
        end
        assert_equal(entities, request.entities)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_update_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_update_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_update_entities(formatted_parent, entities)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_delete_entities' do
    custom_error = CustomTestError_v2.new "Custom test error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_delete_entities."

    it 'invokes batch_delete_entities without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entity_values = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_entities_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_values, request.entity_values)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_delete_entities(formatted_parent, entity_values)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_delete_entities and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entity_values = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::EntityTypesClient#batch_delete_entities.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_entities_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_values, request.entity_values)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          response = client.batch_delete_entities(formatted_parent, entity_values)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_delete_entities with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::EntityTypesClient.entity_type_path("[PROJECT]", "[ENTITY_TYPE]")
      entity_values = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteEntitiesRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(entity_values, request.entity_values)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v2.new(:batch_delete_entities, mock_method)

      # Mock auth layer
      mock_credentials = MockEntityTypesCredentials_v2.new("batch_delete_entities")

      Google::Cloud::Dialogflow::V2::EntityTypes::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::EntityTypes.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_delete_entities(formatted_parent, entity_values)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end