# frozen_string_literal: true

# Copyright 2022 Google LLC
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

require "google/cloud/aiplatform/v1/specialist_pool_service_pb"
require "google/cloud/aiplatform/v1/specialist_pool_service_services_pb"
require "google/cloud/ai_platform/v1/specialist_pool_service"

class ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::ClientTest < Minitest::Test
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

  def test_create_specialist_pool
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    specialist_pool = {}

    create_specialist_pool_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :create_specialist_pool, name
      assert_kind_of ::Google::Cloud::AIPlatform::V1::CreateSpecialistPoolRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::AIPlatform::V1::SpecialistPool), request["specialist_pool"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, create_specialist_pool_client_stub do
      # Create client
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.create_specialist_pool({ parent: parent, specialist_pool: specialist_pool }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.create_specialist_pool parent: parent, specialist_pool: specialist_pool do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.create_specialist_pool ::Google::Cloud::AIPlatform::V1::CreateSpecialistPoolRequest.new(parent: parent, specialist_pool: specialist_pool) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.create_specialist_pool({ parent: parent, specialist_pool: specialist_pool }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.create_specialist_pool(::Google::Cloud::AIPlatform::V1::CreateSpecialistPoolRequest.new(parent: parent, specialist_pool: specialist_pool), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, create_specialist_pool_client_stub.call_rpc_count
    end
  end

  def test_get_specialist_pool
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::AIPlatform::V1::SpecialistPool.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_specialist_pool_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :get_specialist_pool, name
      assert_kind_of ::Google::Cloud::AIPlatform::V1::GetSpecialistPoolRequest, request
      assert_equal "hello world", request["name"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, get_specialist_pool_client_stub do
      # Create client
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.get_specialist_pool({ name: name }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.get_specialist_pool name: name do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.get_specialist_pool ::Google::Cloud::AIPlatform::V1::GetSpecialistPoolRequest.new(name: name) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.get_specialist_pool({ name: name }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.get_specialist_pool(::Google::Cloud::AIPlatform::V1::GetSpecialistPoolRequest.new(name: name), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, get_specialist_pool_client_stub.call_rpc_count
    end
  end

  def test_list_specialist_pools
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::AIPlatform::V1::ListSpecialistPoolsResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"
    read_mask = {}

    list_specialist_pools_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :list_specialist_pools, name
      assert_kind_of ::Google::Cloud::AIPlatform::V1::ListSpecialistPoolsRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal 42, request["page_size"]
      assert_equal "hello world", request["page_token"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Protobuf::FieldMask), request["read_mask"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, list_specialist_pools_client_stub do
      # Create client
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.list_specialist_pools({ parent: parent, page_size: page_size, page_token: page_token, read_mask: read_mask }) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.list_specialist_pools parent: parent, page_size: page_size, page_token: page_token, read_mask: read_mask do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.list_specialist_pools ::Google::Cloud::AIPlatform::V1::ListSpecialistPoolsRequest.new(parent: parent, page_size: page_size, page_token: page_token, read_mask: read_mask) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.list_specialist_pools({ parent: parent, page_size: page_size, page_token: page_token, read_mask: read_mask }, grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.list_specialist_pools(::Google::Cloud::AIPlatform::V1::ListSpecialistPoolsRequest.new(parent: parent, page_size: page_size, page_token: page_token, read_mask: read_mask), grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, list_specialist_pools_client_stub.call_rpc_count
    end
  end

  def test_delete_specialist_pool
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    force = true

    delete_specialist_pool_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :delete_specialist_pool, name
      assert_kind_of ::Google::Cloud::AIPlatform::V1::DeleteSpecialistPoolRequest, request
      assert_equal "hello world", request["name"]
      assert_equal true, request["force"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, delete_specialist_pool_client_stub do
      # Create client
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.delete_specialist_pool({ name: name, force: force }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.delete_specialist_pool name: name, force: force do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.delete_specialist_pool ::Google::Cloud::AIPlatform::V1::DeleteSpecialistPoolRequest.new(name: name, force: force) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.delete_specialist_pool({ name: name, force: force }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.delete_specialist_pool(::Google::Cloud::AIPlatform::V1::DeleteSpecialistPoolRequest.new(name: name, force: force), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, delete_specialist_pool_client_stub.call_rpc_count
    end
  end

  def test_update_specialist_pool
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    specialist_pool = {}
    update_mask = {}

    update_specialist_pool_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :update_specialist_pool, name
      assert_kind_of ::Google::Cloud::AIPlatform::V1::UpdateSpecialistPoolRequest, request
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::AIPlatform::V1::SpecialistPool), request["specialist_pool"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Protobuf::FieldMask), request["update_mask"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, update_specialist_pool_client_stub do
      # Create client
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.update_specialist_pool({ specialist_pool: specialist_pool, update_mask: update_mask }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.update_specialist_pool specialist_pool: specialist_pool, update_mask: update_mask do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.update_specialist_pool ::Google::Cloud::AIPlatform::V1::UpdateSpecialistPoolRequest.new(specialist_pool: specialist_pool, update_mask: update_mask) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.update_specialist_pool({ specialist_pool: specialist_pool, update_mask: update_mask }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.update_specialist_pool(::Google::Cloud::AIPlatform::V1::UpdateSpecialistPoolRequest.new(specialist_pool: specialist_pool, update_mask: update_mask), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, update_specialist_pool_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client::Configuration, config
  end

  def test_operations_client
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    assert_kind_of ::Google::Cloud::AIPlatform::V1::SpecialistPoolService::Operations, client.operations_client
  end
end
