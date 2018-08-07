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

require "google/cloud/debugger/v2"
require "google/cloud/debugger/v2/debugger2_client"
require "google/devtools/clouddebugger/v2/debugger_services_pb"

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

class MockDebugger2Credentials < Google::Cloud::Debugger::V2::Credentials
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

describe Google::Cloud::Debugger::V2::Debugger2Client do

  describe 'set_breakpoint' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Debugger2Client#set_breakpoint."

    it 'invokes set_breakpoint without error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint = {}
      client_version = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::SetBreakpointResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::SetBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(Google::Gax::to_proto(breakpoint, Google::Devtools::Clouddebugger::V2::Breakpoint), request.breakpoint)
        assert_equal(client_version, request.client_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:set_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("set_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          response = client.set_breakpoint(
            debuggee_id,
            breakpoint,
            client_version
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_breakpoint(
            debuggee_id,
            breakpoint,
            client_version
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_breakpoint with error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint = {}
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::SetBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(Google::Gax::to_proto(breakpoint, Google::Devtools::Clouddebugger::V2::Breakpoint), request.breakpoint)
        assert_equal(client_version, request.client_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:set_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("set_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.set_breakpoint(
              debuggee_id,
              breakpoint,
              client_version
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_breakpoint' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Debugger2Client#get_breakpoint."

    it 'invokes get_breakpoint without error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint_id = ''
      client_version = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::GetBreakpointResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::GetBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(breakpoint_id, request.breakpoint_id)
        assert_equal(client_version, request.client_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("get_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          response = client.get_breakpoint(
            debuggee_id,
            breakpoint_id,
            client_version
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_breakpoint(
            debuggee_id,
            breakpoint_id,
            client_version
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_breakpoint with error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint_id = ''
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::GetBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(breakpoint_id, request.breakpoint_id)
        assert_equal(client_version, request.client_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("get_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_breakpoint(
              debuggee_id,
              breakpoint_id,
              client_version
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_breakpoint' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Debugger2Client#delete_breakpoint."

    it 'invokes delete_breakpoint without error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint_id = ''
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::DeleteBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(breakpoint_id, request.breakpoint_id)
        assert_equal(client_version, request.client_version)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("delete_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          response = client.delete_breakpoint(
            debuggee_id,
            breakpoint_id,
            client_version
          )

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_breakpoint(
            debuggee_id,
            breakpoint_id,
            client_version
          ) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_breakpoint with error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint_id = ''
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::DeleteBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(breakpoint_id, request.breakpoint_id)
        assert_equal(client_version, request.client_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("delete_breakpoint")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_breakpoint(
              debuggee_id,
              breakpoint_id,
              client_version
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_breakpoints' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Debugger2Client#list_breakpoints."

    it 'invokes list_breakpoints without error' do
      # Create request parameters
      debuggee_id = ''
      client_version = ''

      # Create expected grpc response
      next_wait_token = "nextWaitToken1006864251"
      expected_response = { next_wait_token: next_wait_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::ListBreakpointsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(client_version, request.client_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_breakpoints, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("list_breakpoints")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          response = client.list_breakpoints(debuggee_id, client_version)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_breakpoints(debuggee_id, client_version) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_breakpoints with error' do
      # Create request parameters
      debuggee_id = ''
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListBreakpointsRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(client_version, request.client_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_breakpoints, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("list_breakpoints")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_breakpoints(debuggee_id, client_version)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_debuggees' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Debugger2Client#list_debuggees."

    it 'invokes list_debuggees without error' do
      # Create request parameters
      project = ''
      client_version = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::ListDebuggeesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListDebuggeesRequest, request)
        assert_equal(project, request.project)
        assert_equal(client_version, request.client_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_debuggees, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("list_debuggees")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          response = client.list_debuggees(project, client_version)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_debuggees(project, client_version) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_debuggees with error' do
      # Create request parameters
      project = ''
      client_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListDebuggeesRequest, request)
        assert_equal(project, request.project)
        assert_equal(client_version, request.client_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_debuggees, mock_method)

      # Mock auth layer
      mock_credentials = MockDebugger2Credentials.new("list_debuggees")

      Google::Devtools::Clouddebugger::V2::Debugger2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Debugger2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_debuggees(project, client_version)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end