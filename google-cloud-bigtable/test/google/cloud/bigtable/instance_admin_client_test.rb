# frozen_string_literal: true

require_relative "test_helper"
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
  # Class aliases
  Bigtable = Google::Cloud::Bigtable unless Object.const_defined?("Bigtable")
  BigtableInstanceAdminClient =
    Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient

  before do
    @project_id = "test-project-id"
    @project_path =
      BigtableInstanceAdminClient.project_path(@project_id)
    @client = Google::Cloud.bigtable(
      project_id: @project_id,
      client_type: :instance
    )
  end

  describe "create_instance" do
    before do
      @instance_id = "name3373707"
      @display_name = "displayName1615086568"
      @instance_data = {
        name: @instance_id,
        display_name: @display_name
      }
    end

    def assert_create_instance_request request, instance_data
      assert_instance_of(Google::Bigtable::Admin::V2::CreateInstanceRequest, request)
      assert_equal(@project_path, request.parent)
      assert_equal(@instance_id, request.instance_id)

      instance_pb = Google::Gax.to_proto(instance_data, Bigtable::Instance)
      assert_equal(instance_pb, request.instance)
    end

    it "invokes create_instance without error" do
      instance = Bigtable::Instance.new(@instance_data)
      location = "us-east1-b"
      cluster = Bigtable::Cluster.new(
        name: "test-cluster",
        location: location
      )
      clusters = [cluster]

      operation, expected_response = build_longrunning_operation(
        "create_instance",
        @instance_data,
        Bigtable::Instance
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_create_instance_request(
          request,
          display_name: @instance_data[:display_name]
        )

        expected_cluster = Bigtable::Cluster.new(
          name: "",
          location: BigtableInstanceAdminClient.location_path(
            @project_id,
            location
          )
        )
        assert_equal({ cluster.name => expected_cluster }, request.clusters)
        operation
      end

      stub_instance_admin_grpc(:create_instance, mock_method) do
        # Call method
        operation = @client.create_instance(instance, clusters)

        # Verify the response
        assert_equal(expected_response, operation.response)
      end
    end

    it "invokes create_instance and returns an operation error." do
      # Create request parameters
      instance = Bigtable::Instance.new(@instance_data)
      clusters = {}

      # Create expected grpc response
      operation, operation_error = build_longrunning_operation_with_error(
        "create_instance",
        BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_create_instance_request(
          request,
          display_name: @instance_data[:display_name]
        )
        assert_equal(clusters, request.clusters)
        operation
      end

      stub_instance_admin_grpc(:create_instance, mock_method) do
        response = @client.create_instance(instance, clusters)
        assert(response.error?)
        assert_equal(operation_error, response.error)
      end
    end
  end

  describe "get_instance" do
    before do
      @instance_id = "name2"
      @display_name = "displayName1615086568"
      @instance_path = BigtableInstanceAdminClient.instance_path(@project_id, @instance_id)
    end

    it 'get instance without error' do
      # Create expected grpc response
      expected_response = { name: @instance_id, display_name: @display_name }
      expected_response = Google::Gax::to_proto(expected_response, Bigtable::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(@instance_path, request.name)
        expected_response
      end

      stub_instance_admin_grpc(:get_instance, mock_method) do
        response = @client.instance(@instance_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_instance with error' do
      custom_error = InstanceAdminTestError.new "get_instance"
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetInstanceRequest, request)
        assert_equal(@instance_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:get_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.instance(@instance_id)
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
        assert_equal(@project_path, request.parent)
        expected_response
      end

      stub_instance_admin_grpc(:list_instances, mock_method) do
        response = @client.instances
        assert_equal(expected_response, response)
      end
    end

    it 'invokes list_instances with error' do
      custom_error = InstanceAdminTestError.new "list_instances"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListInstancesRequest, request)
        assert_equal(@project_path, request.parent)
        raise custom_error
      end

      stub_instance_admin_grpc(:list_instances, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.instances
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end

    end
  end

  describe 'update_instance' do
    before do
      @instance_id = "name3"
      @instance_path = BigtableInstanceAdminClient.instance_path(@project_id, @instance_id)
    end

    it 'invokes update_instance without error' do
      # Create request parameters
      display_name = ''
      type = :TYPE_UNSPECIFIED
      labels = {}

      # Create expected grpc response
      expected_response = { name: @instance_id, display_name: display_name}
      expected_response = Google::Gax::to_proto(expected_response, Bigtable::Instance)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Bigtable::Instance, request)
        assert_equal(@instance_path, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        expected_response
      end

      stub_instance_admin_grpc(:update_instance, mock_method) do
        response = @client.update_instance(
          @instance_id,
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
        assert_instance_of(Bigtable::Instance, request)
        assert_equal(@instance_path, request.name)
        assert_equal(display_name, request.display_name)
        assert_equal(type, request.type)
        assert_equal(labels, request.labels)
        raise custom_error
      end

      stub_instance_admin_grpc(:update_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.update_instance(
            @instance_id,
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
    before do
      @instance_id = "name4"
      @instance_path = BigtableInstanceAdminClient.instance_path(@project_id, @instance_id)
    end

    it 'invokes delete_instance without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(@instance_path, request.name)
        nil
      end

      stub_instance_admin_grpc(:delete_instance, mock_method) do
        response = @client.delete_instance(@instance_id)
        assert_nil(response)
      end
    end

    it 'invokes delete_instance with error' do
      custom_error = InstanceAdminTestError.new "delete_instance"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteInstanceRequest, request)
        assert_equal(@instance_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:delete_instance, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.delete_instance(@instance_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'create_cluster' do
    before do
      @instance_id = "name4"
      @instance_path = BigtableInstanceAdminClient.instance_path(
        @project_id,
        @instance_id
      )
      @cluster_id = "cluster_1"
      @location = "us-east1-a"
      @serve_nodes = 3
      @cluster_data = {
        name: @cluster_id,
        location: @location,
        serve_nodes: @serve_nodes
      }
    end

    it 'invokes create_cluster without error' do
      operation, expected_response = build_longrunning_operation(
        "create_cluster",
        @cluster_data,
        Bigtable::Cluster
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(@instance_path, request.parent)
        assert_equal(@cluster_id, request.cluster_id)

        req_cluster = {
          location: BigtableInstanceAdminClient.location_path(@project_id, @location),
          serve_nodes: @serve_nodes
        }

        assert_equal(Google::Gax::to_proto(req_cluster, Bigtable::Cluster), request.cluster)
        operation
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        response = @client.create_cluster(
          @instance_id,
          Bigtable::Cluster.new(name: @cluster_id, location: @location, serve_nodes: @serve_nodes)
        )
        assert_equal(expected_response, response.response)
      end
    end

    it 'invokes create_cluster and returns an operation error.' do
      # Create expected grpc response
      operation, operation_error = build_longrunning_operation_with_error(
        "create_cluster",
        BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::CreateClusterRequest, request)
        assert_equal(@instance_path, request.parent)
        assert_equal(@cluster_id, request.cluster_id)

        req_cluster = {
          location: BigtableInstanceAdminClient.location_path(@project_id, @location),
          serve_nodes: @serve_nodes
        }
        assert_equal(Google::Gax::to_proto(req_cluster, Bigtable::Cluster), request.cluster)
        operation
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        response = @client.create_cluster(
          @instance_id,
          Bigtable::Cluster.new(name: @cluster_id, location: @location, serve_nodes: @serve_nodes)
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
        assert_equal(@instance_path, request.parent)
        assert_equal(@cluster_id, request.cluster_id)

        req_cluster = {
          location: BigtableInstanceAdminClient.location_path(@project_id, @location),
          serve_nodes: @serve_nodes
        }

        assert_equal(Google::Gax::to_proto(req_cluster, Bigtable::Cluster), request.cluster)
        raise custom_error
      end

      stub_instance_admin_grpc(:create_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.create_cluster(
            @instance_id,
            Bigtable::Cluster.new(name: @cluster_id, location: @location, serve_nodes: @serve_nodes)
          )
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'get_cluster' do
    before do
      @instance_id = "instance-1"
      @cluster_id = "cluster_2"
      @location = "us-east-1c"
      @serve_nodes = 3
      @cluster_path = BigtableInstanceAdminClient.cluster_path(@project_id, @instance_id, @cluster_id)
    end

    it 'invokes get_cluster without error' do
      # Create expected grpc response
      expected_response = {
        name: @cluster_id,
        location: @location,
        serve_nodes: @serve_nodes
      }
      expected_response = Google::Gax::to_proto(expected_response, Bigtable::Cluster)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(@cluster_path, request.name)
        expected_response
      end

      stub_instance_admin_grpc(:get_cluster, mock_method) do
        response = @client.cluster(@instance_id, @cluster_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes get_cluster with error' do
      custom_error = InstanceAdminTestError.new "get_cluster."

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::GetClusterRequest, request)
        assert_equal(@cluster_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:get_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.cluster(@instance_id, @cluster_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'list_clusters' do
    before do
      @instance_id = "instance-1"
      @instance_path = BigtableInstanceAdminClient.instance_path(@project_id, @instance_id)
    end

    it 'invokes list_clusters without error' do
      # Create expected grpc response
      next_page_token = "nextPageToken-1530815211"
      expected_response = { next_page_token: next_page_token }
      expected_response = Google::Gax::to_proto(expected_response, Google::Bigtable::Admin::V2::ListClustersResponse)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(@instance_path, request.parent)
        expected_response
      end

      stub_instance_admin_grpc(:list_clusters, mock_method) do
        response = @client.clusters(@instance_id)
        assert_equal(expected_response, response)
      end
    end

    it 'invokes list_clusters with error' do
      custom_error = InstanceAdminTestError.new "list_clusters"

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::ListClustersRequest, request)
        assert_equal(@instance_path, request.parent)
        raise custom_error
      end

      stub_instance_admin_grpc(:list_clusters, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.clusters(@instance_id)
        end
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'update_cluster' do
    before do
      @instance_id = "instance-2"
      @cluster_id = "cluster_3"
      @location = "us-east-1c"
      @cluster_path = BigtableInstanceAdminClient.cluster_path(@project_id, @instance_id, @cluster_id)
    end
    it 'invokes update_cluster without error' do
      # Create expected grpc response
      serve_nodes = 6
      expected_response = {
        name: @cluster_id,
        serve_nodes: serve_nodes
      }

      operation, expected_response = build_longrunning_operation(
        "update_instance",
        expected_response,
        Bigtable::Cluster
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Bigtable::Cluster, request)
        assert_equal(@cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        operation
      end

      stub_instance_admin_grpc(:update_cluster, mock_method) do
        response = @client.update_cluster(
          @instance_id,
          @cluster_id,
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
        BigtableInstanceAdminClient
      )

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Bigtable::Cluster, request)
        assert_equal(@cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        operation
      end

      # Mock auth layer
      stub_instance_admin_grpc(:update_cluster, mock_method) do
        response = @client.update_cluster(
          @instance_id,
          @cluster_id,
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
        assert_instance_of(Bigtable::Cluster, request)
        assert_equal(@cluster_path, request.name)
        assert_equal('', request.location)
        assert_equal(serve_nodes, request.serve_nodes)
        raise custom_error
      end

      stub_instance_admin_grpc(:update_cluster, mock_method) do
        # Call method
        err = assert_raises Google::Gax::GaxError do
          @client.update_cluster(
            @instance_id,
            @cluster_id,
            serve_nodes
          )
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end

  describe 'delete_cluster' do
    before do
      @instance_id = "instance-2"
      @cluster_id = "cluster_3"
      @location = "us-east-1c"
      @cluster_path = BigtableInstanceAdminClient.cluster_path(@project_id, @instance_id, @cluster_id)
    end

    it 'invokes delete_cluster without error' do
      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(@cluster_path, request.name)
        nil
      end

      stub_instance_admin_grpc(:delete_cluster, mock_method) do
        # Call method
        response = @client.delete_cluster(@instance_id, @cluster_id)

        # Verify the response
        assert_nil(response)
      end
    end

    it 'invokes delete_cluster with error' do
      custom_error = InstanceAdminTestError.new "delete_cluster"

      mock_method = proc do |request|
        assert_instance_of(Google::Bigtable::Admin::V2::DeleteClusterRequest, request)
        assert_equal(@cluster_path, request.name)
        raise custom_error
      end

      stub_instance_admin_grpc(:delete_cluster, mock_method) do
        err = assert_raises Google::Gax::GaxError do
          @client.delete_cluster(@instance_id, @cluster_id)
        end

        # Verify the GaxError wrapped the custom error that was raised.
        assert_match(custom_error.message, err.message)
      end
    end
  end
end
