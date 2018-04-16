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
require "google/cloud/dialogflow/v2/agents_client"
require "google/cloud/dialogflow/v2/agent_services_pb"
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

class MockAgentsCredentials < Google::Cloud::Dialogflow::Credentials
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

describe Google::Cloud::Dialogflow::V2::AgentsClient do

  describe 'get_agent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#get_agent."

    it 'invokes get_agent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      parent_2 = "parent21175163357"
      display_name = "displayName1615086568"
      default_language_code = "defaultLanguageCode856575222"
      time_zone = "timeZone36848094"
      description = "description-1724546052"
      avatar_uri = "avatarUri-402824826"
      enable_logging = false
      classification_threshold = 1.11581064E8
      expected_response = {
        parent: parent_2,
        display_name: display_name,
        default_language_code: default_language_code,
        time_zone: time_zone,
        description: description,
        avatar_uri: avatar_uri,
        enable_logging: enable_logging,
        classification_threshold: classification_threshold
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::Agent)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("get_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.get_agent(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_agent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::GetAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("get_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_agent(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'search_agents' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#search_agents."

    it 'invokes search_agents without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      agents_element = {}
      agents = [agents_element]
      expected_response = { next_page_token: next_page_token, agents: agents }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::SearchAgentsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::SearchAgentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:search_agents, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("search_agents")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.search_agents(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.agents.to_a, response.to_a)
        end
      end
    end

    it 'invokes search_agents with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::SearchAgentsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:search_agents, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("search_agents")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.search_agents(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'train_agent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#train_agent."

    it 'invokes train_agent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/train_agent_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::TrainAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:train_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("train_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.train_agent(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes train_agent and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::AgentsClient#train_agent.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/train_agent_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::TrainAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:train_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("train_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.train_agent(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes train_agent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::TrainAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:train_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("train_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.train_agent(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'export_agent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#export_agent."

    it 'invokes export_agent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      agent_uri = "agentUri-1700713166"
      expected_response = { agent_uri: agent_uri }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::ExportAgentResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_agent_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ExportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:export_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("export_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.export_agent(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes export_agent and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::AgentsClient#export_agent.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/export_agent_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ExportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:export_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("export_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.export_agent(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes export_agent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ExportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:export_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("export_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.export_agent(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'import_agent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#import_agent."

    it 'invokes import_agent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_agent_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ImportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:import_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("import_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.import_agent(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes import_agent and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::AgentsClient#import_agent.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/import_agent_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ImportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:import_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("import_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.import_agent(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes import_agent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::ImportAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:import_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("import_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.import_agent(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'restore_agent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::AgentsClient#restore_agent."

    it 'invokes restore_agent without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/restore_agent_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::RestoreAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:restore_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("restore_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.restore_agent(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes restore_agent and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dialogflow::V2::AgentsClient#restore_agent.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/restore_agent_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::RestoreAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:restore_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("restore_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          response = client.restore_agent(formatted_parent)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes restore_agent with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dialogflow::V2::AgentsClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::RestoreAgentRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:restore_agent, mock_method)

      # Mock auth layer
      mock_credentials = MockAgentsCredentials.new("restore_agent")

      Google::Cloud::Dialogflow::V2::Agents::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Agents.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.restore_agent(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end