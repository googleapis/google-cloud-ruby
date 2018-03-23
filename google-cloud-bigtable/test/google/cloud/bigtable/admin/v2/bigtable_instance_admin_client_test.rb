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

require "google/cloud/bigtable/admin"
require "google/cloud/bigtable/admin/v2/bigtable_instance_admin_client"
require "google/bigtable/admin/v2/bigtable_instance_admin_services_pb"
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

class MockBigtableInstanceAdminCredentials < Google::Cloud::Bigtable::Admin::Credentials
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

describe Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient do

  describe 'create_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#create_instance."

    it 'invokes create_instance without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}
      clusters = {}

      # Create expected grpc response
      name = "name3373707"
      display_name = "displayName1615086568"
      expected_response = { name: name, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Instance)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Bigtable::Admin::V2::Instance), request.instance)
        assert_equal(clusters, request.clusters)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.create_instance(
            formatted_parent,
            instance_id,
            instance,
            clusters
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_instance and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}
      clusters = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#create_instance.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_instance_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Bigtable::Admin::V2::Instance), request.instance)
        assert_equal(clusters, request.clusters)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.create_instance(
            formatted_parent,
            instance_id,
            instance,
            clusters
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_instance with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")
      instance_id = ''
      instance = {}
      clusters = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateInstanceRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(instance_id, request.instance_id)
        assert_equal(Google::Gax::to_proto(instance, Google::Bigtable::Admin::V2::Instance), request.instance)
        assert_equal(clusters, request.clusters)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_instance(
              formatted_parent,
              instance_id,
              instance,
              clusters
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#get_instance."

    it 'invokes get_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name = "displayName1615086568"
      expected_response = { name: name_2, display_name: display_name }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.get_instance(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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

  describe 'list_instances' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#list_instances."

    it 'invokes list_instances without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")

      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListInstancesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_instances")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.list_instances(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes list_instances with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path("[PROJECT]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListInstancesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_instances, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_instances")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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

  describe 'update_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#update_instance."

    it 'invokes update_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      display_name = ''
      type = :TYPE_UNSPECIFIED
      labels = {}

      # Create expected grpc response
      name_2 = "name2-1052831874"
      display_name_2 = "displayName21615000987"
      expected_response = { name: name_2, display_name: display_name_2 }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Instance, request)
        assert_equal(formatted_name, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.update_instance(
            formatted_name,
            display_name,
            type,
            labels
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      display_name = ''
      type = :TYPE_UNSPECIFIED
      labels = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Instance, request)
        assert_equal(formatted_name, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_instance(
              formatted_name,
              display_name,
              type,
              labels
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'partial_update_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#partial_update_instance."

    it 'invokes partial_update_instance without error' do
      # Create request parameters
      instance = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      done = true
      expected_response = { name: name, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::PartialUpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(instance, Google::Bigtable::Admin::V2::Instance), request.instance)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:partial_update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("partial_update_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.partial_update_instance(instance, update_mask)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes partial_update_instance with error' do
      # Create request parameters
      instance = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::PartialUpdateInstanceRequest, request)
        assert_equal(Google::Gax::to_proto(instance, Google::Bigtable::Admin::V2::Instance), request.instance)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:partial_update_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("partial_update_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.partial_update_instance(instance, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_instance' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#delete_instance."

    it 'invokes delete_instance without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.delete_instance(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_instance with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_instance, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_instance")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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

  describe 'create_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#create_cluster."

    it 'invokes create_cluster without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      cluster_id = ''
      cluster = {}

      # Create expected grpc response
      name = "name3373707"
      location = "location1901043637"
      serve_nodes = 1288838783
      expected_response = {
        name: name,
        location: location,
        serve_nodes: serve_nodes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Cluster)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(cluster_id, request.cluster_id)
        assert_equal(Google::Gax::to_proto(cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.create_cluster(
            formatted_parent,
            cluster_id,
            cluster
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_cluster and returns an operation error.' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      cluster_id = ''
      cluster = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#create_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(cluster_id, request.cluster_id)
        assert_equal(Google::Gax::to_proto(cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.create_cluster(
            formatted_parent,
            cluster_id,
            cluster
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes create_cluster with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      cluster_id = ''
      cluster = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(cluster_id, request.cluster_id)
        assert_equal(Google::Gax::to_proto(cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_cluster(
              formatted_parent,
              cluster_id,
              cluster
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#get_cluster."

    it 'invokes get_cluster without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      location = "location1901043637"
      serve_nodes = 1288838783
      expected_response = {
        name: name_2,
        location: location,
        serve_nodes: serve_nodes
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Cluster)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.get_cluster(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_cluster with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_cluster(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_clusters' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#list_clusters."

    it 'invokes list_clusters without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListClustersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_clusters")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.list_clusters(formatted_parent)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes list_clusters with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_clusters")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_clusters(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#update_cluster."

    it 'invokes update_cluster without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      location = ''
      serve_nodes = 0

      # Create expected grpc response
      name_2 = "name2-1052831874"
      location_2 = "location21541837352"
      serve_nodes_2 = 1623486220
      expected_response = {
        name: name_2,
        location: location_2,
        serve_nodes: serve_nodes_2
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Cluster)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(formatted_name, request.name)
        assert_equal(location, request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.update_cluster(
            formatted_name,
            location,
            serve_nodes
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes update_cluster and returns an operation error.' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      location = ''
      serve_nodes = 0

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#update_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(formatted_name, request.name)
        assert_equal(location, request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.update_cluster(
            formatted_name,
            location,
            serve_nodes
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes update_cluster with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")
      location = ''
      serve_nodes = 0

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(formatted_name, request.name)
        assert_equal(location, request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_cluster(
              formatted_name,
              location,
              serve_nodes
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#delete_cluster."

    it 'invokes delete_cluster without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.delete_cluster(formatted_name)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_cluster with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path("[PROJECT]", "[INSTANCE]", "[CLUSTER]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_cluster")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_cluster(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_app_profile' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#create_app_profile."

    it 'invokes create_app_profile without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      app_profile_id = ''
      app_profile = {}

      # Create expected grpc response
      name = "name3373707"
      etag = "etag3123477"
      description = "description-1724546052"
      expected_response = {
        name: name,
        etag: etag,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::AppProfile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateAppProfileRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(app_profile_id, request.app_profile_id)
        assert_equal(Google::Gax::to_proto(app_profile, Google::Bigtable::Admin::V2::AppProfile), request.app_profile)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:create_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.create_app_profile(
            formatted_parent,
            app_profile_id,
            app_profile
          )

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes create_app_profile with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      app_profile_id = ''
      app_profile = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateAppProfileRequest, request)
        assert_equal(formatted_parent, request.parent)
        assert_equal(app_profile_id, request.app_profile_id)
        assert_equal(Google::Gax::to_proto(app_profile, Google::Bigtable::Admin::V2::AppProfile), request.app_profile)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("create_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_app_profile(
              formatted_parent,
              app_profile_id,
              app_profile
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_app_profile' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#get_app_profile."

    it 'invokes get_app_profile without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")

      # Create expected grpc response
      name_2 = "name2-1052831874"
      etag = "etag3123477"
      description = "description-1724546052"
      expected_response = {
        name: name_2,
        etag: etag,
        description: description
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::AppProfile)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetAppProfileRequest, request)
        assert_equal(formatted_name, request.name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.get_app_profile(formatted_name)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_app_profile with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetAppProfileRequest, request)
        assert_equal(formatted_name, request.name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_app_profile(formatted_name)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_app_profiles' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#list_app_profiles."

    it 'invokes list_app_profiles without error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      next_page_token = ""
      app_profiles_element = {}
      app_profiles = [app_profiles_element]
      expected_response = { next_page_token: next_page_token, app_profiles: app_profiles }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListAppProfilesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListAppProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_app_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_app_profiles")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.list_app_profiles(formatted_parent)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.app_profiles.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_app_profiles with error' do
      # Create request parameters
      formatted_parent = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListAppProfilesRequest, request)
        assert_equal(formatted_parent, request.parent)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_app_profiles, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("list_app_profiles")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_app_profiles(formatted_parent)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_app_profile' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#update_app_profile."

    it 'invokes update_app_profile without error' do
      # Create request parameters
      app_profile = {}
      update_mask = {}

      # Create expected grpc response
      name = "name3373707"
      done = true
      expected_response = { name: name, done: done }
      expected_response = Google::Gax::to_proto(expected_response, Google::Longrunning::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::UpdateAppProfileRequest, request)
        assert_equal(Google::Gax::to_proto(app_profile, Google::Bigtable::Admin::V2::AppProfile), request.app_profile)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:update_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.update_app_profile(app_profile, update_mask)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes update_app_profile with error' do
      # Create request parameters
      app_profile = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::UpdateAppProfileRequest, request)
        assert_equal(Google::Gax::to_proto(app_profile, Google::Bigtable::Admin::V2::AppProfile), request.app_profile)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("update_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_app_profile(app_profile, update_mask)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_app_profile' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#delete_app_profile."

    it 'invokes delete_app_profile without error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")
      ignore_warnings = false

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteAppProfileRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ignore_warnings, request.ignore_warnings)
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub.new(:delete_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.delete_app_profile(formatted_name, ignore_warnings)

          # Verify the response
          assert_nil(response)
        end
      end
    end

    it 'invokes delete_app_profile with error' do
      # Create request parameters
      formatted_name = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.app_profile_path("[PROJECT]", "[INSTANCE]", "[APP_PROFILE]")
      ignore_warnings = false

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteAppProfileRequest, request)
        assert_equal(formatted_name, request.name)
        assert_equal(ignore_warnings, request.ignore_warnings)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_app_profile, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("delete_app_profile")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_app_profile(formatted_name, ignore_warnings)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#get_iam_policy."

    it 'invokes get_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Create expected grpc response
      version = 351608024
      etag = "21"
      expected_response = { version: version, etag: etag }
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::Policy)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_iam_policy")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.get_iam_policy(formatted_resource)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes get_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::GetIamPolicyRequest, request)
        assert_equal(formatted_resource, request.resource)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("get_iam_policy")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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

  describe 'set_iam_policy' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#set_iam_policy."

    it 'invokes set_iam_policy without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
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
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:set_iam_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("set_iam_policy")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.set_iam_policy(formatted_resource, policy)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes set_iam_policy with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
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
      mock_credentials = MockBigtableInstanceAdminCredentials.new("set_iam_policy")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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

  describe 'test_iam_permissions' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient#test_iam_permissions."

    it 'invokes test_iam_permissions without error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
      permissions = []

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Iam::V1::TestIamPermissionsResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Iam::V1::TestIamPermissionsRequest, request)
        assert_equal(formatted_resource, request.resource)
        assert_equal(permissions, request.permissions)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:test_iam_permissions, mock_method)

      # Mock auth layer
      mock_credentials = MockBigtableInstanceAdminCredentials.new("test_iam_permissions")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

          # Call method
          response = client.test_iam_permissions(formatted_resource, permissions)

          # Verify the response
          assert_equal(expected_response, response)
        end
      end
    end

    it 'invokes test_iam_permissions with error' do
      # Create request parameters
      formatted_resource = Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path("[PROJECT]", "[INSTANCE]")
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
      mock_credentials = MockBigtableInstanceAdminCredentials.new("test_iam_permissions")

      Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
        Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Bigtable::Admin::BigtableInstanceAdmin.new(version: :v2)

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