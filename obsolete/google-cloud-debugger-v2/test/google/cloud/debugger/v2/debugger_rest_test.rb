# frozen_string_literal: true

# Copyright 2023 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "helper"
require "gapic/rest"
require "google/devtools/clouddebugger/v2/debugger_pb"
require "google/cloud/debugger/v2/debugger/rest"


class ::Google::Cloud::Debugger::V2::Debugger::Rest::ClientTest < Minitest::Test
  class ClientStub
    attr_accessor :call_count, :requests

    def initialize response, &block
      @response = response
      @block = block
      @call_count = 0
      @requests = []
    end

    def make_get_request uri:, params: {}, options: {}
      make_http_request :get, uri: uri, body: nil, params: params, options: options
    end

    def make_delete_request uri:, params: {}, options: {}
      make_http_request :delete, uri: uri, body: nil, params: params, options: options
    end

    def make_post_request uri:, body: nil, params: {}, options: {}
      make_http_request :post, uri: uri, body: body, params: params, options: options
    end

    def make_patch_request uri:, body:, params: {}, options: {}
      make_http_request :patch, uri: uri, body: body, params: params, options: options
    end

    def make_put_request uri:, body:, params: {}, options: {}
      make_http_request :put, uri: uri, body: body, params: params, options: options
    end

    def make_http_request *args, **kwargs
      @call_count += 1

      @requests << @block&.call(*args, **kwargs)

      @response
    end
  end

  def test_set_breakpoint
    # Create test objects.
    client_result = ::Google::Cloud::Debugger::V2::SetBreakpointResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    debuggee_id = "hello world"
    breakpoint = {}
    client_version = "hello world"

    set_breakpoint_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Debugger::V2::Debugger::Rest::ServiceStub.stub :transcode_set_breakpoint_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, set_breakpoint_client_stub do
        # Create client
        client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.set_breakpoint({ debuggee_id: debuggee_id, breakpoint: breakpoint, client_version: client_version }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.set_breakpoint debuggee_id: debuggee_id, breakpoint: breakpoint, client_version: client_version do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.set_breakpoint ::Google::Cloud::Debugger::V2::SetBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint: breakpoint, client_version: client_version) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.set_breakpoint({ debuggee_id: debuggee_id, breakpoint: breakpoint, client_version: client_version }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.set_breakpoint(::Google::Cloud::Debugger::V2::SetBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint: breakpoint, client_version: client_version), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, set_breakpoint_client_stub.call_count
      end
    end
  end

  def test_get_breakpoint
    # Create test objects.
    client_result = ::Google::Cloud::Debugger::V2::GetBreakpointResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    debuggee_id = "hello world"
    breakpoint_id = "hello world"
    client_version = "hello world"

    get_breakpoint_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Debugger::V2::Debugger::Rest::ServiceStub.stub :transcode_get_breakpoint_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_breakpoint_client_stub do
        # Create client
        client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_breakpoint({ debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_breakpoint debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_breakpoint ::Google::Cloud::Debugger::V2::GetBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_breakpoint({ debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_breakpoint(::Google::Cloud::Debugger::V2::GetBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_breakpoint_client_stub.call_count
      end
    end
  end

  def test_delete_breakpoint
    # Create test objects.
    client_result = ::Google::Protobuf::Empty.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    debuggee_id = "hello world"
    breakpoint_id = "hello world"
    client_version = "hello world"

    delete_breakpoint_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Debugger::V2::Debugger::Rest::ServiceStub.stub :transcode_delete_breakpoint_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, delete_breakpoint_client_stub do
        # Create client
        client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.delete_breakpoint({ debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.delete_breakpoint debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.delete_breakpoint ::Google::Cloud::Debugger::V2::DeleteBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.delete_breakpoint({ debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.delete_breakpoint(::Google::Cloud::Debugger::V2::DeleteBreakpointRequest.new(debuggee_id: debuggee_id, breakpoint_id: breakpoint_id, client_version: client_version), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, delete_breakpoint_client_stub.call_count
      end
    end
  end

  def test_list_breakpoints
    # Create test objects.
    client_result = ::Google::Cloud::Debugger::V2::ListBreakpointsResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    debuggee_id = "hello world"
    include_all_users = true
    include_inactive = true
    action = {}
    strip_results = true
    wait_token = "hello world"
    client_version = "hello world"

    list_breakpoints_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Debugger::V2::Debugger::Rest::ServiceStub.stub :transcode_list_breakpoints_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_breakpoints_client_stub do
        # Create client
        client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_breakpoints({ debuggee_id: debuggee_id, include_all_users: include_all_users, include_inactive: include_inactive, action: action, strip_results: strip_results, wait_token: wait_token, client_version: client_version }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_breakpoints debuggee_id: debuggee_id, include_all_users: include_all_users, include_inactive: include_inactive, action: action, strip_results: strip_results, wait_token: wait_token, client_version: client_version do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_breakpoints ::Google::Cloud::Debugger::V2::ListBreakpointsRequest.new(debuggee_id: debuggee_id, include_all_users: include_all_users, include_inactive: include_inactive, action: action, strip_results: strip_results, wait_token: wait_token, client_version: client_version) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_breakpoints({ debuggee_id: debuggee_id, include_all_users: include_all_users, include_inactive: include_inactive, action: action, strip_results: strip_results, wait_token: wait_token, client_version: client_version }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_breakpoints(::Google::Cloud::Debugger::V2::ListBreakpointsRequest.new(debuggee_id: debuggee_id, include_all_users: include_all_users, include_inactive: include_inactive, action: action, strip_results: strip_results, wait_token: wait_token, client_version: client_version), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_breakpoints_client_stub.call_count
      end
    end
  end

  def test_list_debuggees
    # Create test objects.
    client_result = ::Google::Cloud::Debugger::V2::ListDebuggeesResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project = "hello world"
    include_inactive = true
    client_version = "hello world"

    list_debuggees_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Debugger::V2::Debugger::Rest::ServiceStub.stub :transcode_list_debuggees_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_debuggees_client_stub do
        # Create client
        client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_debuggees({ project: project, include_inactive: include_inactive, client_version: client_version }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_debuggees project: project, include_inactive: include_inactive, client_version: client_version do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_debuggees ::Google::Cloud::Debugger::V2::ListDebuggeesRequest.new(project: project, include_inactive: include_inactive, client_version: client_version) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_debuggees({ project: project, include_inactive: include_inactive, client_version: client_version }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_debuggees(::Google::Cloud::Debugger::V2::ListDebuggeesRequest.new(project: project, include_inactive: include_inactive, client_version: client_version), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_debuggees_client_stub.call_count
      end
    end
  end

  def test_configure
    credentials_token = :dummy_value

    client = block_config = config = nil
    Gapic::Rest::ClientStub.stub :new, nil do
      client = ::Google::Cloud::Debugger::V2::Debugger::Rest::Client.new do |config|
        config.credentials = credentials_token
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::Debugger::V2::Debugger::Rest::Client::Configuration, config
  end
end
