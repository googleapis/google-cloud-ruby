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
require "google/datastore/admin/v1/datastore_admin_pb"
require "google/cloud/datastore/admin/v1/datastore_admin/rest"


class ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ClientTest < Minitest::Test
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

  def test_export_entities
    # Create test objects.
    client_result = ::Google::Longrunning::Operation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    labels = {}
    entity_filter = {}
    output_url_prefix = "hello world"

    export_entities_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_export_entities_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, export_entities_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.export_entities({ project_id: project_id, labels: labels, entity_filter: entity_filter, output_url_prefix: output_url_prefix }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.export_entities project_id: project_id, labels: labels, entity_filter: entity_filter, output_url_prefix: output_url_prefix do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.export_entities ::Google::Cloud::Datastore::Admin::V1::ExportEntitiesRequest.new(project_id: project_id, labels: labels, entity_filter: entity_filter, output_url_prefix: output_url_prefix) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.export_entities({ project_id: project_id, labels: labels, entity_filter: entity_filter, output_url_prefix: output_url_prefix }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.export_entities(::Google::Cloud::Datastore::Admin::V1::ExportEntitiesRequest.new(project_id: project_id, labels: labels, entity_filter: entity_filter, output_url_prefix: output_url_prefix), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, export_entities_client_stub.call_count
      end
    end
  end

  def test_import_entities
    # Create test objects.
    client_result = ::Google::Longrunning::Operation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    labels = {}
    input_url = "hello world"
    entity_filter = {}

    import_entities_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_import_entities_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, import_entities_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.import_entities({ project_id: project_id, labels: labels, input_url: input_url, entity_filter: entity_filter }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.import_entities project_id: project_id, labels: labels, input_url: input_url, entity_filter: entity_filter do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.import_entities ::Google::Cloud::Datastore::Admin::V1::ImportEntitiesRequest.new(project_id: project_id, labels: labels, input_url: input_url, entity_filter: entity_filter) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.import_entities({ project_id: project_id, labels: labels, input_url: input_url, entity_filter: entity_filter }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.import_entities(::Google::Cloud::Datastore::Admin::V1::ImportEntitiesRequest.new(project_id: project_id, labels: labels, input_url: input_url, entity_filter: entity_filter), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, import_entities_client_stub.call_count
      end
    end
  end

  def test_create_index
    # Create test objects.
    client_result = ::Google::Longrunning::Operation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    index = {}

    create_index_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_create_index_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, create_index_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.create_index({ project_id: project_id, index: index }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.create_index project_id: project_id, index: index do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.create_index ::Google::Cloud::Datastore::Admin::V1::CreateIndexRequest.new(project_id: project_id, index: index) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.create_index({ project_id: project_id, index: index }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.create_index(::Google::Cloud::Datastore::Admin::V1::CreateIndexRequest.new(project_id: project_id, index: index), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, create_index_client_stub.call_count
      end
    end
  end

  def test_delete_index
    # Create test objects.
    client_result = ::Google::Longrunning::Operation.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    index_id = "hello world"

    delete_index_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_delete_index_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, delete_index_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.delete_index({ project_id: project_id, index_id: index_id }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.delete_index project_id: project_id, index_id: index_id do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.delete_index ::Google::Cloud::Datastore::Admin::V1::DeleteIndexRequest.new(project_id: project_id, index_id: index_id) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.delete_index({ project_id: project_id, index_id: index_id }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.delete_index(::Google::Cloud::Datastore::Admin::V1::DeleteIndexRequest.new(project_id: project_id, index_id: index_id), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, delete_index_client_stub.call_count
      end
    end
  end

  def test_get_index
    # Create test objects.
    client_result = ::Google::Cloud::Datastore::Admin::V1::Index.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    index_id = "hello world"

    get_index_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_get_index_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, get_index_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.get_index({ project_id: project_id, index_id: index_id }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.get_index project_id: project_id, index_id: index_id do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.get_index ::Google::Cloud::Datastore::Admin::V1::GetIndexRequest.new(project_id: project_id, index_id: index_id) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.get_index({ project_id: project_id, index_id: index_id }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.get_index(::Google::Cloud::Datastore::Admin::V1::GetIndexRequest.new(project_id: project_id, index_id: index_id), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, get_index_client_stub.call_count
      end
    end
  end

  def test_list_indexes
    # Create test objects.
    client_result = ::Google::Cloud::Datastore::Admin::V1::ListIndexesResponse.new
    http_response = OpenStruct.new body: client_result.to_json

    call_options = {}

    # Create request parameters for a unary method.
    project_id = "hello world"
    filter = "hello world"
    page_size = 42
    page_token = "hello world"

    list_indexes_client_stub = ClientStub.new http_response do |_verb, uri:, body:, params:, options:, method_name:|
      assert options.metadata.key? :"x-goog-api-client"
      assert options.metadata[:"x-goog-api-client"].include? "rest"
      refute options.metadata[:"x-goog-api-client"].include? "grpc"
    end

    ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::ServiceStub.stub :transcode_list_indexes_request, ["", "", {}] do
      Gapic::Rest::ClientStub.stub :new, list_indexes_client_stub do
        # Create client
        client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
          config.credentials = :dummy_value
        end

        # Use hash object
        client.list_indexes({ project_id: project_id, filter: filter, page_size: page_size, page_token: page_token }) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use named arguments
        client.list_indexes project_id: project_id, filter: filter, page_size: page_size, page_token: page_token do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object
        client.list_indexes ::Google::Cloud::Datastore::Admin::V1::ListIndexesRequest.new(project_id: project_id, filter: filter, page_size: page_size, page_token: page_token) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use hash object with options
        client.list_indexes({ project_id: project_id, filter: filter, page_size: page_size, page_token: page_token }, call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Use protobuf object with options
        client.list_indexes(::Google::Cloud::Datastore::Admin::V1::ListIndexesRequest.new(project_id: project_id, filter: filter, page_size: page_size, page_token: page_token), call_options) do |_result, response|
          assert_equal http_response, response.underlying_op
        end

        # Verify method calls
        assert_equal 5, list_indexes_client_stub.call_count
      end
    end
  end

  def test_configure
    credentials_token = :dummy_value

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil
    Gapic::Rest::ClientStub.stub :new, dummy_stub do
      client = ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client.new do |config|
        config.credentials = credentials_token
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::Datastore::Admin::V1::DatastoreAdmin::Rest::Client::Configuration, config
  end
end
