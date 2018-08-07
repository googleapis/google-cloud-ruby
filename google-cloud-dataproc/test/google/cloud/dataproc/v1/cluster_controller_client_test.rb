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

require "google/cloud/dataproc"
require "google/cloud/dataproc/v1/cluster_controller_client"
require "google/cloud/dataproc/v1/clusters_services_pb"
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

class MockClusterControllerCredentials < Google::Cloud::Dataproc::V1::Credentials
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

describe Google::Cloud::Dataproc::V1::ClusterControllerClient do

  describe 'create_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#create_cluster."

    it 'invokes create_cluster without error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster = {}

      # Create expected grpc response
      project_id_2 = "projectId2939242356"
      cluster_name = "clusterName-1018081872"
      cluster_uuid = "clusterUuid-1017854240"
      expected_response = {
        project_id: project_id_2,
        cluster_name: cluster_name,
        cluster_uuid: cluster_uuid
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Cluster)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CreateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("create_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.create_cluster(
            project_id,
            region,
            cluster
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes create_cluster and returns an operation error.' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::ClusterControllerClient#create_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/create_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CreateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("create_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.create_cluster(
            project_id,
            region,
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
      project_id = ''
      region = ''
      cluster = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::CreateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("create_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.create_cluster(
              project_id,
              region,
              cluster
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#update_cluster."

    it 'invokes update_cluster without error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''
      cluster = {}
      update_mask = {}

      # Create expected grpc response
      project_id_2 = "projectId2939242356"
      cluster_name_2 = "clusterName2875867491"
      cluster_uuid = "clusterUuid-1017854240"
      expected_response = {
        project_id: project_id_2,
        cluster_name: cluster_name_2,
        cluster_uuid: cluster_uuid
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Cluster)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("update_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.update_cluster(
            project_id,
            region,
            cluster_name,
            cluster,
            update_mask
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes update_cluster and returns an operation error.' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''
      cluster = {}
      update_mask = {}

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::ClusterControllerClient#update_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/update_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("update_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.update_cluster(
            project_id,
            region,
            cluster_name,
            cluster,
            update_mask
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes update_cluster with error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''
      cluster = {}
      update_mask = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::UpdateClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        assert_equal(Google::Gax::to_proto(cluster, Google::Cloud::Dataproc::V1::Cluster), request.cluster)
        assert_equal(Google::Gax::to_proto(update_mask, Google::Protobuf::FieldMask), request.update_mask)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("update_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.update_cluster(
              project_id,
              region,
              cluster_name,
              cluster,
              update_mask
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#delete_cluster."

    it 'invokes delete_cluster without error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("delete_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.delete_cluster(
            project_id,
            region,
            cluster_name
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes delete_cluster and returns an operation error.' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::ClusterControllerClient#delete_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/delete_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("delete_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.delete_cluster(
            project_id,
            region,
            cluster_name
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes delete_cluster with error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DeleteClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("delete_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.delete_cluster(
              project_id,
              region,
              cluster_name
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#get_cluster."

    it 'invokes get_cluster without error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Create expected grpc response
      project_id_2 = "projectId2939242356"
      cluster_name_2 = "clusterName2875867491"
      cluster_uuid = "clusterUuid-1017854240"
      expected_response = {
        project_id: project_id_2,
        cluster_name: cluster_name_2,
        cluster_uuid: cluster_uuid
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::Cluster)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("get_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.get_cluster(
            project_id,
            region,
            cluster_name
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_cluster(
            project_id,
            region,
            cluster_name
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_cluster with error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::GetClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("get_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.get_cluster(
              project_id,
              region,
              cluster_name
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_clusters' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#list_clusters."

    it 'invokes list_clusters without error' do
      # Create request parameters
      project_id = ''
      region = ''

      # Create expected grpc response
      next_page_token = ""
      clusters_element = {}
      clusters = [clusters_element]
      expected_response = { next_page_token: next_page_token, clusters: clusters }
      expected_response = Google::Gax::to_proto(expected_response, Google::Cloud::Dataproc::V1::ListClustersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListClustersRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("list_clusters")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.list_clusters(project_id, region)

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.clusters.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_clusters with error' do
      # Create request parameters
      project_id = ''
      region = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::ListClustersRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("list_clusters")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.list_clusters(project_id, region)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'diagnose_cluster' do
    custom_error = CustomTestError.new "Custom test error for Google::Cloud::Dataproc::V1::ClusterControllerClient#diagnose_cluster."

    it 'invokes diagnose_cluster without error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Protobuf::Empty)
      result = Google::Protobuf::Any.new
      result.pack(expected_response)
      operation = Google::Longrunning::Operation.new(
        name: 'operations/diagnose_cluster_test',
        done: true,
        response: result
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DiagnoseClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:diagnose_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("diagnose_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.diagnose_cluster(
            project_id,
            region,
            cluster_name
          )

          # Verify the response
          assert_equal(expected_response, response.response)
        end
      end
    end

    it 'invokes diagnose_cluster and returns an operation error.' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Create expected grpc response
      operation_error = Google::Rpc::Status.new(
        message: 'Operation error for Google::Cloud::Dataproc::V1::ClusterControllerClient#diagnose_cluster.'
      )
      operation = Google::Longrunning::Operation.new(
        name: 'operations/diagnose_cluster_test',
        done: true,
        error: operation_error
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DiagnoseClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        OpenStruct.new(execute: operation)
      end
      mock_stub = MockGrpcClientStub.new(:diagnose_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("diagnose_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          response = client.diagnose_cluster(
            project_id,
            region,
            cluster_name
          )

          # Verify the response
          assert(response.error?)
          assert_equal(operation_error, response.error)
        end
      end
    end

    it 'invokes diagnose_cluster with error' do
      # Create request parameters
      project_id = ''
      region = ''
      cluster_name = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Cloud::Dataproc::V1::DiagnoseClusterRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(region, request.region)
        assert_equal(cluster_name, request.cluster_name)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub.new(:diagnose_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterControllerCredentials.new("diagnose_cluster")

      Google::Cloud::Dataproc::V1::ClusterController::Stub.stub(:new, mock_stub) do
        Google::Cloud::Dataproc::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Dataproc::ClusterController.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError do
            client.diagnose_cluster(
              project_id,
              region,
              cluster_name
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end