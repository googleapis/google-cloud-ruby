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
require "google/cloud/debugger/v2/controller2_client"
require "google/devtools/clouddebugger/v2/controller_services_pb"

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

class MockController2Credentials < Google::Cloud::Debugger::V2::Credentials
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

describe Google::Cloud::Debugger::V2::Controller2Client do

  describe 'register_debuggee' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Controller2Client#register_debuggee."

    it 'invokes register_debuggee without error' do
      # Create request parameters
      debuggee = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::RegisterDebuggeeResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::RegisterDebuggeeRequest, request)
        assert_equal(Google::Gax::to_proto(debuggee, Google::Devtools::Clouddebugger::V2::Debuggee), request.debuggee)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:register_debuggee, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("register_debuggee")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          response = client.register_debuggee(debuggee)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.register_debuggee(debuggee) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes register_debuggee with error' do
      # Create request parameters
      debuggee = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::RegisterDebuggeeRequest, request)
        assert_equal(Google::Gax::to_proto(debuggee, Google::Devtools::Clouddebugger::V2::Debuggee), request.debuggee)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:register_debuggee, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("register_debuggee")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.register_debuggee(debuggee)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_active_breakpoints' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Controller2Client#list_active_breakpoints."

    it 'invokes list_active_breakpoints without error' do
      # Create request parameters
      debuggee_id = ''

      # Create expected grpc response
      next_wait_token = "nextWaitToken1006864251"
      wait_expired = false
      expected_response = { next_wait_token: next_wait_token, wait_expired: wait_expired }
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::ListActiveBreakpointsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListActiveBreakpointsRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_active_breakpoints, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("list_active_breakpoints")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          response = client.list_active_breakpoints(debuggee_id)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_active_breakpoints(debuggee_id) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_active_breakpoints with error' do
      # Create request parameters
      debuggee_id = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::ListActiveBreakpointsRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_active_breakpoints, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("list_active_breakpoints")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_active_breakpoints(debuggee_id)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_active_breakpoint' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Debugger::V2::Controller2Client#update_active_breakpoint."

    it 'invokes update_active_breakpoint without error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Devtools::Clouddebugger::V2::UpdateActiveBreakpointResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::UpdateActiveBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(Google::Gax::to_proto(breakpoint, Google::Devtools::Clouddebugger::V2::Breakpoint), request.breakpoint)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_active_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("update_active_breakpoint")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          response = client.update_active_breakpoint(debuggee_id, breakpoint)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_active_breakpoint(debuggee_id, breakpoint) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_active_breakpoint with error' do
      # Create request parameters
      debuggee_id = ''
      breakpoint = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Devtools::Clouddebugger::V2::UpdateActiveBreakpointRequest, request)
        assert_equal(debuggee_id, request.debuggee_id)
        assert_equal(Google::Gax::to_proto(breakpoint, Google::Devtools::Clouddebugger::V2::Breakpoint), request.breakpoint)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_active_breakpoint, mock_method)

      # Mock auth layer
      mock_credentials = MockController2Credentials.new("update_active_breakpoint")

      Google::Devtools::Clouddebugger::V2::Controller2::Stub.stub(:new, mock_stub) do
        Google::Cloud::Debugger::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Debugger::V2::Controller2.new

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_active_breakpoint(debuggee_id, breakpoint)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end