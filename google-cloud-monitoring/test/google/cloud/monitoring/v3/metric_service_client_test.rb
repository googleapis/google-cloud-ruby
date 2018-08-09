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
require "google/cloud/monitoring/v3/metric_service_client"
require "google/monitoring/v3/metric_service_services_pb"

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

class MockMetricServiceCredentials < Google::Cloud::Monitoring::V3::Credentials
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

describe Google::Cloud::Monitoring::V3::MetricServiceClient do

  describe 'list_monitored_resource_descriptors' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#list_monitored_resource_descriptors."

    it 'invokes list_monitored_resource_descriptors without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      resource_descriptors_element = {}
      resource_descriptors = [resource_descriptors_element]
      expected_response = { next_page_token: next_page_token, resource_descriptors: resource_descriptors }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListMonitoredResourceDescriptorsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListMonitoredResourceDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_monitored_resource_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_monitored_resource_descriptors")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.list_monitored_resource_descriptors(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.resource_descriptors.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_monitored_resource_descriptors with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListMonitoredResourceDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_monitored_resource_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_monitored_resource_descriptors")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_monitored_resource_descriptors(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_monitored_resource_descriptor' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#get_monitored_resource_descriptor."

    it 'invokes get_monitored_resource_descriptor without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.monitored_resource_descriptor_path("[PROJECT]", "[MONITORED_RESOURCE_DESCRIPTOR]")

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
      expected_response = Google::Gax::to_proto(expected_response, Google::Api::MonitoredResourceDescriptor)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetMonitoredResourceDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_monitored_resource_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("get_monitored_resource_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.get_monitored_resource_descriptor(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_monitored_resource_descriptor(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_monitored_resource_descriptor with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.monitored_resource_descriptor_path("[PROJECT]", "[MONITORED_RESOURCE_DESCRIPTOR]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetMonitoredResourceDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_monitored_resource_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("get_monitored_resource_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_monitored_resource_descriptor(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_metric_descriptors' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#list_metric_descriptors."

    it 'invokes list_metric_descriptors without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      metric_descriptors_element = {}
      metric_descriptors = [metric_descriptors_element]
      expected_response = { next_page_token: next_page_token, metric_descriptors: metric_descriptors }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListMetricDescriptorsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListMetricDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_metric_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_metric_descriptors")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.list_metric_descriptors(formatted_name)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.metric_descriptors.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_metric_descriptors with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListMetricDescriptorsRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_metric_descriptors, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_metric_descriptors")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_metric_descriptors(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_metric_descriptor' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#get_metric_descriptor."

    it 'invokes get_metric_descriptor without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      type = "type3575610"
      unit = "unit3594628"
      description = "description-1724546052"
      display_name = "displayName1615086568"
      expected_response = {
        name: name_2,
        type: type,
        unit: unit,
        description: description,
        display_name: display_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Api::MetricDescriptor)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("get_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.get_metric_descriptor(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_metric_descriptor(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_metric_descriptor with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("get_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_metric_descriptor(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_metric_descriptor' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#create_metric_descriptor."

    it 'invokes create_metric_descriptor without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      metric_descriptor = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      type = "type3575610"
      unit = "unit3594628"
      description = "description-1724546052"
      display_name = "displayName1615086568"
      expected_response = {
        name: name_2,
        type: type,
        unit: unit,
        description: description,
        display_name: display_name
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Api::MetricDescriptor)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(metric_descriptor, Google::Api::MetricDescriptor), request.metric_descriptor)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("create_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.create_metric_descriptor(formatted_name, metric_descriptor)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_metric_descriptor(formatted_name, metric_descriptor) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_metric_descriptor with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      metric_descriptor = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(Google::Gax::to_proto(metric_descriptor, Google::Api::MetricDescriptor), request.metric_descriptor)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("create_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_metric_descriptor(formatted_name, metric_descriptor)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_metric_descriptor' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#delete_metric_descriptor."

    it 'invokes delete_metric_descriptor without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("delete_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.delete_metric_descriptor(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_metric_descriptor(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_metric_descriptor with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.metric_descriptor_path("[PROJECT]", "[METRIC_DESCRIPTOR]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteMetricDescriptorRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_metric_descriptor, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("delete_metric_descriptor")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_metric_descriptor(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_time_series' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#list_time_series."

    it 'invokes list_time_series without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      filter = ''
      interval = {}
      view = :FULL

      # Create expected grpc response
      next_page_token = ""
      time_series_element = {}
      time_series = [time_series_element]
      expected_response = { next_page_token: next_page_token, time_series: time_series }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListTimeSeriesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListTimeSeriesRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(filter, request.filter)
        assert_equal(Google::Gax::to_proto(interval, Google::Monitoring::V3::TimeInterval), request.interval)
        assert_equal(view, request.view)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_time_series, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_time_series")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.list_time_series(
            formatted_name,
            filter,
            interval,
            view
          )

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.time_series.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_time_series with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      filter = ''
      interval = {}
      view = :FULL

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListTimeSeriesRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(filter, request.filter)
        assert_equal(Google::Gax::to_proto(interval, Google::Monitoring::V3::TimeInterval), request.interval)
        assert_equal(view, request.view)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_time_series, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("list_time_series")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_time_series(
              formatted_name,
              filter,
              interval,
              view
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_time_series' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Monitoring::V3::MetricServiceClient#create_time_series."

    it 'invokes create_time_series without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      time_series = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateTimeSeriesRequest, request)
        assert_equal(formatted_name, request.name)
        time_series = time_series.map do |req|
          Google::Gax::to_proto(req, Google::Monitoring::V3::TimeSeries)
        end
        assert_equal(time_series, request.time_series)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:create_time_series, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("create_time_series")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          response = client.create_time_series(formatted_name, time_series)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.create_time_series(formatted_name, time_series) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_time_series with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path("[PROJECT]")
      time_series = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateTimeSeriesRequest, request)
        assert_equal(formatted_name, request.name)
        time_series = time_series.map do |req|
          Google::Gax::to_proto(req, Google::Monitoring::V3::TimeSeries)
        end
        assert_equal(time_series, request.time_series)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_time_series, mock_method)

      # Mock auth layer
      mock_credentials = MockMetricServiceCredentials.new("create_time_series")

      Google::Monitoring::V3::MetricService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Metric.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_time_series(formatted_name, time_series)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end