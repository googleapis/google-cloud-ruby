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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/gax"

require "google/cloud/monitoring/dashboard"
require "google/cloud/monitoring/dashboard/v1/dashboards_service_client"
require "google/monitoring/dashboard/v1/dashboards_service_services_pb"

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

class MockDashboardsServiceCredentials_v1 < Google::Cloud::Monitoring::Dashboard::V1::Credentials
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

describe Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient do

  describe 'create_dashboard' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient#create_dashboard."

    it 'invokes create_dashboard without error' do
      # Create request parameters
      parent = ''
      dashboard = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      expected_response = {
        name: name,
        display_name: display_name,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::Dashboard::V1::Dashboard)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::CreateDashboardRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(Google::Gax::to_proto(dashboard, Google::Monitoring::Dashboard::V1::Dashboard), request.dashboard)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("create_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          response = client.create_dashboard(parent, dashboard)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_dashboard(parent, dashboard) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_dashboard with error' do
      # Create request parameters
      parent = ''
      dashboard = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::CreateDashboardRequest, request)
        assert_equal(parent, request.parent)
        assert_equal(Google::Gax::to_proto(dashboard, Google::Monitoring::Dashboard::V1::Dashboard), request.dashboard)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("create_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_dashboard(parent, dashboard)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_dashboards' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient#list_dashboards."

    it 'invokes list_dashboards without error' do
      # Create request parameters
      parent = ''

      # Create expected grpc response
      next_page_token = ""
      dashboards_element = {}
      dashboards = [dashboards_element]
      expected_response = { next_page_token: next_page_token, dashboards: dashboards }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::Dashboard::V1::ListDashboardsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::ListDashboardsRequest, request)
        assert_equal(parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_dashboards, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("list_dashboards")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          response = client.list_dashboards(parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.dashboards.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_dashboards with error' do
      # Create request parameters
      parent = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::ListDashboardsRequest, request)
        assert_equal(parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_dashboards, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("list_dashboards")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_dashboards(parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_dashboard' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient#get_dashboard."

    it 'invokes get_dashboard without error' do
      # Create request parameters
      name = ''

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      expected_response = {
        name: name_2,
        display_name: display_name,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::Dashboard::V1::Dashboard)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::GetDashboardRequest, request)
        assert_equal(name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("get_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          response = client.get_dashboard(name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_dashboard(name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_dashboard with error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::GetDashboardRequest, request)
        assert_equal(name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("get_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_dashboard(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_dashboard' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient#delete_dashboard."

    it 'invokes delete_dashboard without error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::DeleteDashboardRequest, request)
        assert_equal(name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("delete_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          response = client.delete_dashboard(name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_dashboard(name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_dashboard with error' do
      # Create request parameters
      name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::DeleteDashboardRequest, request)
        assert_equal(name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("delete_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_dashboard(name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_dashboard' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Monitoring::Dashboard::V1::DashboardsServiceClient#update_dashboard."

    it 'invokes update_dashboard without error' do
      # Create request parameters
      dashboard = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      etag = "etag3123477"
      expected_response = {
        name: name,
        display_name: display_name,
        etag: etag
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::Dashboard::V1::Dashboard)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::UpdateDashboardRequest, request)
        assert_equal(Google::Gax::to_proto(dashboard, Google::Monitoring::Dashboard::V1::Dashboard), request.dashboard)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("update_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          response = client.update_dashboard(dashboard)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_dashboard(dashboard) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_dashboard with error' do
      # Create request parameters
      dashboard = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::Dashboard::V1::UpdateDashboardRequest, request)
        assert_equal(Google::Gax::to_proto(dashboard, Google::Monitoring::Dashboard::V1::Dashboard), request.dashboard)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_dashboard, mock_method)

      # Mock auth layer
      mock_credentials = MockDashboardsServiceCredentials_v1.new("update_dashboard")

      Google::Monitoring::Dashboard::V1::DashboardsService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::Dashboard::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::Dashboard.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_dashboard(dashboard)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end