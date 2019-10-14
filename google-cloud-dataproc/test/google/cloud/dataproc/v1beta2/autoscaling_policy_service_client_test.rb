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

require "google/cloud/dataproc"
require "google/cloud/dataproc/v1beta2/autoscaling_policy_service_client"
require "google/cloud/dataproc/v1beta2/autoscaling_policies_services_pb"

class CustomTestError_v1beta2 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1beta2

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

class MockAutoscalingPolicyServiceCredentials_v1beta2 < Google::Cloud::Dataproc::V1beta2::Credentials
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

describe Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient do

  describe 'create_autoscaling_policy' do
    custom_error = CustomTestError_v1beta2.new "Custom test error for Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient#create_autoscaling_policy."

    it 'invokes create_autoscaling_policy without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")
      policy = {}

      # Create expected grpc response
      id = "id3355"
      name = "name3373707"
      expected_response = { id: id, name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::CreateAutoscalingPolicyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(policy, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:create_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("create_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          response = client.create_autoscaling_policy(formatted_parent, policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_autoscaling_policy(formatted_parent, policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_autoscaling_policy with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::CreateAutoscalingPolicyRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(policy, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:create_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("create_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta2 do
            client.create_autoscaling_policy(formatted_parent, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_autoscaling_policy' do
    custom_error = CustomTestError_v1beta2.new "Custom test error for Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient#update_autoscaling_policy."

    it 'invokes update_autoscaling_policy without error' do
      # Create request parameters
      policy = {}

      # Create expected grpc response
      id = "id3355"
      name = "name3373707"
      expected_response = { id: id, name: name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::UpdateAutoscalingPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(policy, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy), request.policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:update_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("update_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          response = client.update_autoscaling_policy(policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_autoscaling_policy(policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_autoscaling_policy with error' do
      # Create request parameters
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::UpdateAutoscalingPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(policy, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:update_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("update_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta2 do
            client.update_autoscaling_policy(policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_autoscaling_policy' do
    custom_error = CustomTestError_v1beta2.new "Custom test error for Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient#get_autoscaling_policy."

    it 'invokes get_autoscaling_policy without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")

      # Create expected grpc response
      id = "id3355"
      name_2 = "name2-1052831874"
      expected_response = { id: id, name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1beta2::AutoscalingPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::GetAutoscalingPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:get_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("get_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          response = client.get_autoscaling_policy(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_autoscaling_policy(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_autoscaling_policy with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::GetAutoscalingPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:get_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("get_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta2 do
            client.get_autoscaling_policy(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_autoscaling_policies' do
    custom_error = CustomTestError_v1beta2.new "Custom test error for Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient#list_autoscaling_policies."

    it 'invokes list_autoscaling_policies without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")

      # Create expected grpc response
      next_page_token = ""
      policies_element = {}
      policies = [policies_element]
      expected_response = { next_page_token: next_page_token, policies: policies }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1beta2::ListAutoscalingPoliciesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::ListAutoscalingPoliciesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:list_autoscaling_policies, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("list_autoscaling_policies")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          response = client.list_autoscaling_policies(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.policies.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_autoscaling_policies with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.region_path("[PROJECT]", "[REGION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::ListAutoscalingPoliciesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:list_autoscaling_policies, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("list_autoscaling_policies")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta2 do
            client.list_autoscaling_policies(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_autoscaling_policy' do
    custom_error = CustomTestError_v1beta2.new "Custom test error for Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient#delete_autoscaling_policy."

    it 'invokes delete_autoscaling_policy without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::DeleteAutoscalingPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:delete_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("delete_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          response = client.delete_autoscaling_policy(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_autoscaling_policy(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_autoscaling_policy with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyServiceClient.autoscaling_policy_path("[PROJECT]", "[REGION]", "[AUTOSCALING_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1beta2::DeleteAutoscalingPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1beta2.new(:delete_autoscaling_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAutoscalingPolicyServiceCredentials_v1beta2.new("delete_autoscaling_policy")

      Google::Cloud::Dataproc::V1beta2::AutoscalingPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1beta2::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::AutoscalingPolicyService.new(version: :v1beta2)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1beta2 do
            client.delete_autoscaling_policy(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
