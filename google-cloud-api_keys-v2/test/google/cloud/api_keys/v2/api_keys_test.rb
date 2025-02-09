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

require "google/api/apikeys/v2/apikeys_pb"
require "google/api/apikeys/v2/apikeys_services_pb"
require "google/cloud/api_keys/v2/api_keys"

class ::Google::Cloud::ApiKeys::V2::ApiKeys::ClientTest < Minitest::Test
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

  def test_create_key
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    key = {}
    key_id = "hello world"

    create_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :create_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::CreateKeyRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::ApiKeys::V2::Key), request["key"]
      assert_equal "hello world", request["key_id"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, create_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.create_key({ parent: parent, key: key, key_id: key_id }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.create_key parent: parent, key: key, key_id: key_id do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.create_key ::Google::Cloud::ApiKeys::V2::CreateKeyRequest.new(parent: parent, key: key, key_id: key_id) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.create_key({ parent: parent, key: key, key_id: key_id }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.create_key(::Google::Cloud::ApiKeys::V2::CreateKeyRequest.new(parent: parent, key: key, key_id: key_id), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, create_key_client_stub.call_rpc_count
    end
  end

  def test_list_keys
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::ApiKeys::V2::ListKeysResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"
    show_deleted = true

    list_keys_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :list_keys, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::ListKeysRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal 42, request["page_size"]
      assert_equal "hello world", request["page_token"]
      assert_equal true, request["show_deleted"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, list_keys_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.list_keys({ parent: parent, page_size: page_size, page_token: page_token, show_deleted: show_deleted }) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.list_keys parent: parent, page_size: page_size, page_token: page_token, show_deleted: show_deleted do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.list_keys ::Google::Cloud::ApiKeys::V2::ListKeysRequest.new(parent: parent, page_size: page_size, page_token: page_token, show_deleted: show_deleted) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.list_keys({ parent: parent, page_size: page_size, page_token: page_token, show_deleted: show_deleted }, grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.list_keys(::Google::Cloud::ApiKeys::V2::ListKeysRequest.new(parent: parent, page_size: page_size, page_token: page_token, show_deleted: show_deleted), grpc_options) do |response, operation|
        assert_kind_of Gapic::PagedEnumerable, response
        assert_equal grpc_response, response.response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, list_keys_client_stub.call_rpc_count
    end
  end

  def test_get_key
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::ApiKeys::V2::Key.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :get_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::GetKeyRequest, request
      assert_equal "hello world", request["name"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, get_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.get_key({ name: name }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.get_key name: name do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.get_key ::Google::Cloud::ApiKeys::V2::GetKeyRequest.new(name: name) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.get_key({ name: name }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.get_key(::Google::Cloud::ApiKeys::V2::GetKeyRequest.new(name: name), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, get_key_client_stub.call_rpc_count
    end
  end

  def test_get_key_string
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::ApiKeys::V2::GetKeyStringResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    get_key_string_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :get_key_string, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::GetKeyStringRequest, request
      assert_equal "hello world", request["name"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, get_key_string_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.get_key_string({ name: name }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.get_key_string name: name do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.get_key_string ::Google::Cloud::ApiKeys::V2::GetKeyStringRequest.new(name: name) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.get_key_string({ name: name }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.get_key_string(::Google::Cloud::ApiKeys::V2::GetKeyStringRequest.new(name: name), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, get_key_string_client_stub.call_rpc_count
    end
  end

  def test_update_key
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    key = {}
    update_mask = {}

    update_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :update_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::UpdateKeyRequest, request
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::ApiKeys::V2::Key), request["key"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Protobuf::FieldMask), request["update_mask"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, update_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.update_key({ key: key, update_mask: update_mask }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.update_key key: key, update_mask: update_mask do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.update_key ::Google::Cloud::ApiKeys::V2::UpdateKeyRequest.new(key: key, update_mask: update_mask) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.update_key({ key: key, update_mask: update_mask }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.update_key(::Google::Cloud::ApiKeys::V2::UpdateKeyRequest.new(key: key, update_mask: update_mask), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, update_key_client_stub.call_rpc_count
    end
  end

  def test_delete_key
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    etag = "hello world"

    delete_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :delete_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::DeleteKeyRequest, request
      assert_equal "hello world", request["name"]
      assert_equal "hello world", request["etag"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, delete_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.delete_key({ name: name, etag: etag }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.delete_key name: name, etag: etag do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.delete_key ::Google::Cloud::ApiKeys::V2::DeleteKeyRequest.new(name: name, etag: etag) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.delete_key({ name: name, etag: etag }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.delete_key(::Google::Cloud::ApiKeys::V2::DeleteKeyRequest.new(name: name, etag: etag), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, delete_key_client_stub.call_rpc_count
    end
  end

  def test_undelete_key
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    undelete_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :undelete_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::UndeleteKeyRequest, request
      assert_equal "hello world", request["name"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, undelete_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.undelete_key({ name: name }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.undelete_key name: name do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.undelete_key ::Google::Cloud::ApiKeys::V2::UndeleteKeyRequest.new(name: name) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.undelete_key({ name: name }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.undelete_key(::Google::Cloud::ApiKeys::V2::UndeleteKeyRequest.new(name: name), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, undelete_key_client_stub.call_rpc_count
    end
  end

  def test_lookup_key
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::ApiKeys::V2::LookupKeyResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    key_string = "hello world"

    lookup_key_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :lookup_key, name
      assert_kind_of ::Google::Cloud::ApiKeys::V2::LookupKeyRequest, request
      assert_equal "hello world", request["key_string"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, lookup_key_client_stub do
      # Create client
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.lookup_key({ key_string: key_string }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.lookup_key key_string: key_string do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.lookup_key ::Google::Cloud::ApiKeys::V2::LookupKeyRequest.new(key_string: key_string) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.lookup_key({ key_string: key_string }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.lookup_key(::Google::Cloud::ApiKeys::V2::LookupKeyRequest.new(key_string: key_string), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, lookup_key_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::ApiKeys::V2::ApiKeys::Client::Configuration, config
  end

  def test_operations_client
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::ApiKeys::V2::ApiKeys::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    assert_kind_of ::Google::Cloud::ApiKeys::V2::ApiKeys::Operations, client.operations_client
  end
end
