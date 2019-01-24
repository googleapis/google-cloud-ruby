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
require "google/cloud/talent/v4beta1/resume_service_client"
require "google/cloud/talent/v4beta1/resume_service_services_pb"

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

class MockResumeServiceCredentials_v4beta1 < Google::Cloud::Talent::V4beta1::Credentials
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

describe Google::Cloud::Talent::V4beta1::ResumeServiceClient do

  describe 'parse_resume' do
    custom_error = CustomTestError_v4beta1.new "Custom test error for Google::Cloud::Talent::V4beta1::ResumeServiceClient#parse_resume."

    it 'invokes parse_resume without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ResumeServiceClient.project_path("[PROJECT]")
      resume = ''

      # Create expected grpc response
      raw_text = "rawText503586532"
      expected_response = { raw_text: raw_text }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Talent::V4beta1::ParseResumeResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ParseResumeRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(resume, request.resume)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:parse_resume, mock_method)

      # Mock auth layer
      mock_credentials = MockResumeServiceCredentials_v4beta1.new("parse_resume")

      Google::Cloud::Talent::V4beta1::ResumeService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Resume.new(version: :v4beta1)

          # Call method
          response = client.parse_resume(formatted_parent, resume)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.parse_resume(formatted_parent, resume) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes parse_resume with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Talent::V4beta1::ResumeServiceClient.project_path("[PROJECT]")
      resume = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Talent::V4beta1::ParseResumeRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(resume, request.resume)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v4beta1.new(:parse_resume, mock_method)

      # Mock auth layer
      mock_credentials = MockResumeServiceCredentials_v4beta1.new("parse_resume")

      Google::Cloud::Talent::V4beta1::ResumeService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Talent::V4beta1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Talent::Resume.new(version: :v4beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.parse_resume(formatted_parent, resume)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end