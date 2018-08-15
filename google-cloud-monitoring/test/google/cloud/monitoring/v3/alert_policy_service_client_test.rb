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

require "google/cloud/monitoring"
require "google/cloud/monitoring/v3/alert_policy_service_client"
require "google/monitoring/v3/alert_service_services_pb"

class CustomTestError_v3 < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v3

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

class MockAlertPolicyServiceCredentials_v3 < Google::Cloud::Monitoring::V3::Credentials
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

describe Google::Cloud::Monitoring::V3::AlertPolicyServiceClient do

  describe 'list_alert_policies' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::AlertPolicyServiceClient#list_alert_policies."

    it 'invokes list_alert_policies without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      alert_policies_element = {}
      alert_policies = [alert_policies_element]
      expected_response = { next_page_token: next_page_token, alert_policies: alert_policies }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListAlertPoliciesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListAlertPoliciesRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_alert_policies, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("list_alert_policies")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          response = client.list_alert_policies(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.alert_policies.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_alert_policies with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListAlertPoliciesRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_alert_policies, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("list_alert_policies")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_alert_policies(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_alert_policy' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::AlertPolicyServiceClient#get_alert_policy."

    it 'invokes get_alert_policy without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::AlertPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("get_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          response = client.get_alert_policy(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_alert_policy(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_alert_policy with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("get_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_alert_policy(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_alert_policy' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::AlertPolicyServiceClient#create_alert_policy."

    it 'invokes create_alert_policy without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")
      alert_policy = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::AlertPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(alert_policy, Google::Monitoring::V3::AlertPolicy), request.alert_policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("create_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          response = client.create_alert_policy(formatted_name, alert_policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_alert_policy(formatted_name, alert_policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_alert_policy with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.project_path("[PROJECT]")
      alert_policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(alert_policy, Google::Monitoring::V3::AlertPolicy), request.alert_policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("create_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_alert_policy(formatted_name, alert_policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_alert_policy' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::AlertPolicyServiceClient#delete_alert_policy."

    it 'invokes delete_alert_policy without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("delete_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          response = client.delete_alert_policy(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_alert_policy(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_alert_policy with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::AlertPolicyServiceClient.alert_policy_path("[PROJECT]", "[ALERT_POLICY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteAlertPolicyRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("delete_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_alert_policy(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_alert_policy' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::AlertPolicyServiceClient#update_alert_policy."

    it 'invokes update_alert_policy without error' do
      # Create request parameters
      alert_policy = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::AlertPolicy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateAlertPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(alert_policy, Google::Monitoring::V3::AlertPolicy), request.alert_policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("update_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          response = client.update_alert_policy(alert_policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_alert_policy(alert_policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_alert_policy with error' do
      # Create request parameters
      alert_policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateAlertPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(alert_policy, Google::Monitoring::V3::AlertPolicy), request.alert_policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_alert_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockAlertPolicyServiceCredentials_v3.new("update_alert_policy")

      Google::Monitoring::V3::AlertPolicyService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::AlertPolicy.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_alert_policy(alert_policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end