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

require "helper"

require "google/gax"

require "google/cloud/container_analysis"
require "google/cloud/container_analysis/v1/container_analysis_client"
require "google/devtools/containeranalysis/v1/containeranalysis_services_pb"

class CustomTestError_v1 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1

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

class MockContainerAnalysisCredentials_v1 < Google::Cloud::ContainerAnalysis::V1::Credentials
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

describe Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient do

  describe 'set_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")
      policy = {}

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("set_iam_policy")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          response = client.set_iam_policy(formatted_resource, policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_iam_policy(formatted_resource, policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("set_iam_policy")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_iam_policy(formatted_resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("get_iam_policy")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          response = client.get_iam_policy(formatted_resource)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_iam_policy(formatted_resource) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("get_iam_policy")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_iam_policy(formatted_resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("test_iam_permissions")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          response = client.test_iam_permissions(formatted_resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.test_iam_permissions(formatted_resource, permissions) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisClient.note_path("[PROJECT]", "[NOTE]")
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockContainerAnalysisCredentials_v1.new("test_iam_permissions")

      Google::Cloud::ContainerAnalysis::V1::ContainerAnalysisService::Stub.stub(:new, mock_stub) do
        Google::Cloud::ContainerAnalysis::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::ContainerAnalysis.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.test_iam_permissions(formatted_resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
