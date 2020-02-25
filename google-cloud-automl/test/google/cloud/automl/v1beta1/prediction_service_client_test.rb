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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/automl"
require "google/cloud/automl/v1beta1/prediction_service_client"
require "google/cloud/automl/v1beta1/prediction_service_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError_v1beta1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1beta1

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

class MockPredictionServiceCredentials_v1beta1 < Google::Cloud::AutoML::V1beta1::Credentials
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

describe Google::Cloud::AutoML::V1beta1::PredictionServiceClient do

  describe 'predict' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::PredictionServiceClient#predict."

    it 'invokes predict without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      payload = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::PredictResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::PredictRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(payload, Google::Cloud::AutoML::V1beta1::ExamplePayload), request.payload)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:predict, mock_method)

      # Mock auth layer
      mock_credentials = MockPredictionServiceCredentials_v1beta1.new("predict")

      Google::Cloud::AutoML::V1beta1::PredictionService::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)

          # Call method
          response = client.predict(formatted_name, payload)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.predict(formatted_name, payload) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes predict with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      payload = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::PredictRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(payload, Google::Cloud::AutoML::V1beta1::ExamplePayload), request.payload)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:predict, mock_method)

      # Mock auth layer
      mock_credentials = MockPredictionServiceCredentials_v1beta1.new("predict")

      Google::Cloud::AutoML::V1beta1::PredictionService::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.predict(formatted_name, payload)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_predict' do
    custom_error = CustomTestError_v1beta1.new "Custom test error for Google::Cloud::AutoML::V1beta1::PredictionServiceClient#batch_predict."

    it 'invokes batch_predict without error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      input_config = {}
      output_config = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::AutoML::V1beta1::BatchPredictResult)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_predict_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::BatchPredictRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig), request.input_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:batch_predict, mock_method)

      # Mock auth layer
      mock_credentials = MockPredictionServiceCredentials_v1beta1.new("batch_predict")

      Google::Cloud::AutoML::V1beta1::PredictionService::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)

          # Call method
          response = client.batch_predict(
            formatted_name,
            input_config,
            output_config
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes batch_predict and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      input_config = {}
      output_config = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::AutoML::V1beta1::PredictionServiceClient#batch_predict.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/batch_predict_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::BatchPredictRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig), request.input_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig), request.output_config)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:batch_predict, mock_method)

      # Mock auth layer
      mock_credentials = MockPredictionServiceCredentials_v1beta1.new("batch_predict")

      Google::Cloud::AutoML::V1beta1::PredictionService::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)

          # Call method
          response = client.batch_predict(
            formatted_name,
            input_config,
            output_config
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes batch_predict with error' do
      # Create request parameters
      formatted_name = Google::Cloud::AutoML::V1beta1::PredictionServiceClient.model_path("[PROJECT]", "[LOCATION]", "[MODEL]")
      input_config = {}
      output_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::AutoML::V1beta1::BatchPredictRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(input_config, Google::Cloud::AutoML::V1beta1::BatchPredictInputConfig), request.input_config)
        assert_equal(Google::Gax::to_proto(output_config, Google::Cloud::AutoML::V1beta1::BatchPredictOutputConfig), request.output_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta1.new(:batch_predict, mock_method)

      # Mock auth layer
      mock_credentials = MockPredictionServiceCredentials_v1beta1.new("batch_predict")

      Google::Cloud::AutoML::V1beta1::PredictionService::Stub.stub(:new, mock_stub) do
        Google::Cloud::AutoML::V1beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::AutoML::Prediction.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta1 do
            client.batch_predict(
              formatted_name,
              input_config,
              output_config
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end