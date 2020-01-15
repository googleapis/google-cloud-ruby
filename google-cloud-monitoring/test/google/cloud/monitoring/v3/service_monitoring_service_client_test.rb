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

require "google/cloud/monitoring"
require "google/cloud/monitoring/v3/service_monitoring_service_client"
require "google/monitoring/v3/service_service_services_pb"

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

class MockServiceMonitoringServiceCredentials_v3 < Google::Cloud::Monitoring::V3::Credentials
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

describe Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient do

  describe 'create_service' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#create_service."

    it 'invokes create_service without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")
      service = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Service)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateServiceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(service, Google::Monitoring::V3::Service), request.service)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("create_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.create_service(formatted_parent, service)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_service(formatted_parent, service) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_service with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")
      service = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateServiceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(service, Google::Monitoring::V3::Service), request.service)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("create_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.create_service(formatted_parent, service)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_service' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#get_service."

    it 'invokes get_service without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Service)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetServiceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("get_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.get_service(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_service(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_service with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetServiceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("get_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.get_service(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_services' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#list_services."

    it 'invokes list_services without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      services_element = {}
      services = [services_element]
      expected_response = { next_page_token: next_page_token, services: services }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListServicesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListServicesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_services, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("list_services")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.list_services(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.services.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_services with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListServicesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_services, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("list_services")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.list_services(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_service' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#update_service."

    it 'invokes update_service without error' do
      # Create request parameters
      service = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::Service)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateServiceRequest, request)
        assert_equal(Google::Gax::to_proto(service, Google::Monitoring::V3::Service), request.service)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("update_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.update_service(service)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_service(service) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_service with error' do
      # Create request parameters
      service = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateServiceRequest, request)
        assert_equal(Google::Gax::to_proto(service, Google::Monitoring::V3::Service), request.service)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("update_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.update_service(service)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_service' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#delete_service."

    it 'invokes delete_service without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteServiceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("delete_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.delete_service(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_service(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_service with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteServiceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_service, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("delete_service")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.delete_service(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_service_level_objective' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#create_service_level_objective."

    it 'invokes create_service_level_objective without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
      service_level_objective = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      goal = 317825.0
      expected_response = {
        name: name,
        display_name: display_name,
        goal: goal
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ServiceLevelObjective)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateServiceLevelObjectiveRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(service_level_objective, Google::Monitoring::V3::ServiceLevelObjective), request.service_level_objective)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("create_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.create_service_level_objective(formatted_parent, service_level_objective)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_service_level_objective(formatted_parent, service_level_objective) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_service_level_objective with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")
      service_level_objective = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::CreateServiceLevelObjectiveRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(Google::Gax::to_proto(service_level_objective, Google::Monitoring::V3::ServiceLevelObjective), request.service_level_objective)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:create_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("create_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.create_service_level_objective(formatted_parent, service_level_objective)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_service_level_objective' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#get_service_level_objective."

    it 'invokes get_service_level_objective without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      goal = 317825.0
      expected_response = {
        name: name_2,
        display_name: display_name,
        goal: goal
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ServiceLevelObjective)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetServiceLevelObjectiveRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("get_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.get_service_level_objective(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_service_level_objective(formatted_name) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_service_level_objective with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::GetServiceLevelObjectiveRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:get_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("get_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.get_service_level_objective(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_service_level_objectives' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#list_service_level_objectives."

    it 'invokes list_service_level_objectives without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Create expected grpc response
      next_page_token = ""
      service_level_objectives_element = {}
      service_level_objectives = [service_level_objectives_element]
      expected_response = { next_page_token: next_page_token, service_level_objectives: service_level_objectives }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ListServiceLevelObjectivesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListServiceLevelObjectivesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_service_level_objectives, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("list_service_level_objectives")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.list_service_level_objectives(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.service_level_objectives.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_service_level_objectives with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_path("[PROJECT]", "[SERVICE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::ListServiceLevelObjectivesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:list_service_level_objectives, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("list_service_level_objectives")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.list_service_level_objectives(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_service_level_objective' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#update_service_level_objective."

    it 'invokes update_service_level_objective without error' do
      # Create request parameters
      service_level_objective = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      goal = 317825.0
      expected_response = {
        name: name,
        display_name: display_name,
        goal: goal
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Monitoring::V3::ServiceLevelObjective)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateServiceLevelObjectiveRequest, request)
        assert_equal(Google::Gax::to_proto(service_level_objective, Google::Monitoring::V3::ServiceLevelObjective), request.service_level_objective)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("update_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.update_service_level_objective(service_level_objective)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_service_level_objective(service_level_objective) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_service_level_objective with error' do
      # Create request parameters
      service_level_objective = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::UpdateServiceLevelObjectiveRequest, request)
        assert_equal(Google::Gax::to_proto(service_level_objective, Google::Monitoring::V3::ServiceLevelObjective), request.service_level_objective)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:update_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("update_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.update_service_level_objective(service_level_objective)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_service_level_objective' do
    custom_error = CustomTestError_v3.new "Custom test error for Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient#delete_service_level_objective."

    it 'invokes delete_service_level_objective without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteServiceLevelObjectiveRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("delete_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          response = client.delete_service_level_objective(formatted_name)

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.delete_service_level_objective(formatted_name) do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_service_level_objective with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Monitoring::V3::ServiceMonitoringServiceClient.service_level_objective_path("[PROJECT]", "[SERVICE]", "[SERVICE_LEVEL_OBJECTIVE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Monitoring::V3::DeleteServiceLevelObjectiveRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v3.new(:delete_service_level_objective, mock_method)

      # Mock auth layer
      mock_credentials = MockServiceMonitoringServiceCredentials_v3.new("delete_service_level_objective")

      Google::Monitoring::V3::ServiceMonitoringService::Stub.stub(:new, mock_stub) do
        Google::Cloud::Monitoring::V3::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Monitoring::ServiceMonitoring.new(version: :v3)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v3 do
            client.delete_service_level_objective(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end