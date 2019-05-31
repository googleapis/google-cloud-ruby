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
require "google/cloud/talent/v4beta1/completion_client"
require "google/cloud/talent/v4beta1/completion_service_services_pb"

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

class MockCompletionCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::CompletionClient do

  describe 'complete_query' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::CompletionClient#complete_query."

    it 'invokes complete_query without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompletionClient.tenant_path("[PROJECT]", "[TENANT]")
      query = ''
      page_size = 0

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::CompleteQueryResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CompleteQueryRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(query, request.query)
        assert_equal(page_size, request.page_size)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:complete_query, mock_method)

      # Mock auth layer
      mock_credentials = MockCompletionCredentials_v4beta1.new("complete_query")

      Google::Cloud::Talent::V4beta1::Completion::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Completion.new(version: :v4beta1)

          # Call method
          response = client.complete_query(
            formatted_parent,
            query,
            page_size
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.complete_query(
            formatted_parent,
            query,
            page_size
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes complete_query with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::CompletionClient.tenant_path("[PROJECT]", "[TENANT]")
      query = ''
      page_size = 0

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::CompleteQueryRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(query, request.query)
        assert_equal(page_size, request.page_size)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:complete_query, mock_method)

      # Mock auth layer
      mock_credentials = MockCompletionCredentials_v4beta1.new("complete_query")

      Google::Cloud::Talent::V4beta1::Completion::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Completion.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v4beta1 do
            client.complete_query(
              formatted_parent,
              query,
              page_size
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end