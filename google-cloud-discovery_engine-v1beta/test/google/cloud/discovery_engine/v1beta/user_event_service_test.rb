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

require "gapic/grpc/service_stub"

require "google/cloud/discoveryengine/v1beta/user_event_service_pb"
require "google/cloud/discoveryengine/v1beta/user_event_service_services_pb"
require "google/cloud/discovery_engine/v1beta/user_event_service"

class ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::ClientTest < Minitest::Test
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

  def test_write_user_event
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::DiscoveryEngine::V1beta::UserEvent.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    user_event = {}
    write_async = true

    write_user_event_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :write_user_event, name
      assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::WriteUserEventRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::DiscoveryEngine::V1beta::UserEvent), request["user_event"]
      assert request.has_user_event?
      assert_equal true, request["write_async"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, write_user_event_client_stub do
      # Create client
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.write_user_event({ parent: parent, user_event: user_event, write_async: write_async }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.write_user_event parent: parent, user_event: user_event, write_async: write_async do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.write_user_event ::Google::Cloud::DiscoveryEngine::V1beta::WriteUserEventRequest.new(parent: parent, user_event: user_event, write_async: write_async) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.write_user_event({ parent: parent, user_event: user_event, write_async: write_async }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.write_user_event(::Google::Cloud::DiscoveryEngine::V1beta::WriteUserEventRequest.new(parent: parent, user_event: user_event, write_async: write_async), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, write_user_event_client_stub.call_rpc_count
    end
  end

  def test_collect_user_event
    # Create GRPC objects.
    grpc_response = ::Google::Api::HttpBody.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    user_event = "hello world"
    uri = "hello world"
    ets = 42

    collect_user_event_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :collect_user_event, name
      assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::CollectUserEventRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal "hello world", request["user_event"]
      assert_equal "hello world", request["uri"]
      assert request.has_uri?
      assert_equal 42, request["ets"]
      assert request.has_ets?
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, collect_user_event_client_stub do
      # Create client
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.collect_user_event({ parent: parent, user_event: user_event, uri: uri, ets: ets }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.collect_user_event parent: parent, user_event: user_event, uri: uri, ets: ets do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.collect_user_event ::Google::Cloud::DiscoveryEngine::V1beta::CollectUserEventRequest.new(parent: parent, user_event: user_event, uri: uri, ets: ets) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.collect_user_event({ parent: parent, user_event: user_event, uri: uri, ets: ets }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.collect_user_event(::Google::Cloud::DiscoveryEngine::V1beta::CollectUserEventRequest.new(parent: parent, user_event: user_event, uri: uri, ets: ets), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, collect_user_event_client_stub.call_rpc_count
    end
  end

  def test_purge_user_events
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    filter = "hello world"
    force = true

    purge_user_events_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :purge_user_events, name
      assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::PurgeUserEventsRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal "hello world", request["filter"]
      assert_equal true, request["force"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, purge_user_events_client_stub do
      # Create client
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.purge_user_events({ parent: parent, filter: filter, force: force }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.purge_user_events parent: parent, filter: filter, force: force do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.purge_user_events ::Google::Cloud::DiscoveryEngine::V1beta::PurgeUserEventsRequest.new(parent: parent, filter: filter, force: force) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.purge_user_events({ parent: parent, filter: filter, force: force }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.purge_user_events(::Google::Cloud::DiscoveryEngine::V1beta::PurgeUserEventsRequest.new(parent: parent, filter: filter, force: force), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, purge_user_events_client_stub.call_rpc_count
    end
  end

  def test_import_user_events
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    inline_source = {}
    parent = "hello world"
    error_config = {}

    import_user_events_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :import_user_events, name
      assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::ImportUserEventsRequest, request
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::DiscoveryEngine::V1beta::ImportUserEventsRequest::InlineSource), request["inline_source"]
      assert_equal :inline_source, request.source
      assert_equal "hello world", request["parent"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::DiscoveryEngine::V1beta::ImportErrorConfig), request["error_config"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, import_user_events_client_stub do
      # Create client
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.import_user_events({ inline_source: inline_source, parent: parent, error_config: error_config }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.import_user_events inline_source: inline_source, parent: parent, error_config: error_config do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.import_user_events ::Google::Cloud::DiscoveryEngine::V1beta::ImportUserEventsRequest.new(inline_source: inline_source, parent: parent, error_config: error_config) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.import_user_events({ inline_source: inline_source, parent: parent, error_config: error_config }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.import_user_events(::Google::Cloud::DiscoveryEngine::V1beta::ImportUserEventsRequest.new(inline_source: inline_source, parent: parent, error_config: error_config), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, import_user_events_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client::Configuration, config
  end

  def test_operations_client
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    assert_kind_of ::Google::Cloud::DiscoveryEngine::V1beta::UserEventService::Operations, client.operations_client
  end
end
