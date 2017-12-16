# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/video_intelligence"
require "google/cloud/video_intelligence/v1beta2/video_intelligence_service_client"
require "google/cloud/videointelligence/v1beta2/video_intelligence_services_pb"
require "google/longrunning/operations_pb"

class CustomTestError < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub

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

class MockVideoIntelligenceServiceCredentials < Google::Cloud::VideoIntelligence::Credentials
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

describe Google::Cloud::VideoIntelligence::V1beta2::VideoIntelligenceServiceClient do

  describe 'annotate_video' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::VideoIntelligence::V1beta2::VideoIntelligenceServiceClient#annotate_video."

    it 'invokes annotate_video without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Videointelligence::V1beta2::AnnotateVideoResponse)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/annotate_video_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do
        operation
      end
      mock_stub = MockGrpcClientStub.new(:annotate_video, mock_method)

      # Mock auth layer
      mock_credentials = MockVideoIntelligenceServiceCredentials.new("annotate_video")

      Google::Cloud::Videointelligence::V1beta2::VideoIntelligenceService::Stub.stub(:new, mock_stub) do
        Google::Cloud::VideoIntelligence::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::VideoIntelligence.new(version: :v1beta2)

          # Call method
          response = client.annotate_video

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes annotate_video and returns an operation error.' do
      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::VideoIntelligence::V1beta2::VideoIntelligenceServiceClient#annotate_video.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/annotate_video_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do
        operation
      end
      mock_stub = MockGrpcClientStub.new(:annotate_video, mock_method)

      # Mock auth layer
      mock_credentials = MockVideoIntelligenceServiceCredentials.new("annotate_video")

      Google::Cloud::Videointelligence::V1beta2::VideoIntelligenceService::Stub.stub(:new, mock_stub) do
        Google::Cloud::VideoIntelligence::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::VideoIntelligence.new(version: :v1beta2)

          # Call method
          response = client.annotate_video

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes annotate_video with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:annotate_video, mock_method)

      # Mock auth layer
      mock_credentials = MockVideoIntelligenceServiceCredentials.new("annotate_video")

      Google::Cloud::Videointelligence::V1beta2::VideoIntelligenceService::Stub.stub(:new, mock_stub) do
        Google::Cloud::VideoIntelligence::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::VideoIntelligence.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.annotate_video
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end