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
require "ostruct"

require "google/cloud/redis"
require "google/cloud/redis/v1beta1/cloud_redis_client"
require "google/cloud/redis/v1beta1/cloud_redis_services_pb"
require "google/longrunning/operations_pb"

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

class MockCloudRedisCredentials < Google::Cloud::Redis::Credentials
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

describe Google::Cloud::Redis::V1beta1::CloudRedisClient do

  describe 'list_instances' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Redis::V1beta1::CloudRedisClient#list_instances."

    it 'invokes list_instances without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")

      # Create expected grpc response
      next_page_token = ""
      instances_element = {}
      instances = [instances_element]
      expected_response = { next_page_token: next_page_token, instances: instances }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Redis::V1beta1::ListInstancesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new execute: expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("list_instances")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.list_instances(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.instances.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_instances with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("list_instances")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_instances(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Redis::V1beta1::CloudRedisClient#get_instance."

    it 'invokes get_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      location_id = "locationId552319461"
      alternative_location_id = "alternativeLocationId-718920621"
      redis_version = "redisVersion-685310444"
      reserved_ip_range = "reservedIpRange-1082940580"
      host = "host3208616"
      port = 3446913
      current_location_id = "currentLocationId1312712735"
      status_message = "statusMessage-239442758"
      memory_size_gb = 34199707
      authorized_network = "authorizedNetwork-1733809270"
      expected_response = {
        name: name_2,
        display_name: display_name,
        location_id: location_id,
        alternative_location_id: alternative_location_id,
        redis_version: redis_version,
        reserved_ip_range: reserved_ip_range,
        host: host,
        port: port,
        current_location_id: current_location_id,
        status_message: status_message,
        memory_size_gb: memory_size_gb,
        authorized_network: authorized_network
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Redis::V1beta1::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new execute: expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("get_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.get_instance(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("get_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_instance(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Redis::V1beta1::CloudRedisClient#create_instance."

    it 'invokes create_instance without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")
      instance_id = "test_instance"
      tier = :BASIC
      memory_size_gb = 1
      instance = { tier: tier, memory_size_gb: memory_size_gb }

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      location_id = "locationId552319461"
      alternative_location_id = "alternativeLocationId-718920621"
      redis_version = "redisVersion-685310444"
      reserved_ip_range = "reservedIpRange-1082940580"
      host = "host3208616"
      port = 3446913
      current_location_id = "currentLocationId1312712735"
      status_message = "statusMessage-239442758"
      memory_size_gb_2 = 1493816946
      authorized_network = "authorizedNetwork-1733809270"
      expected_response = {
        name: name,
        display_name: display_name,
        location_id: location_id,
        alternative_location_id: alternative_location_id,
        redis_version: redis_version,
        reserved_ip_range: reserved_ip_range,
        host: host,
        port: port,
        current_location_id: current_location_id,
        status_message: status_message,
        memory_size_gb: memory_size_gb_2,
        authorized_network: authorized_network
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Redis::V1beta1::Instance)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("create_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.create_instance(
            formatted_parent,
            instance_id,
            instance
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_instance and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")
      instance_id = "test_instance"
      tier = :BASIC
      memory_size_gb = 1
      instance = { tier: tier, memory_size_gb: memory_size_gb }

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Redis::V1beta1::CloudRedisClient#create_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("create_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.create_instance(
            formatted_parent,
            instance_id,
            instance
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_instance with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Redis::V1beta1::CloudRedisClient.location_path("[PROJECT]", "[LOCATION]")
      instance_id = "test_instance"
      tier = :BASIC
      memory_size_gb = 1
      instance = { tier: tier, memory_size_gb: memory_size_gb }

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("create_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_instance(
              formatted_parent,
              instance_id,
              instance
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Redis::V1beta1::CloudRedisClient#update_instance."

    it 'invokes update_instance without error' do
      # Create request parameters
      paths_element = "display_name"
      paths_element_2 = "memory_size_gb"
      paths = [paths_element, paths_element_2]
      update_mask = { paths: paths }
      display_name = "UpdatedDisplayName"
      memory_size_gb = 4
      instance = { display_name: display_name, memory_size_gb: memory_size_gb }

      # Create expected grpc response
      name = "name3373707"
      display_name_2 = "displayName21615000987"
      location_id = "locationId552319461"
      alternative_location_id = "alternativeLocationId-718920621"
      redis_version = "redisVersion-685310444"
      reserved_ip_range = "reservedIpRange-1082940580"
      host = "host3208616"
      port = 3446913
      current_location_id = "currentLocationId1312712735"
      status_message = "statusMessage-239442758"
      memory_size_gb_2 = 1493816946
      authorized_network = "authorizedNetwork-1733809270"
      expected_response = {
        name: name,
        display_name: display_name_2,
        location_id: location_id,
        alternative_location_id: alternative_location_id,
        redis_version: redis_version,
        reserved_ip_range: reserved_ip_range,
        host: host,
        port: port,
        current_location_id: current_location_id,
        status_message: status_message,
        memory_size_gb: memory_size_gb_2,
        authorized_network: authorized_network
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Redis::V1beta1::Instance)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("update_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.update_instance(update_mask, instance)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes update_instance and returns an operation error.' do
      # Create request parameters
      paths_element = "display_name"
      paths_element_2 = "memory_size_gb"
      paths = [paths_element, paths_element_2]
      update_mask = { paths: paths }
      display_name = "UpdatedDisplayName"
      memory_size_gb = 4
      instance = { display_name: display_name, memory_size_gb: memory_size_gb }

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Redis::V1beta1::CloudRedisClient#update_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("update_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.update_instance(update_mask, instance)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes update_instance with error' do
      # Create request parameters
      paths_element = "display_name"
      paths_element_2 = "memory_size_gb"
      paths = [paths_element, paths_element_2]
      update_mask = { paths: paths }
      display_name = "UpdatedDisplayName"
      memory_size_gb = 4
      instance = { display_name: display_name, memory_size_gb: memory_size_gb }

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        assert_equal(Google::Gax::to_proto(instance, Google::Cloud::Redis::V1beta1::Instance), request.instance)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("update_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_instance(update_mask, instance)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Redis::V1beta1::CloudRedisClient#delete_instance."

    it 'invokes delete_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("delete_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.delete_instance(formatted_name)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes delete_instance and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Redis::V1beta1::CloudRedisClient#delete_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new execute: operation
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("delete_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          response = client.delete_instance(formatted_name)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes delete_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Redis::V1beta1::CloudRedisClient.instance_path("[PROJECT]", "[LOCATION]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Redis::V1beta1::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockCloudRedisCredentials.new("delete_instance")

      Google::Cloud::Redis::V1beta1::CloudRedis::Stub.stub(:new, mock_stub) do
        Google::Cloud::Redis::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Redis.new(version: :v1beta1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_instance(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end
