# frozen_string_literal: true

# Copyright 2021 Google LLC
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

require "gapic/grpc/service_stub"

require "google/cloud/ids/v1/ids_pb"
require "google/cloud/ids/v1/ids_services_pb"
require "google/cloud/ids/v1/ids"

class ::Google::Cloud::IDS::V1::IDS::ClientTest < Minitest::Test
  class ClientStub
    attr_accessor :call_rpc_count, :requests

    def initialize response, operation, &block
      @response = response
      @operation = operation
      @block = block
      @call_rpc_count = 0
      @requests = []
    end

    def call_rpc *args, **kwargs
      @call_rpc_count += 1

      @requests << @block&.call(*args, **kwargs)

      catch :response do
        yield @response, @operation if block_given?
        @response
      end
    end

    def endpoint
      "endpoint.example.com"
    end

    def universe_domain
      "example.com"
    end

    def stub_logger
      nil
    end

    def logger
      nil
    end
  end

  def test_list_endpoints
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::IDS::V1::ListEndpointsResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"
    filter = "hello world"
    order_by = "hello world"

    list_endpoints_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :list_endpoints, name
      assert_kind_of ::Google::Cloud::IDS::V1::ListEndpointsRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal 42, request["page_size"]
      assert_equal "hello world", request["page_token"]
      assert_equal "hello world", request["filter"]
      assert_equal "hello world", request["order_by"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, list_endpoints_client_stub do
      # Create client
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.list_endpoints({ parent: parent, page_size: page_size, page_token: page_token, filter: filter, order_by: order_by }) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.list_endpoints parent: parent, page_size: page_size, page_token: page_token, filter: filter, order_by: order_by do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.list_endpoints ::Google::Cloud::IDS::V1::ListEndpointsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter, order_by: order_by) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.list_endpoints({ parent: parent, page_size: page_size, page_token: page_token, filter: filter, order_by: order_by }, grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.list_endpoints(::Google::Cloud::IDS::V1::ListEndpointsRequest.new(parent: parent, page_size: page_size, page_token: page_token, filter: filter, order_by: order_by), grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, list_endpoints_client_stub.call_rpc_count
    end
  end

  def test_get_endpoint
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::IDS::V1::Endpoint.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_endpoint_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :get_endpoint, name
      assert_kind_of ::Google::Cloud::IDS::V1::GetEndpointRequest, request
      assert_equal "hello world", request["name"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, get_endpoint_client_stub do
      # Create client
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.get_endpoint({ name: name }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.get_endpoint name: name do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.get_endpoint ::Google::Cloud::IDS::V1::GetEndpointRequest.new(name: name) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.get_endpoint({ name: name }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.get_endpoint(::Google::Cloud::IDS::V1::GetEndpointRequest.new(name: name), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, get_endpoint_client_stub.call_rpc_count
    end
  end

  def test_create_endpoint
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    endpoint_id = "hello world"
    endpoint = {}
    request_id = "hello world"

    create_endpoint_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :create_endpoint, name
      assert_kind_of ::Google::Cloud::IDS::V1::CreateEndpointRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal "hello world", request["endpoint_id"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::IDS::V1::Endpoint), request["endpoint"]
      assert_equal "hello world", request["request_id"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, create_endpoint_client_stub do
      # Create client
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.create_endpoint({ parent: parent, endpoint_id: endpoint_id, endpoint: endpoint, request_id: request_id }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.create_endpoint parent: parent, endpoint_id: endpoint_id, endpoint: endpoint, request_id: request_id do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.create_endpoint ::Google::Cloud::IDS::V1::CreateEndpointRequest.new(parent: parent, endpoint_id: endpoint_id, endpoint: endpoint, request_id: request_id) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.create_endpoint({ parent: parent, endpoint_id: endpoint_id, endpoint: endpoint, request_id: request_id }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.create_endpoint(::Google::Cloud::IDS::V1::CreateEndpointRequest.new(parent: parent, endpoint_id: endpoint_id, endpoint: endpoint, request_id: request_id), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, create_endpoint_client_stub.call_rpc_count
    end
  end

  def test_delete_endpoint
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    request_id = "hello world"

    delete_endpoint_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :delete_endpoint, name
      assert_kind_of ::Google::Cloud::IDS::V1::DeleteEndpointRequest, request
      assert_equal "hello world", request["name"]
      assert_equal "hello world", request["request_id"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, delete_endpoint_client_stub do
      # Create client
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.delete_endpoint({ name: name, request_id: request_id }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.delete_endpoint name: name, request_id: request_id do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.delete_endpoint ::Google::Cloud::IDS::V1::DeleteEndpointRequest.new(name: name, request_id: request_id) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.delete_endpoint({ name: name, request_id: request_id }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.delete_endpoint(::Google::Cloud::IDS::V1::DeleteEndpointRequest.new(name: name, request_id: request_id), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, delete_endpoint_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::IDS::V1::IDS::Client::Configuration, config
  end

  def test_operations_client
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::IDS::V1::IDS::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    assert_kind_of ::Google::Cloud::IDS::V1::IDS::Operations, client.operations_client
  end
end
