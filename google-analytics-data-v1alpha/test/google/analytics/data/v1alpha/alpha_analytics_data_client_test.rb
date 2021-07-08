# Copyright 2020 Google LLC
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

require "google/analytics/data/v1alpha"
require "google/analytics/data/v1alpha/alpha_analytics_data_client"
require "google/analytics/data/v1alpha/analytics_data_api_services_pb"

class CustomTestError_v1alpha < StandardError; end

# Mock for the GRPC::ClientStub class.
class MockGrpcClientStub_v1alpha

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

class MockAlphaAnalyticsDataCredentials_v1alpha < Google::Analytics::Data::V1alpha::Credentials
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

describe Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient do

  describe 'run_report' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#run_report."

    it 'invokes run_report without error' do
      # Create expected grpc response
      row_count = 1340416618
      expected_response = { row_count: row_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::RunReportResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.run_report

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.run_report do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes run_report with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.run_report
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_pivot_report' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#run_pivot_report."

    it 'invokes run_pivot_report without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::RunPivotReportResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_pivot_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_pivot_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.run_pivot_report

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.run_pivot_report do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes run_pivot_report with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_pivot_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_pivot_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.run_pivot_report
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_run_reports' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#batch_run_reports."

    it 'invokes batch_run_reports without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::BatchRunReportsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:batch_run_reports, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("batch_run_reports")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.batch_run_reports

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_run_reports do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_run_reports with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:batch_run_reports, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("batch_run_reports")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.batch_run_reports
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'batch_run_pivot_reports' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#batch_run_pivot_reports."

    it 'invokes batch_run_pivot_reports without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::BatchRunPivotReportsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:batch_run_pivot_reports, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("batch_run_pivot_reports")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.batch_run_pivot_reports

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.batch_run_pivot_reports do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes batch_run_pivot_reports with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:batch_run_pivot_reports, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("batch_run_pivot_reports")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.batch_run_pivot_reports
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_metadata' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#get_metadata."

    it 'invokes get_metadata without error' do
      # Create request parameters
      formatted_name = Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient.metadata_path("[PROPERTY]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      expected_response = { name: name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::Metadata)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Analytics::Data::V1alpha::GetMetadataRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:get_metadata, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("get_metadata")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.get_metadata(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_metadata(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_metadata with error' do
      # Create request parameters
      formatted_name = Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient.metadata_path("[PROPERTY]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Analytics::Data::V1alpha::GetMetadataRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:get_metadata, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("get_metadata")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.get_metadata(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'run_realtime_report' do
    custom_error = CustomTestError_v1alpha.new "Custom test error for Google::Analytics::Data::V1alpha::AlphaAnalyticsDataClient#run_realtime_report."

    it 'invokes run_realtime_report without error' do
      # Create expected grpc response
      row_count = 1340416618
      expected_response = { row_count: row_count }
      expected_response = Google::Gax::to_proto(expected_response, Google::Analytics::Data::V1alpha::RunRealtimeReportResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_realtime_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_realtime_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          response = client.run_realtime_report

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.run_realtime_report do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes run_realtime_report with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1alpha.new(:run_realtime_report, mock_method)

      # Mock auth layer
      mock_credentials = MockAlphaAnalyticsDataCredentials_v1alpha.new("run_realtime_report")

      Google::Analytics::Data::V1alpha::AlphaAnalyticsData::Stub.stub(:new, mock_stub) do
        Google::Analytics::Data::V1alpha::Credentials.stub(:default, mock_credentials) do
          client = Google::Analytics::Data::V1alpha.new

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1alpha do
            client.run_realtime_report
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end