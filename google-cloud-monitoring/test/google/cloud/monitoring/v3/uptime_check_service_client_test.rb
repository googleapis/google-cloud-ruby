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
require "google/cloud/monitoring/v3/uptime_check_service_client"
require "google/monitoring/v3/uptime_service_services_pb"

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

class MockUptimeCheckServiceCredentials < Google::Cloud::Monitoring::Credentials
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

describe Google::Cloud::Monitoring::V3::UptimeCheckServiceClient do

  describe 'list_uptime_check_configs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#list_uptime_check_configs."

    it 'invokes list_uptime_check_configs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      uptime_check_configs_element = {}
      uptime_check_configs = [uptime_check_configs_element]
      expected_response = { next_page_token: next_page_token, uptime_check_configs: uptime_check_configs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListUptimeCheckConfigsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListUptimeCheckConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_uptime_check_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("list_uptime_check_configs")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.list_uptime_check_configs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.uptime_check_configs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_uptime_check_configs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListUptimeCheckConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_uptime_check_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("list_uptime_check_configs")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_uptime_check_configs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_uptime_check_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#get_uptime_check_config."

    it 'invokes get_uptime_check_config without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.uptime_check_config_path("[PROJECT]", "[UPTIME_CHECK_CONFIG]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::UptimeCheckConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetUptimeCheckConfigRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("get_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.get_uptime_check_config(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_uptime_check_config with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.uptime_check_config_path("[PROJECT]", "[UPTIME_CHECK_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetUptimeCheckConfigRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("get_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_uptime_check_config(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_uptime_check_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#create_uptime_check_config."

    it 'invokes create_uptime_check_config without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.project_path("[PROJECT]")
      uptime_check_config = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::UptimeCheckConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateUptimeCheckConfigRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(uptime_check_config, Google::Monitoring::V3::UptimeCheckConfig), request.uptime_check_config)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("create_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.create_uptime_check_config(formatted_parent, uptime_check_config)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_uptime_check_config with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.project_path("[PROJECT]")
      uptime_check_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateUptimeCheckConfigRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(uptime_check_config, Google::Monitoring::V3::UptimeCheckConfig), request.uptime_check_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("create_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_uptime_check_config(formatted_parent, uptime_check_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_uptime_check_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#update_uptime_check_config."

    it 'invokes update_uptime_check_config without error' do
      # Create request parameters
      uptime_check_config = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::UptimeCheckConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateUptimeCheckConfigRequest, request)
        assert_equal(Google::Gax::to_proto(uptime_check_config, Google::Monitoring::V3::UptimeCheckConfig), request.uptime_check_config)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("update_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.update_uptime_check_config(uptime_check_config)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_uptime_check_config with error' do
      # Create request parameters
      uptime_check_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateUptimeCheckConfigRequest, request)
        assert_equal(Google::Gax::to_proto(uptime_check_config, Google::Monitoring::V3::UptimeCheckConfig), request.uptime_check_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("update_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_uptime_check_config(uptime_check_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_uptime_check_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#delete_uptime_check_config."

    it 'invokes delete_uptime_check_config without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.uptime_check_config_path("[PROJECT]", "[UPTIME_CHECK_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteUptimeCheckConfigRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("delete_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.delete_uptime_check_config(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_uptime_check_config with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::UptimeCheckServiceClient.uptime_check_config_path("[PROJECT]", "[UPTIME_CHECK_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteUptimeCheckConfigRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_uptime_check_config, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("delete_uptime_check_config")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_uptime_check_config(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_uptime_check_ips' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::UptimeCheckServiceClient#list_uptime_check_ips."

    it 'invokes list_uptime_check_ips without error' do
      # Create expected grpc response
      next_page_token = ""
      uptime_check_ips_element = {}
      uptime_check_ips = [uptime_check_ips_element]
      expected_response = { next_page_token: next_page_token, uptime_check_ips: uptime_check_ips }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListUptimeCheckIpsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_uptime_check_ips, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("list_uptime_check_ips")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          response = client.list_uptime_check_ips

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.uptime_check_ips.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_uptime_check_ips with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_uptime_check_ips, mock_method)

      # Mock auth layer
      mock_credentials = MockUptimeCheckServiceCredentials.new("list_uptime_check_ips")

      Google::Monitoring::V3::UptimeCheckService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::UptimeCheck.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_uptime_check_ips
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end