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
require "google/cloud/dialogflow/v2/intents_client"
require "google/cloud/dialogflow/v2/intent_services_pb"
require "google/longrunning/operations_pb"

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

class MockIntentsCredentials < Google::Cloud::Dialogflow::Credentials
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

describe Google::Cloud::Dialogflow::V2::IntentsClient do

  describe 'list_intents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#list_intents."

    it 'invokes list_intents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      intents_element = {}
      intents = [intents_element]
      expected_response = { next_page_token: next_page_token, intents: intents }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::ListIntentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("list_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.list_intents(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.intents.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_intents with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ListIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("list_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_intents(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#get_intent."

    it 'invokes get_intent without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::IntentsClient.intent_path("[PROJECT]", "[INTENT]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      priority = 1165461084
      is_fallback = false
      ml_disabled = true
      action = "action-1422950858"
      reset_contexts = true
      root_followup_intent_name = "rootFollowupIntentName402253784"
      parent_followup_intent_name = "parentFollowupIntentName-1131901680"
      expected_response = {
        name: name_2,
        display_name: display_name,
        priority: priority,
        is_fallback: is_fallback,
        ml_disabled: ml_disabled,
        action: action,
        reset_contexts: reset_contexts,
        root_followup_intent_name: root_followup_intent_name,
        parent_followup_intent_name: parent_followup_intent_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Intent)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetIntentRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("get_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.get_intent(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_intent with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::IntentsClient.intent_path("[PROJECT]", "[INTENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetIntentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("get_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_intent(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#create_intent."

    it 'invokes create_intent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      intent = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      priority = 1165461084
      is_fallback = false
      ml_disabled = true
      action = "action-1422950858"
      reset_contexts = true
      root_followup_intent_name = "rootFollowupIntentName402253784"
      parent_followup_intent_name = "parentFollowupIntentName-1131901680"
      expected_response = {
        name: name,
        display_name: display_name,
        priority: priority,
        is_fallback: is_fallback,
        ml_disabled: ml_disabled,
        action: action,
        reset_contexts: reset_contexts,
        root_followup_intent_name: root_followup_intent_name,
        parent_followup_intent_name: parent_followup_intent_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Intent)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateIntentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(intent, Google::Cloud::Dialogflow::V2::Intent), request.intent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("create_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.create_intent(formatted_parent, intent)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_intent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      intent = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::CreateIntentRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(intent, Google::Cloud::Dialogflow::V2::Intent), request.intent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("create_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_intent(formatted_parent, intent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#update_intent."

    it 'invokes update_intent without error' do
      # Create request parameters
      intent = {}
      language_code = ''

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      priority = 1165461084
      is_fallback = false
      ml_disabled = true
      action = "action-1422950858"
      reset_contexts = true
      root_followup_intent_name = "rootFollowupIntentName402253784"
      parent_followup_intent_name = "parentFollowupIntentName-1131901680"
      expected_response = {
        name: name,
        display_name: display_name,
        priority: priority,
        is_fallback: is_fallback,
        ml_disabled: ml_disabled,
        action: action,
        reset_contexts: reset_contexts,
        root_followup_intent_name: root_followup_intent_name,
        parent_followup_intent_name: parent_followup_intent_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Intent)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateIntentRequest, request)
        assert_equal(Google::Gax::to_proto(intent, Google::Cloud::Dialogflow::V2::Intent), request.intent)
        assert_equal(language_code, request.language_code)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("update_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.update_intent(intent, language_code)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_intent with error' do
      # Create request parameters
      intent = {}
      language_code = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::UpdateIntentRequest, request)
        assert_equal(Google::Gax::to_proto(intent, Google::Cloud::Dialogflow::V2::Intent), request.intent)
        assert_equal(language_code, request.language_code)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("update_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_intent(intent, language_code)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#delete_intent."

    it 'invokes delete_intent without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::IntentsClient.intent_path("[PROJECT]", "[INTENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteIntentRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("delete_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.delete_intent(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_intent with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dialogflow::V2::IntentsClient.intent_path("[PROJECT]", "[INTENT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DeleteIntentRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("delete_intent")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_intent(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_update_intents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#batch_update_intents."

    it 'invokes batch_update_intents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      language_code = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::BatchUpdateIntentsResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_intents_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(language_code, request.language_code)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:batch_update_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_update_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.batch_update_intents(formatted_parent, language_code)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_update_intents and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      language_code = ''

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::IntentsClient#batch_update_intents.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_update_intents_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(language_code, request.language_code)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:batch_update_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_update_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.batch_update_intents(formatted_parent, language_code)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_update_intents with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      language_code = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchUpdateIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(language_code, request.language_code)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:batch_update_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_update_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_update_intents(formatted_parent, language_code)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_delete_intents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::IntentsClient#batch_delete_intents."

    it 'invokes batch_delete_intents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      intents = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_intents_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        intents = intents.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::Intent)
        end
        assert_equal(intents, request.intents)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:batch_delete_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_delete_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.batch_delete_intents(formatted_parent, intents)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_delete_intents and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      intents = []

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::IntentsClient#batch_delete_intents.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_delete_intents_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        intents = intents.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::Intent)
        end
        assert_equal(intents, request.intents)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:batch_delete_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_delete_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          response = client.batch_delete_intents(formatted_parent, intents)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_delete_intents with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::IntentsClient.project_agent_path("[PROJECT]")
      intents = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::BatchDeleteIntentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        intents = intents.map do |req|
          Google::Gax::to_proto(req, Google::Cloud::Dialogflow::V2::Intent)
        end
        assert_equal(intents, request.intents)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:batch_delete_intents, mock_method)

      # Mock auth layer
      mock_credentials = MockIntentsCredentials.new("batch_delete_intents")

      Google::Cloud::Dialogflow::V2::Intents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Intents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.batch_delete_intents(formatted_parent, intents)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end