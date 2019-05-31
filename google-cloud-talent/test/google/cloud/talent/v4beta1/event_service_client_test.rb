# Copyright 2019 Google LLC
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

require "google/cloud/talent"
require "google/cloud/talent/v4beta1/event_service_client"
require "google/cloud/talent/v4beta1/event_service_services_pb"

class CustomTestError_v4beta1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v4beta1

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

class MockEventServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::EventServiceClient do

  describe 'create_client_event' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::EventServiceClient#create_client_event."

    it 'invokes create_client_event without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::EventServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      client_event = {}

      # Create expected grpc response
      request_id = "requestId37109963"
      event_id = "eventId278118624"
      event_notes = "eventNotes445073628"
      expected_response = {
        request_id: request_id,
        event_id: event_id,
        event_notes: event_notes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ClientEvent)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateClientEventRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(client_event, Google::Cloud::Talent::V4beta1::ClientEvent), request.client_event)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_client_event, mock_method)

      # Mock auth layer
      mock_credentials = MockEventServiceCredentials_v4beta1.new("create_client_event")

      Google::Cloud::Talent::V4beta1::EventService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Event.new(version: :v4beta1)

          # Call method
          response = client.create_client_event(formatted_parent, client_event)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_client_event(formatted_parent, client_event) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_client_event with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::EventServiceClient.tenant_path("[PROJECT]", "[TENANT]")
      client_event = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CreateClientEventRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(client_event, Google::Cloud::Talent::V4beta1::ClientEvent), request.client_event)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:create_client_event, mock_method)

      # Mock auth layer
      mock_credentials = MockEventServiceCredentials_v4beta1.new("create_client_event")

      Google::Cloud::Talent::V4beta1::EventService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Event.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.create_client_event(formatted_parent, client_event)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end