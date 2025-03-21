# frozen_string_literal: true

# Copyright 2020 Google LLC
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

require "google/cloud/phishingprotection/v1beta1/phishingprotection_pb"
require "google/cloud/phishingprotection/v1beta1/phishingprotection_services_pb"
require "google/cloud/phishing_protection/v1beta1/phishing_protection_service"

class ::Google::Cloud::PhishingProtection::V1beta1::PhishingProtectionService::ClientTest < Minitest::Test
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

  def test_report_phishing
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::PhishingProtection::V1beta1::ReportPhishingResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    parent = "hello world"
    uri = "hello world"

    report_phishing_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :report_phishing, name
      assert_kind_of ::Google::Cloud::PhishingProtection::V1beta1::ReportPhishingRequest, request
      assert_equal "hello world", request["parent"]
      assert_equal "hello world", request["uri"]
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, report_phishing_client_stub do
      # Create client
      client = ::Google::Cloud::PhishingProtection::V1beta1::PhishingProtectionService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.report_phishing({ parent: parent, uri: uri }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.report_phishing parent: parent, uri: uri do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.report_phishing ::Google::Cloud::PhishingProtection::V1beta1::ReportPhishingRequest.new(parent: parent, uri: uri) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.report_phishing({ parent: parent, uri: uri }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.report_phishing(::Google::Cloud::PhishingProtection::V1beta1::ReportPhishingRequest.new(parent: parent, uri: uri), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, report_phishing_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::PhishingProtection::V1beta1::PhishingProtectionService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::PhishingProtection::V1beta1::PhishingProtectionService::Client::Configuration, config
  end
end
