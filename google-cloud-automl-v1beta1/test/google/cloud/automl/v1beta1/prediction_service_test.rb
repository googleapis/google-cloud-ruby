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

require "google/cloud/automl/v1beta1/prediction_service_pb"
require "google/cloud/automl/v1beta1/prediction_service_services_pb"
require "google/cloud/automl/v1beta1/prediction_service"

class ::Google::Cloud::AutoML::V1beta1::PredictionService::ClientTest < Minitest::Test
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

  def test_predict
    # Create GRPC objects.
    grpc_response = ::Google::Cloud::AutoML::V1beta1::PredictResponse.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    payload = {}
    params = {}

    predict_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :predict, name
      assert_kind_of ::Google::Cloud::AutoML::V1beta1::PredictRequest, request
      assert_equal "hello world", request["name"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::AutoML::V1beta1::ExamplePayload), request["payload"]
      assert_equal({}, request["params"].to_h)
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, predict_client_stub do
      # Create client
      client = ::Google::Cloud::AutoML::V1beta1::PredictionService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.predict({ name: name, payload: payload, params: params }) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.predict name: name, payload: payload, params: params do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.predict ::Google::Cloud::AutoML::V1beta1::PredictRequest.new(name: name, payload: payload, params: params) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.predict({ name: name, payload: payload, params: params }, grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.predict(::Google::Cloud::AutoML::V1beta1::PredictRequest.new(name: name, payload: payload, params: params), grpc_options) do |response, operation|
        assert_equal grpc_response, response
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, predict_client_stub.call_rpc_count
    end
  end

  def test_batch_predict
    # Create GRPC objects.
    grpc_response = ::Google::Longrunning::Operation.new
    grpc_operation = GRPC::ActiveCall::Operation.new nil
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    grpc_options = {}

    # Create request parameters for a unary method.
    name = "hello world"
    input_config = {}
    output_config = {}
    params = {}

    batch_predict_client_stub = ClientStub.new grpc_response, grpc_operation do |name, request, options:|
      assert_equal :batch_predict, name
      assert_kind_of ::Google::Cloud::AutoML::V1beta1::BatchPredictRequest, request
      assert_equal "hello world", request["name"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig), request["input_config"]
      assert_equal Gapic::Protobuf.coerce({}, to: ::Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig), request["output_config"]
      assert_equal({}, request["params"].to_h)
      refute_nil options
    end

    Gapic::ServiceStub.stub :new, batch_predict_client_stub do
      # Create client
      client = ::Google::Cloud::AutoML::V1beta1::PredictionService::Client.new do |config|
        config.credentials = grpc_channel
      end

      # Use hash object
      client.batch_predict({ name: name, input_config: input_config, output_config: output_config, params: params }) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use named arguments
      client.batch_predict name: name, input_config: input_config, output_config: output_config, params: params do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object
      client.batch_predict ::Google::Cloud::AutoML::V1beta1::BatchPredictRequest.new(name: name, input_config: input_config, output_config: output_config, params: params) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use hash object with options
      client.batch_predict({ name: name, input_config: input_config, output_config: output_config, params: params }, grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Use protobuf object with options
      client.batch_predict(::Google::Cloud::AutoML::V1beta1::BatchPredictRequest.new(name: name, input_config: input_config, output_config: output_config, params: params), grpc_options) do |response, operation|
        assert_kind_of Gapic::Operation, response
        assert_equal grpc_response, response.grpc_op
        assert_equal grpc_operation, operation
      end

      # Verify method calls
      assert_equal 5, batch_predict_client_stub.call_rpc_count
    end
  end

  def test_configure
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = block_config = config = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::AutoML::V1beta1::PredictionService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    config = client.configure do |c|
      block_config = c
    end

    assert_same block_config, config
    assert_kind_of ::Google::Cloud::AutoML::V1beta1::PredictionService::Client::Configuration, config
  end

  def test_operations_client
    grpc_channel = GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure

    client = nil
    dummy_stub = ClientStub.new nil, nil
    Gapic::ServiceStub.stub :new, dummy_stub do
      client = ::Google::Cloud::AutoML::V1beta1::PredictionService::Client.new do |config|
        config.credentials = grpc_channel
      end
    end

    assert_kind_of ::Google::Cloud::AutoML::V1beta1::PredictionService::Operations, client.operations_client
  end
end
