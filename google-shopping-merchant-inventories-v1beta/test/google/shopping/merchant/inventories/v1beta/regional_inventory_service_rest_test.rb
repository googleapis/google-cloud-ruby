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
require "google/shopping/merchant/inventories/v1beta/regionalinventory_pb"
require "google/shopping/merchant/inventories/v1beta/regional_inventory_service/rest"


class ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::ClientTest < Minitest::Test
  class ClientStub
    attr_accessor :call_count, :requests

    def initialize response, &block
      @response = response
      @block = block
      @call_count = 0
      @requests = []
    end

    def make_get_request uri:, params: {}, options: {}, method_name: nil
      make_http_request :get, uri: uri, body: nil, params: params, options: options, method_name: method_name
    end

    def make_delete_request uri:, params: {}, options: {}, method_name: nil
      make_http_request :delete, uri: uri, body: nil, params: params, options: options, method_name: method_name
    end

    def make_post_request uri:, body: nil, params: {}, options: {}, method_name: nil
      make_http_request :post, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_patch_request uri:, body:, params: {}, options: {}, method_name: nil
      make_http_request :patch, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_put_request uri:, body:, params: {}, options: {}, method_name: nil
      make_http_request :put, uri: uri, body: body, params: params, options: options, method_name: method_name
    end

    def make_http_request *args, **kwargs
      @call_count += 1

      @requests << @block&.call(*args, **kwargs)

      @response
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

  def test_list_regional_inventories
    # Create test objects.
    client_result = ::Google::Shopping::Merchant::Inventories::V1beta::ListRegionalInventoriesResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    page_size = 42
    page_token = "hello world"

    list_regional_inventories_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::ServiceStub.stub :transcode_list_regional_inventories_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_regional_inventories_client_stub do
        # Create client
        client = ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_regional_inventories({ parent: parent, page_size: page_size, page_token: page_token }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_regional_inventories parent: parent, page_size: page_size, page_token: page_token do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_regional_inventories ::Google::Shopping::Merchant::Inventories::V1beta::ListRegionalInventoriesRequest.new(parent: parent, page_size: page_size, page_token: page_token) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_regional_inventories({ parent: parent, page_size: page_size, page_token: page_token }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_regional_inventories(::Google::Shopping::Merchant::Inventories::V1beta::ListRegionalInventoriesRequest.new(parent: parent, page_size: page_size, page_token: page_token), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_regional_inventories_client_stub.call_count
      end
    end
  end

  def test_insert_regional_inventory
    # Create test objects.
    client_result = ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventory.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    regional_inventory = {}

    insert_regional_inventory_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::ServiceStub.stub :transcode_insert_regional_inventory_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, insert_regional_inventory_client_stub do
        # Create client
        client = ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.insert_regional_inventory({ parent: parent, regional_inventory: regional_inventory }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.insert_regional_inventory parent: parent, regional_inventory: regional_inventory do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.insert_regional_inventory ::Google::Shopping::Merchant::Inventories::V1beta::InsertRegionalInventoryRequest.new(parent: parent, regional_inventory: regional_inventory) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.insert_regional_inventory({ parent: parent, regional_inventory: regional_inventory }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.insert_regional_inventory(::Google::Shopping::Merchant::Inventories::V1beta::InsertRegionalInventoryRequest.new(parent: parent, regional_inventory: regional_inventory), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, insert_regional_inventory_client_stub.call_count
      end
    end
  end

  def test_delete_regional_inventory
    # Create test objects.
    client_result = ::Google::Protobuf::Empty.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    name = "hello world"

    delete_regional_inventory_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::ServiceStub.stub :transcode_delete_regional_inventory_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, delete_regional_inventory_client_stub do
        # Create client
        client = ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.delete_regional_inventory({ name: name }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.delete_regional_inventory name: name do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.delete_regional_inventory ::Google::Shopping::Merchant::Inventories::V1beta::DeleteRegionalInventoryRequest.new(name: name) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.delete_regional_inventory({ name: name }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.delete_regional_inventory(::Google::Shopping::Merchant::Inventories::V1beta::DeleteRegionalInventoryRequest.new(name: name), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, delete_regional_inventory_client_stub.call_count
      end
    end
  end

  def test_configure
    credentials_token = :dummy_value

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil
    Gapic::Rest::ClientStub.stub :new, dummy_stub do
      client = ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::Client.new do |config|
        config.credentials = credentials_token
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Shopping::Merchant::Inventories::V1beta::RegionalInventoryService::Rest::Client::Configuration, config
  end
end
