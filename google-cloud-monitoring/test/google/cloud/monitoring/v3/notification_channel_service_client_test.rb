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
require "google/cloud/monitoring/v3/notification_channel_service_client"
require "google/monitoring/v3/notification_service_services_pb"

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

class MockNotificationChannelServiceCredentials < Google::Cloud::Monitoring::V3::Credentials
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

describe Google::Cloud::Monitoring::V3::NotificationChannelServiceClient do

  describe 'list_notification_channel_descriptors' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#list_notification_channel_descriptors."

    it 'invokes list_notification_channel_descriptors without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      channel_descriptors_element = {}
      channel_descriptors = [channel_descriptors_element]
      expected_response = { next_page_token: next_page_token, channel_descriptors: channel_descriptors }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListNotificationChannelDescriptorsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListNotificationChannelDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_notification_channel_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("list_notification_channel_descriptors")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.list_notification_channel_descriptors(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.channel_descriptors.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_notification_channel_descriptors with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListNotificationChannelDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_notification_channel_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("list_notification_channel_descriptors")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_notification_channel_descriptors(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_notification_channel_descriptor' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#get_notification_channel_descriptor."

    it 'invokes get_notification_channel_descriptor without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_descriptor_path("[PROJECT]", "[CHANNEL_DESCRIPTOR]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      type = "type3575610"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        type: type,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::NotificationChannelDescriptor)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetNotificationChannelDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_notification_channel_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("get_notification_channel_descriptor")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.get_notification_channel_descriptor(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_notification_channel_descriptor(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_notification_channel_descriptor with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_descriptor_path("[PROJECT]", "[CHANNEL_DESCRIPTOR]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetNotificationChannelDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_notification_channel_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("get_notification_channel_descriptor")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_notification_channel_descriptor(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_notification_channels' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#list_notification_channels."

    it 'invokes list_notification_channels without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      notification_channels_element = {}
      notification_channels = [notification_channels_element]
      expected_response = { next_page_token: next_page_token, notification_channels: notification_channels }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListNotificationChannelsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListNotificationChannelsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_notification_channels, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("list_notification_channels")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.list_notification_channels(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.notification_channels.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_notification_channels with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListNotificationChannelsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_notification_channels, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("list_notification_channels")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_notification_channels(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_notification_channel' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#get_notification_channel."

    it 'invokes get_notification_channel without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")

      # Create expected grpc response
      type = "type3575610"
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        type: type,
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::NotificationChannel)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("get_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.get_notification_channel(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_notification_channel(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_notification_channel with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("get_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_notification_channel(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_notification_channel' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#create_notification_channel."

    it 'invokes create_notification_channel without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")
      notification_channel = {}

      # Create expected grpc response
      type = "type3575610"
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        type: type,
        name: name_2,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::NotificationChannel)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(notification_channel, Google::Monitoring::V3::NotificationChannel), request.notification_channel)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("create_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.create_notification_channel(formatted_name, notification_channel)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_notification_channel(formatted_name, notification_channel) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_notification_channel with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.project_path("[PROJECT]")
      notification_channel = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(notification_channel, Google::Monitoring::V3::NotificationChannel), request.notification_channel)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("create_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_notification_channel(formatted_name, notification_channel)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_notification_channel' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#update_notification_channel."

    it 'invokes update_notification_channel without error' do
      # Create request parameters
      notification_channel = {}

      # Create expected grpc response
      type = "type3575610"
      name = "name3373707"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      expected_response = {
        type: type,
        name: name,
        display_name: display_name,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::NotificationChannel)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateNotificationChannelRequest, request)
        assert_equal(Google::Gax::to_proto(notification_channel, Google::Monitoring::V3::NotificationChannel), request.notification_channel)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("update_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.update_notification_channel(notification_channel)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_notification_channel(notification_channel) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_notification_channel with error' do
      # Create request parameters
      notification_channel = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateNotificationChannelRequest, request)
        assert_equal(Google::Gax::to_proto(notification_channel, Google::Monitoring::V3::NotificationChannel), request.notification_channel)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("update_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_notification_channel(notification_channel)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_notification_channel' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::NotificationChannelServiceClient#delete_notification_channel."

    it 'invokes delete_notification_channel without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("delete_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          response = client.delete_notification_channel(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_notification_channel(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_notification_channel with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::NotificationChannelServiceClient.notification_channel_path("[PROJECT]", "[NOTIFICATION_CHANNEL]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteNotificationChannelRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_notification_channel, mock_method)

      # Mock auth layer
      mock_credentials = MockNotificationChannelServiceCredentials.new("delete_notification_channel")

      Google::Monitoring::V3::NotificationChannelService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::NotificationChannel.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_notification_channel(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end