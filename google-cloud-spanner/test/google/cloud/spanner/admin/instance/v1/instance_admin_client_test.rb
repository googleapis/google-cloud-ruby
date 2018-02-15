# Copyright 2017 Google LLC
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

require "google/cloud/spanner/admin/instance"
require "google/cloud/spanner/admin/instance/v1/instance_admin_client"
require "google/spanner/admin/instance/v1/spanner_instance_admin_services_pb"
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

class MockInstanceAdminCredentials < Google::Cloud::Spanner::Admin::Instance::Credentials
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

describe Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient do

  describe 'list_instance_configs' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#list_instance_configs."

    it 'invokes list_instance_configs without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      instance_configs_element = {}
      instance_configs = [instance_configs_element]
      expected_response = { next_page_token: next_page_token, instance_configs: instance_configs }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::ListInstanceConfigsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::ListInstanceConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_instance_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("list_instance_configs")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.list_instance_configs(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.instance_configs.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_instance_configs with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::ListInstanceConfigsRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_instance_configs, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("list_instance_configs")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_instance_configs(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_instance_config' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#get_instance_config."

    it 'invokes get_instance_config without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_config_path("[PROJECT]", "[INSTANCE_CONFIG]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::InstanceConfig)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::GetInstanceConfigRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_instance_config, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_instance_config")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.get_instance_config(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_instance_config with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_config_path("[PROJECT]", "[INSTANCE_CONFIG]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::GetInstanceConfigRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_instance_config, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_instance_config")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_instance_config(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_instances' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#list_instances."

    it 'invokes list_instances without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = ""
      instances_element = {}
      instances = [instances_element]
      expected_response = { next_page_token: next_page_token, instances: instances }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::ListInstancesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("list_instances")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("list_instances")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#get_instance."

    it 'invokes get_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      config = "config-1354792126"
      display_name = "displayName1615086568"
      node_count = 1539922066
      expected_response = {
        name: name_2,
        config: config,
        display_name: display_name,
        node_count: node_count
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.get_instance(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#create_instance."

    it 'invokes create_instance without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}

      # Create expected grpc response
      name = "name3373707"
      config = "config-1354792126"
      display_name = "displayName1615086568"
      node_count = 1539922066
      expected_response = {
        name: name,
        config: config,
        display_name: display_name,
        node_count: node_count
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::Instance)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("create_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#create_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("create_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
      formatted_parent = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("create_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#update_instance."

    it 'invokes update_instance without error' do
      # Create request parameters
      instance = {}
      field_mask = {}

      # Create expected grpc response
      name = "name3373707"
      config = "config-1354792126"
      display_name = "displayName1615086568"
      node_count = 1539922066
      expected_response = {
        name: name,
        config: config,
        display_name: display_name,
        node_count: node_count
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Spanner::Admin::Instance::V1::Instance)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        assert_equal(Google::Gax::to_proto(field_mask, Google::Protobuf::FieldMask), request.field_mask)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("update_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.update_instance(instance, field_mask)

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes update_instance and returns an operation error.' do
      # Create request parameters
      instance = {}
      field_mask = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#update_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        assert_equal(Google::Gax::to_proto(field_mask, Google::Protobuf::FieldMask), request.field_mask)
        operation
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("update_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.update_instance(instance, field_mask)

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes update_instance with error' do
      # Create request parameters
      instance = {}
      field_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::UpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(instance, Google::Spanner::Admin::Instance::V1::Instance), request.instance)
        assert_equal(Google::Gax::to_proto(field_mask, Google::Protobuf::FieldMask), request.field_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("update_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_instance(instance, field_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#delete_instance."

    it 'invokes delete_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        nil
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("delete_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.delete_instance(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Spanner::Admin::Instance::V1::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("delete_instance")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

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

  describe 'set_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      policy = {}

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("set_iam_policy")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.set_iam_policy(formatted_resource, policy)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::SetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(Google::Gax::to_proto(policy, Google::Iam::V1::Policy), request.policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("set_iam_policy")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.set_iam_policy(formatted_resource, policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_iam_policy")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.get_iam_policy(formatted_resource)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("get_iam_policy")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_iam_policy(formatted_resource)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'test_iam_permissions' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        expected_response
      end
      mock_stub = MockGrpcClientStub.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("test_iam_permissions")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          response = client.test_iam_permissions(formatted_resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Spanner::Admin::Instance::V1::InstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      permissions = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockInstanceAdminCredentials.new("test_iam_permissions")

      Google::Spanner::Admin::Instance::V1::InstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Spanner::Admin::Instance::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Spanner::Admin::Instance.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.test_iam_permissions(formatted_resource, permissions)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end