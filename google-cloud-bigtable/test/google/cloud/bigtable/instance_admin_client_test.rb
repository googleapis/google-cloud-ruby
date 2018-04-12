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


require "test_helper"
require "google/cloud/bigtable/instance_admin_client"

class InstanceAdminTestError < StandardError
  def initialize(operation_name)
    super("Custom test error for Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient##{operation_name}.")
  end
end

def stub_instance_admin_grpc service_name, mock_method
  mock_stub = MockGrpcClientStub.new(service_name, mock_method)

  # Mock auth layer
  mock_credentials = MockBigtableAdminCredentials.new(service_name.to_s)

  Google::Bigtable::Admin::V2::BigtableInstanceAdmin::Stub.stub(:new, mock_stub) do
    Google::Cloud::Bigtable::Admin::Credentials.stub(:default, mock_credentials) do
      yield
    end
  end
end

describe Google::Cloud::Bigtable::InstanceAdminClient do
  let(:project_id) { "test-project-id" }
  let(:instance_id) { "test-instance-id" }
  let(:cluster_id) { "test-cluster-id" }
  let(:cluster_location) { "us-east-1a" }
  let(:client) { Google::Cloud::Bigtable::InstanceAdminClient.new(project_id) }
  let(:project_path){
    Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.project_path(
      project_id
    )
  }
  let(:instance_path) {
    Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.instance_path(
      project_id,
      instance_id
    )
  }
  let(:instance_attrs) {
    { name: instance_id, display_name: "my-test-instance" }
  }
  let(:cluster_attrs){
    { name: cluster_id, location: cluster_location, serve_nodes: 3 }
  }
  let(:cluster_path) {
    Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.cluster_path(
      project_id,
      instance_id,
      cluster_id
    )
  }
  let(:cluster_location_path){
    Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient.location_path(
      project_id,
      cluster_location
    )
  }

  describe "create_instance" do
    def assert_create_instance_request request, instance_attrs
      assert_instance_of(Google::Bigtable::Admin::V2::CreateInstanceRequest, request)
      assert_equal(project_path, request.parent)
      assert_equal(instance_id, request.instance_id)

      instance_pb = Google::Gax.to_proto(instance_attrs, Google::Bigtable::Admin::V2::Instance)
      assert_equal(instance_pb, request.instance)
    end

    it "invokes create_instance without error" do
      instance = Google::Bigtable::Admin::V2::Instance.new(instance_attrs)
      cluster = Google::Bigtable::Admin::V2::Cluster.new(
        name: "test-cluster",
        location: cluster_location
      )
      clusters = [cluster]

      operation, expected_response = build_longrunning_operation(
        "create_instance",
        instance_attrs,
        Google::Bigtable::Admin::V2::Instance
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_create_instance_request(
          request,
          display_name: instance_attrs[:display_name]
        )

        expected_cluster = Google::Bigtable::Admin::V2::Cluster.new(
          name: "",
          location: cluster_location_path
        )
        assert_equal({ cluster.name => expected_cluster }, request.clusters)
        OpenStruct.new(execute: operation)
      end

      stub_instance_admin_grpc(:create_instance, mock_method) do
        # Call method
        operation = client.create_instance(instance, clusters)

        # Verify the response
        assert_equal(expected_response, operation.response)
      end
    end

    it "invokes create_instance and returns an operation error." do
      # Create request parameters
      instance = Google::Bigtable::Admin::V2::Instance.new(instance_attrs)
      clusters = {}

      # Create expected grpc response
      operation, operation_error = build_longrunning_operation_with_error(
        "create_instance",
        Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_create_instance_request(
          request,
          display_name: instance_attrs[:display_name]
        )
        assert_equal(clusters, request.clusters)
        OpenStruct.new(execute: operation)
      end

      stub_instance_admin_grpc(:create_instance, mock_method) do
        response = client.create_instance(instance, clusters)
        assert(response.error?)
        assert_equal(operation_error, response.error)
      end
    end
  end

  describe "get_instance" do
    it 'get instance without error' do
      # Create expected grpc response
      expected_response = instance_attrs
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(instance_path, request.name)
        OpenStruct.new(execute: expected_response)
      end

      stub_instance_admin_grpc(:get_instance, mock_method) do
        response = client.instance(instance_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_instance with error' do
      custom_error = InstanceAdminTestError.new "get_instance"
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(instance_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:get_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.instance(instance_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'list_instances' do
    it 'invokes list_instances without error' do
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListInstancesResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListInstancesRequest, request)
        assert_equal(project_path, request.parent)
        OpenStruct.new(execute: expected_response)
      end

      stub_instance_admin_grpc(:list_instances, mock_method) do
        response = client.instances
        assert_equal(expected_response, response)
      end
    end

    it 'invokes list_instances with error' do
      custom_error = InstanceAdminTestError.new "list_instances"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListInstancesRequest, request)
        assert_equal(project_path, request.parent)
        raise custom_error
      end

      stub_instance_admin_grpc(:list_instances, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.instances
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end

    end
  end

  describe 'update_instance' do
    it 'invokes update_instance without error' do
      # Create request parameters
      display_name = ''
      type = :TYPE_UNSPECIFIED
      labels = {}

      # Create expected grpc response
      expected_response = { name: instance_id, display_name: display_name}
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Instance, request)
        assert_equal(instance_path, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        OpenStruct.new(execute: expected_response)
      end

      stub_instance_admin_grpc(:update_instance, mock_method) do
        response = client.update_instance(
          instance_id,
          display_name: display_name,
          type: type,
          labels: labels
        )
        assert_equal(expected_response, response)
      end
    end

    it 'invokes update_instance with error' do
      custom_error = InstanceAdminTestError.new "update_instance"

      # Create request parameters
      display_name = ''
      type = :TYPE_UNSPECIFIED
      labels = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Instance, request)
        assert_equal(instance_path, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        raise custom_error
      end

      stub_instance_admin_grpc(:update_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.update_instance(
            instance_id,
            display_name: display_name,
            type: type,
            labels: labels
          )
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_instance' do
    it 'invokes delete_instance without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(instance_path, request.name)
        OpenStruct.new(execute: nil)
      end

      stub_instance_admin_grpc(:delete_instance, mock_method) do
        response = client.delete_instance(instance_id)
        assert_nil(response)
      end
    end

    it 'invokes delete_instance with error' do
      custom_error = InstanceAdminTestError.new "delete_instance"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(instance_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:delete_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.delete_instance(instance_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'create_cluster' do
    it 'invokes create_cluster without error' do
      operation, expected_response = build_longrunning_operation(
        "create_cluster",
        cluster_attrs,
        Google::Bigtable::Admin::V2::Cluster
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(cluster_id, request.cluster_id)

        req_cluster = {
          location: cluster_location_path,
          serve_nodes: cluster_attrs[:serve_nodes]
        }

        assert_equal(Google::Gax::to_proto(req_cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        response = client.create_cluster(
          instance_id,
           Google::Bigtable::Admin::V2::Cluster.new(cluster_attrs)
        )
        assert_equal(expected_response, response.response)
      end
    end

    it 'invokes create_cluster and returns an operation error.' do
      # Create expected grpc response
      operation, operation_error = build_longrunning_operation_with_error(
        "create_cluster",
        Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(cluster_id, request.cluster_id)

        req_cluster = {
          location: cluster_location_path,
          serve_nodes: cluster_attrs[:serve_nodes]
        }
        assert_equal(Google::Gax::to_proto(req_cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        OpenStruct.new(execute: operation)
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        response = client.create_cluster(
          instance_id,
          Google::Bigtable::Admin::V2::Cluster.new(cluster_attrs)
        )
        assert(response.error?)
        assert_equal(operation_error, response.error)
      end

    end

    it 'invokes create_cluster with error' do
      custom_error = InstanceAdminTestError.new "create_cluster"
      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(instance_path, request.parent)
        assert_equal(cluster_id, request.cluster_id)

        req_cluster = {
          location: cluster_location_path,
          serve_nodes: cluster_attrs[:serve_nodes]
        }

        assert_equal(Google::Gax::to_proto(req_cluster, Google::Bigtable::Admin::V2::Cluster), request.cluster)
        raise custom_error
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.create_cluster(
            instance_id,
            Google::Bigtable::Admin::V2::Cluster.new(cluster_attrs)
          )
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'get_cluster' do
    it 'invokes get_cluster without error' do
      # Create expected grpc response
      expected_response = {
        name: cluster_id,
        location: location,
        serve_nodes: cluster_attrs[:serve_nodes]
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::Cluster)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(cluster_path, request.name)
        OpenStruct.new(execute: expected_response)
      end

      stub_instance_admin_grpc(:get_cluster, mock_method) do
        response = client.cluster(instance_id, cluster_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_cluster with error' do
      custom_error = InstanceAdminTestError.new "get_cluster."

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(cluster_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:get_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.cluster(instance_id, cluster_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'list_clusters' do
    it 'invokes list_clusters without error' do
      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListClustersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(instance_path, request.parent)
        OpenStruct.new(execute: expected_response)
      end

      stub_instance_admin_grpc(:list_clusters, mock_method) do
        response = client.clusters(instance_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes list_clusters with error' do
      custom_error = InstanceAdminTestError.new "list_clusters"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(instance_path, request.parent)
        raise custom_error
      end

      stub_instance_admin_grpc(:list_clusters, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.clusters(instance_id)
        end
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'update_cluster' do
    it 'invokes update_cluster without error' do
      # Create expected grpc response
      serve_nodes = 6
      expected_response = {
        name: cluster_id,
        serve_nodes: serve_nodes
      }

      operation, expected_response = build_longrunning_operation(
        "update_instance",
        expected_response,
        Google::Bigtable::Admin::V2::Cluster
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        OpenStruct.new(execute: operation)
      end

      stub_instance_admin_grpc(:update_cluster, mock_method) do
        response = client.update_cluster(
          instance_id,
          cluster_id,
          serve_nodes
        )

        assert_equal(expected_response, response.response)
      end
    end

    it 'invokes update_cluster and returns an operation error.' do
      serve_nodes = 0

      # Create expected grpc response
      operation, operation_error = build_longrunning_operation_with_error(
        "update_cluster",
        Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        OpenStruct.new(execute: operation)
      end

      # Mock auth layer
      stub_instance_admin_grpc(:update_cluster, mock_method) do
        response = client.update_cluster(
          instance_id,
          cluster_id,
          serve_nodes
        )

        assert(response.error?)
        assert_equal(operation_error, response.error)
      end
    end

    it 'invokes update_cluster with error' do
      custom_error = InstanceAdminTestError.new "update_cluster."
      serve_nodes = 1

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::Cluster, request)
        assert_equal(cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        raise custom_error
      end

      stub_instance_admin_grpc(:update_cluster, mock_method) do
        # Call method
        err = assert_raises Google::Gax::GaxError do
          client.update_cluster(
            instance_id,
            cluster_id,
            serve_nodes
          )
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_cluster' do
    it 'invokes delete_cluster without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(cluster_path, request.name)
        OpenStruct.new(execute: nil)
      end

      stub_instance_admin_grpc(:delete_cluster, mock_method) do
        # Call method
        response = client.delete_cluster(instance_id, cluster_id)

        # Verify the response
        assert_nil(response)
      end
    end

    it 'invokes delete_cluster with error' do
      custom_error = InstanceAdminTestError.new "delete_cluster"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(cluster_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:delete_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          client.delete_cluster(instance_id, cluster_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end
end
