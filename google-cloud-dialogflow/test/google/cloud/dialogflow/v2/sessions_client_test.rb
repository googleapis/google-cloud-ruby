# Copyright 2018 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/dialogflow"
require "google/cloud/dialogflow/v2/sessions_client"
require "google/cloud/dialogflow/v2/session_services_pb"

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

class MockSessionsCredentials < Google::Cloud::Dialogflow::V2::Credentials
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

describe Google::Cloud::Dialogflow::V2::SessionsClient do

  describe 'detect_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::SessionsClient#detect_intent."

    it 'invokes detect_intent without error' do
      # Create request parameters
      formatted_session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path("[PROJECT]", "[SESSION]")
      query_input = {}

      # Create expected grpc response
      response_id = "responseId1847552473"
      expected_response = { response_id: response_id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::DetectIntentResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DetectIntentRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(Google::Gax::to_proto(query_input, Google::Cloud::Dialogflow::V2::QueryInput), request.query_input)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:detect_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockSessionsCredentials.new("detect_intent")

      Google::Cloud::Dialogflow::V2::Sessions::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)

          # Call method
          response = client.detect_intent(formatted_session, query_input)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.detect_intent(formatted_session, query_input) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes detect_intent with error' do
      # Create request parameters
      formatted_session = Google::Cloud::Dialogflow::V2::SessionsClient.session_path("[PROJECT]", "[SESSION]")
      query_input = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dialogflow::V2::DetectIntentRequest, request)
        assert_equal(formatted_session, request.session)
        assert_equal(Google::Gax::to_proto(query_input, Google::Cloud::Dialogflow::V2::QueryInput), request.query_input)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:detect_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockSessionsCredentials.new("detect_intent")

      Google::Cloud::Dialogflow::V2::Sessions::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.detect_intent(formatted_session, query_input)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'streaming_detect_intent' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dialogflow::V2::SessionsClient#streaming_detect_intent."

    it 'invokes streaming_detect_intent without error' do
      # Create request parameters
      session = ''
      query_input = {}
      request = { session: session, query_input: query_input }

      # Create expected grpc response
      response_id = "responseId1847552473"
      expected_response = { response_id: response_id }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dialogflow::V2::StreamingDetectIntentResponse)

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Cloud::Dialogflow::V2::StreamingDetectIntentRequest, request)
        assert_equal(session, request.session)
        assert_equal(Google::Gax::to_proto(query_input, Google::Cloud::Dialogflow::V2::QueryInput), request.query_input)
        OpenStruct.new(execute: [expected_response])
      end
      mock_stub = MockGrpcClientStub.new(:streaming_detect_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockSessionsCredentials.new("streaming_detect_intent")

      Google::Cloud::Dialogflow::V2::Sessions::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)

          # Call method
          response = client.streaming_detect_intent([request])

          # Verify the response
          assert_equal(1, response.count)
          assert_equal(expected_response, response.first)
        end
      end
    end

    it 'invokes streaming_detect_intent with error' do
      # Create request parameters
      session = ''
      query_input = {}
      request = { session: session, query_input: query_input }

      # Mock Grpc layer
      mock_method = proc do |requests|
        request = requests.first
        assert_instance_of(Google::Cloud::Dialogflow::V2::StreamingDetectIntentRequest, request)
        assert_equal(session, request.session)
        assert_equal(Google::Gax::to_proto(query_input, Google::Cloud::Dialogflow::V2::QueryInput), request.query_input)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:streaming_detect_intent, mock_method)

      # Mock auth layer
      mock_credentials = MockSessionsCredentials.new("streaming_detect_intent")

      Google::Cloud::Dialogflow::V2::Sessions::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dialogflow::V2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dialogflow::Sessions.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.streaming_detect_intent([request])
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end