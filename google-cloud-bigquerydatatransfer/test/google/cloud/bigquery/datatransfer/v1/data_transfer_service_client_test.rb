# Copyright 2017, Google LLC All rights reserved.
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

require "google/cloud/bigquery/datatransfer"
require "google/cloud/bigquery/datatransfer/v1/data_transfer_service_client"
require "google/cloud/bigquery/datatransfer/v1/datatransfer_services_pb"

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

class MockDataTransferServiceCredentials < Google::Cloud::Bigquery::Datatransfer::Credentials
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

describe Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient do

  describe 'get_data_source' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#get_data_source."

    it 'invokes get_data_source without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_data_source_path("[PROJECT]", "[LOCATION]", "[DATA_SOURCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      data_source_id = "dataSourceId-1015796374"
      display_name = "displayName1615086568"
      description = "description-1724546052"
      client_id = "clientId-1904089585"
      supports_multiple_transfers = true
      update_deadline_seconds = 991471694
      default_schedule = "defaultSchedule-800168235"
      supports_custom_schedule = true
      help_url = "helpUrl-789431439"
      default_data_refresh_window_days = -1804935157
      manual_runs_disabled = true
      expected_response = {
        name: name_2,
        data_source_id: data_source_id,
        display_name: display_name,
        description: description,
        client_id: client_id,
        supports_multiple_transfers: supports_multiple_transfers,
        update_deadline_seconds: update_deadline_seconds,
        default_schedule: default_schedule,
        supports_custom_schedule: supports_custom_schedule,
        help_url: help_url,
        default_data_refresh_window_days: default_data_refresh_window_days,
        manual_runs_disabled: manual_runs_disabled
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::DataSource)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetDataSourceRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_data_source, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_data_source")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.get_data_source(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_data_source with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_data_source_path("[PROJECT]", "[LOCATION]", "[DATA_SOURCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetDataSourceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_data_source, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_data_source")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_data_source(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_data_sources' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#list_data_sources."

    it 'invokes list_data_sources without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      data_sources_element = {}
      data_sources = [data_sources_element]
      expected_response = { next_page_token: next_page_token, data_sources: data_sources }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::ListDataSourcesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListDataSourcesRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_data_sources, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_data_sources")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.list_data_sources(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.data_sources.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_data_sources with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListDataSourcesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_data_sources, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_data_sources")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_data_sources(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_transfer_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#create_transfer_config."

    it 'invokes create_transfer_config without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")
      transfer_config = {}

      # Create expected grpc response
      name = "name3373707"
      destination_dataset_id = "destinationDatasetId1541564179"
      display_name = "displayName1615086568"
      data_source_id = "dataSourceId-1015796374"
      schedule = "schedule-697920873"
      data_refresh_window_days = 327632845
      disabled = true
      user_id = -147132913
      dataset_region = "datasetRegion959248539"
      expected_response = {
        name: name,
        destination_dataset_id: destination_dataset_id,
        display_name: display_name,
        data_source_id: data_source_id,
        schedule: schedule,
        data_refresh_window_days: data_refresh_window_days,
        disabled: disabled,
        user_id: user_id,
        dataset_region: dataset_region
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::CreateTransferConfigRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(transfer_config, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig), request.transfer_config)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:create_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("create_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.create_transfer_config(formatted_parent, transfer_config)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_transfer_config with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")
      transfer_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::CreateTransferConfigRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(transfer_config, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig), request.transfer_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("create_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_transfer_config(formatted_parent, transfer_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_transfer_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#update_transfer_config."

    it 'invokes update_transfer_config without error' do
      # Create request parameters
      transfer_config = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      destination_dataset_id = "destinationDatasetId1541564179"
      display_name = "displayName1615086568"
      data_source_id = "dataSourceId-1015796374"
      schedule = "schedule-697920873"
      data_refresh_window_days = 327632845
      disabled = true
      user_id = -147132913
      dataset_region = "datasetRegion959248539"
      expected_response = {
        name: name,
        destination_dataset_id: destination_dataset_id,
        display_name: display_name,
        data_source_id: data_source_id,
        schedule: schedule,
        data_refresh_window_days: data_refresh_window_days,
        disabled: disabled,
        user_id: user_id,
        dataset_region: dataset_region
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::UpdateTransferConfigRequest, request)
        assert_equal(Google::Gax::to_proto(transfer_config, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig), request.transfer_config)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:update_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("update_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.update_transfer_config(transfer_config, update_mask)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_transfer_config with error' do
      # Create request parameters
      transfer_config = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::UpdateTransferConfigRequest, request)
        assert_equal(Google::Gax::to_proto(transfer_config, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig), request.transfer_config)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("update_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_transfer_config(transfer_config, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_transfer_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#delete_transfer_config."

    it 'invokes delete_transfer_config without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferConfigRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("delete_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.delete_transfer_config(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_transfer_config with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferConfigRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("delete_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_transfer_config(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_transfer_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#get_transfer_config."

    it 'invokes get_transfer_config without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      destination_dataset_id = "destinationDatasetId1541564179"
      display_name = "displayName1615086568"
      data_source_id = "dataSourceId-1015796374"
      schedule = "schedule-697920873"
      data_refresh_window_days = 327632845
      disabled = true
      user_id = -147132913
      dataset_region = "datasetRegion959248539"
      expected_response = {
        name: name_2,
        destination_dataset_id: destination_dataset_id,
        display_name: display_name,
        data_source_id: data_source_id,
        schedule: schedule,
        data_refresh_window_days: data_refresh_window_days,
        disabled: disabled,
        user_id: user_id,
        dataset_region: dataset_region
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::TransferConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetTransferConfigRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.get_transfer_config(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_transfer_config with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetTransferConfigRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_transfer_config, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_transfer_config")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_transfer_config(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_transfer_configs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#list_transfer_configs."

    it 'invokes list_transfer_configs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      transfer_configs_element = {}
      transfer_configs = [transfer_configs_element]
      expected_response = { next_page_token: next_page_token, transfer_configs: transfer_configs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferConfigsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_configs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.list_transfer_configs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.transfer_configs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_transfer_configs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_configs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_transfer_configs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'schedule_transfer_runs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#schedule_transfer_runs."

    it 'invokes schedule_transfer_runs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")
      start_time = {}
      end_time = {}

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::ScheduleTransferRunsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ScheduleTransferRunsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(start_time, Google::Protobuf::Timestamp), request.start_time)
        assert_equal(Google::Gax::to_proto(end_time, Google::Protobuf::Timestamp), request.end_time)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:schedule_transfer_runs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("schedule_transfer_runs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.schedule_transfer_runs(
            formatted_parent,
            start_time,
            end_time
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes schedule_transfer_runs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")
      start_time = {}
      end_time = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ScheduleTransferRunsRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(start_time, Google::Protobuf::Timestamp), request.start_time)
        assert_equal(Google::Gax::to_proto(end_time, Google::Protobuf::Timestamp), request.end_time)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:schedule_transfer_runs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("schedule_transfer_runs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.schedule_transfer_runs(
              formatted_parent,
              start_time,
              end_time
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_transfer_run' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#get_transfer_run."

    it 'invokes get_transfer_run without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      destination_dataset_id = "destinationDatasetId1541564179"
      data_source_id = "dataSourceId-1015796374"
      user_id = -147132913
      schedule = "schedule-697920873"
      expected_response = {
        name: name_2,
        destination_dataset_id: destination_dataset_id,
        data_source_id: data_source_id,
        user_id: user_id,
        schedule: schedule
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::TransferRun)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetTransferRunRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_transfer_run, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_transfer_run")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.get_transfer_run(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_transfer_run with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::GetTransferRunRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_transfer_run, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("get_transfer_run")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_transfer_run(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_transfer_run' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#delete_transfer_run."

    it 'invokes delete_transfer_run without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferRunRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_transfer_run, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("delete_transfer_run")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.delete_transfer_run(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_transfer_run with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::DeleteTransferRunRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_transfer_run, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("delete_transfer_run")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_transfer_run(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_transfer_runs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#list_transfer_runs."

    it 'invokes list_transfer_runs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Create expected grpc response
      next_page_token = ""
      transfer_runs_element = {}
      transfer_runs = [transfer_runs_element]
      expected_response = { next_page_token: next_page_token, transfer_runs: transfer_runs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferRunsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferRunsRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_runs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_runs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.list_transfer_runs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.transfer_runs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_transfer_runs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_transfer_config_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferRunsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_runs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_runs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_transfer_runs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_transfer_logs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#list_transfer_logs."

    it 'invokes list_transfer_logs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Create expected grpc response
      next_page_token = ""
      transfer_messages_element = {}
      transfer_messages = [transfer_messages_element]
      expected_response = { next_page_token: next_page_token, transfer_messages: transfer_messages }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::ListTransferLogsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferLogsRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_logs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_logs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.list_transfer_logs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.transfer_messages.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_transfer_logs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_run_path("[PROJECT]", "[LOCATION]", "[TRANSFER_CONFIG]", "[RUN]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::ListTransferLogsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_transfer_logs, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("list_transfer_logs")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_transfer_logs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'check_valid_creds' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient#check_valid_creds."

    it 'invokes check_valid_creds without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_data_source_path("[PROJECT]", "[LOCATION]", "[DATA_SOURCE]")

      # Create expected grpc response
      has_valid_creds = false
      expected_response = { has_valid_creds: has_valid_creds }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Bigquery::Datatransfer::V1::CheckValidCredsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::CheckValidCredsRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:check_valid_creds, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("check_valid_creds")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          response = client.check_valid_creds(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes check_valid_creds with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigquery::Datatransfer::V1::DataTransferServiceClient.location_data_source_path("[PROJECT]", "[LOCATION]", "[DATA_SOURCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Bigquery::Datatransfer::V1::CheckValidCredsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:check_valid_creds, mock_method)

      # Mock auth layer
      mock_credentials = MockDataTransferServiceCredentials.new("check_valid_creds")

      Google::Cloud::Bigquery::Datatransfer::V1::DataTransferService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigquery::Datatransfer::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigquery::Datatransfer.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.check_valid_creds(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end