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

require "google/cloud/container"
require "google/cloud/container/v1/cluster_manager_client"
require "google/container/v1/cluster_service_services_pb"

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

class MockClusterManagerCredentials_v1 < Google::Cloud::Container::V1::Credentials
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

describe Google::Cloud::Container::V1::ClusterManagerClient do

  describe 'list_clusters' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#list_clusters."

    it 'invokes list_clusters without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::ListClustersResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_clusters")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.list_clusters

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_clusters do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_clusters with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_clusters, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_clusters")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_clusters
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_cluster' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#get_cluster."

    it 'invokes get_cluster without error' do
      # Create expected grpc response
      name = "name3373707"
      description = "description-1724546052"
      initial_node_count = 1682564205
      logging_service = "loggingService-1700501035"
      monitoring_service = "monitoringService1469270462"
      network = "network1843485230"
      cluster_ipv4_cidr = "clusterIpv4Cidr-141875831"
      subnetwork = "subnetwork-1302785042"
      enable_kubernetes_alpha = false
      label_fingerprint = "labelFingerprint714995737"
      self_link = "selfLink-1691268851"
      zone = "zone3744684"
      endpoint = "endpoint1741102485"
      initial_cluster_version = "initialClusterVersion-276373352"
      current_master_version = "currentMasterVersion-920953983"
      current_node_version = "currentNodeVersion-407476063"
      create_time = "createTime-493574096"
      status_message = "statusMessage-239442758"
      node_ipv4_cidr_size = 1181176815
      services_ipv4_cidr = "servicesIpv4Cidr1966438125"
      current_node_count = 178977560
      expire_time = "expireTime-96179731"
      location = "location1901043637"
      enable_tpu = false
      tpu_ipv4_cidr_block = "tpuIpv4CidrBlock1137906646"
      expected_response = {
        name: name,
        description: description,
        initial_node_count: initial_node_count,
        logging_service: logging_service,
        monitoring_service: monitoring_service,
        network: network,
        cluster_ipv4_cidr: cluster_ipv4_cidr,
        subnetwork: subnetwork,
        enable_kubernetes_alpha: enable_kubernetes_alpha,
        label_fingerprint: label_fingerprint,
        self_link: self_link,
        zone: zone,
        endpoint: endpoint,
        initial_cluster_version: initial_cluster_version,
        current_master_version: current_master_version,
        current_node_version: current_node_version,
        create_time: create_time,
        status_message: status_message,
        node_ipv4_cidr_size: node_ipv4_cidr_size,
        services_ipv4_cidr: services_ipv4_cidr,
        current_node_count: current_node_count,
        expire_time: expire_time,
        location: location,
        enable_tpu: enable_tpu,
        tpu_ipv4_cidr_block: tpu_ipv4_cidr_block
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Cluster)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.get_cluster

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_cluster do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_cluster with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_cluster
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_cluster' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#create_cluster."

    it 'invokes create_cluster without error' do
      # Create request parameters
      cluster = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::CreateClusterRequest, request)
        assert_equal(Google::Gax::to_proto(cluster, Google::Container::V1::Cluster), request.cluster)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("create_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.create_cluster(cluster)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_cluster(cluster) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_cluster with error' do
      # Create request parameters
      cluster = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::CreateClusterRequest, request)
        assert_equal(Google::Gax::to_proto(cluster, Google::Container::V1::Cluster), request.cluster)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("create_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_cluster(cluster)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_cluster' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#update_cluster."

    it 'invokes update_cluster without error' do
      # Create request parameters
      update = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateClusterRequest, request)
        assert_equal(Google::Gax::to_proto(update, Google::Container::V1::ClusterUpdate), request.update)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.update_cluster(update)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_cluster(update) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_cluster with error' do
      # Create request parameters
      update = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateClusterRequest, request)
        assert_equal(Google::Gax::to_proto(update, Google::Container::V1::ClusterUpdate), request.update)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_cluster(update)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_node_pool' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#update_node_pool."

    it 'invokes update_node_pool without error' do
      # Create request parameters
      node_version = ''
      image_type = ''

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateNodePoolRequest, request)
        assert_equal(node_version, request.node_version)
        assert_equal(image_type, request.image_type)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.update_node_pool(node_version, image_type)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_node_pool(node_version, image_type) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_node_pool with error' do
      # Create request parameters
      node_version = ''
      image_type = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateNodePoolRequest, request)
        assert_equal(node_version, request.node_version)
        assert_equal(image_type, request.image_type)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_node_pool(node_version, image_type)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_node_pool_autoscaling' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_node_pool_autoscaling."

    it 'invokes set_node_pool_autoscaling without error' do
      # Create request parameters
      autoscaling = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolAutoscalingRequest, request)
        assert_equal(Google::Gax::to_proto(autoscaling, Google::Container::V1::NodePoolAutoscaling), request.autoscaling)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_autoscaling, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_autoscaling")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_node_pool_autoscaling(autoscaling)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_node_pool_autoscaling(autoscaling) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_node_pool_autoscaling with error' do
      # Create request parameters
      autoscaling = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolAutoscalingRequest, request)
        assert_equal(Google::Gax::to_proto(autoscaling, Google::Container::V1::NodePoolAutoscaling), request.autoscaling)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_autoscaling, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_autoscaling")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_node_pool_autoscaling(autoscaling)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_logging_service' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_logging_service."

    it 'invokes set_logging_service without error' do
      # Create request parameters
      logging_service = ''

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLoggingServiceRequest, request)
        assert_equal(logging_service, request.logging_service)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_logging_service, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_logging_service")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_logging_service(logging_service)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_logging_service(logging_service) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_logging_service with error' do
      # Create request parameters
      logging_service = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLoggingServiceRequest, request)
        assert_equal(logging_service, request.logging_service)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_logging_service, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_logging_service")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_logging_service(logging_service)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_monitoring_service' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_monitoring_service."

    it 'invokes set_monitoring_service without error' do
      # Create request parameters
      monitoring_service = ''

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMonitoringServiceRequest, request)
        assert_equal(monitoring_service, request.monitoring_service)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_monitoring_service, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_monitoring_service")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_monitoring_service(monitoring_service)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_monitoring_service(monitoring_service) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_monitoring_service with error' do
      # Create request parameters
      monitoring_service = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMonitoringServiceRequest, request)
        assert_equal(monitoring_service, request.monitoring_service)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_monitoring_service, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_monitoring_service")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_monitoring_service(monitoring_service)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_addons_config' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_addons_config."

    it 'invokes set_addons_config without error' do
      # Create request parameters
      addons_config = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetAddonsConfigRequest, request)
        assert_equal(Google::Gax::to_proto(addons_config, Google::Container::V1::AddonsConfig), request.addons_config)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_addons_config, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_addons_config")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_addons_config(addons_config)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_addons_config(addons_config) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_addons_config with error' do
      # Create request parameters
      addons_config = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetAddonsConfigRequest, request)
        assert_equal(Google::Gax::to_proto(addons_config, Google::Container::V1::AddonsConfig), request.addons_config)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_addons_config, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_addons_config")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_addons_config(addons_config)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_locations' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_locations."

    it 'invokes set_locations without error' do
      # Create request parameters
      locations = []

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLocationsRequest, request)
        assert_equal(locations, request.locations)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_locations, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_locations")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_locations(locations)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_locations(locations) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_locations with error' do
      # Create request parameters
      locations = []

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLocationsRequest, request)
        assert_equal(locations, request.locations)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_locations, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_locations")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_locations(locations)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'update_master' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#update_master."

    it 'invokes update_master without error' do
      # Create request parameters
      master_version = ''

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateMasterRequest, request)
        assert_equal(master_version, request.master_version)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_master, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_master")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.update_master(master_version)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.update_master(master_version) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes update_master with error' do
      # Create request parameters
      master_version = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::UpdateMasterRequest, request)
        assert_equal(master_version, request.master_version)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:update_master, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("update_master")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.update_master(master_version)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_master_auth' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_master_auth."

    it 'invokes set_master_auth without error' do
      # Create request parameters
      action = :UNKNOWN
      update = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMasterAuthRequest, request)
        assert_equal(action, request.action)
        assert_equal(Google::Gax::to_proto(update, Google::Container::V1::MasterAuth), request.update)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_master_auth, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_master_auth")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_master_auth(action, update)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_master_auth(action, update) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_master_auth with error' do
      # Create request parameters
      action = :UNKNOWN
      update = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMasterAuthRequest, request)
        assert_equal(action, request.action)
        assert_equal(Google::Gax::to_proto(update, Google::Container::V1::MasterAuth), request.update)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_master_auth, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_master_auth")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_master_auth(action, update)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_cluster' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#delete_cluster."

    it 'invokes delete_cluster without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("delete_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.delete_cluster

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.delete_cluster do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_cluster with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_cluster, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("delete_cluster")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_cluster
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_operations' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#list_operations."

    it 'invokes list_operations without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::ListOperationsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_operations, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_operations")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.list_operations

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_operations do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_operations with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_operations, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_operations")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_operations
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_operation' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#get_operation."

    it 'invokes get_operation without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_operation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.get_operation

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_operation do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_operation with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_operation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_operation
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'cancel_operation' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#cancel_operation."

    it 'invokes cancel_operation without error' do

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: nil)
      end
      mock_stub = MockGrpcClientStub_v1.new(:cancel_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("cancel_operation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.cancel_operation

          # Verify the response
          assert_nil(response)

          # Call method with block
          client.cancel_operation do |response, operation|
            # Verify the response
            assert_nil(response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes cancel_operation with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:cancel_operation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("cancel_operation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.cancel_operation
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_server_config' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#get_server_config."

    it 'invokes get_server_config without error' do
      # Create expected grpc response
      default_cluster_version = "defaultClusterVersion111003029"
      default_image_type = "defaultImageType-918225828"
      expected_response = { default_cluster_version: default_cluster_version, default_image_type: default_image_type }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::ServerConfig)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_server_config, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_server_config")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.get_server_config

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_server_config do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_server_config with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_server_config, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_server_config")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_server_config
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_node_pools' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#list_node_pools."

    it 'invokes list_node_pools without error' do
      # Create expected grpc response
      expected_response = {}
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::ListNodePoolsResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_node_pools, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_node_pools")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.list_node_pools

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.list_node_pools do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes list_node_pools with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_node_pools, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_node_pools")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_node_pools
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'get_node_pool' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#get_node_pool."

    it 'invokes get_node_pool without error' do
      # Create expected grpc response
      name = "name3373707"
      initial_node_count = 1682564205
      self_link = "selfLink-1691268851"
      version = "version351608024"
      status_message = "statusMessage-239442758"
      pod_ipv4_cidr_size = 1098768716
      expected_response = {
        name: name,
        initial_node_count: initial_node_count,
        self_link: self_link,
        version: version,
        status_message: status_message,
        pod_ipv4_cidr_size: pod_ipv4_cidr_size
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::NodePool)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.get_node_pool

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.get_node_pool do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes get_node_pool with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:get_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("get_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.get_node_pool
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'create_node_pool' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#create_node_pool."

    it 'invokes create_node_pool without error' do
      # Create request parameters
      node_pool = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::CreateNodePoolRequest, request)
        assert_equal(Google::Gax::to_proto(node_pool, Google::Container::V1::NodePool), request.node_pool)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("create_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.create_node_pool(node_pool)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.create_node_pool(node_pool) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes create_node_pool with error' do
      # Create request parameters
      node_pool = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::CreateNodePoolRequest, request)
        assert_equal(Google::Gax::to_proto(node_pool, Google::Container::V1::NodePool), request.node_pool)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:create_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("create_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.create_node_pool(node_pool)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'delete_node_pool' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#delete_node_pool."

    it 'invokes delete_node_pool without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("delete_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.delete_node_pool

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.delete_node_pool do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes delete_node_pool with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:delete_node_pool, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("delete_node_pool")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.delete_node_pool
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'rollback_node_pool_upgrade' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#rollback_node_pool_upgrade."

    it 'invokes rollback_node_pool_upgrade without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback_node_pool_upgrade, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("rollback_node_pool_upgrade")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.rollback_node_pool_upgrade

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.rollback_node_pool_upgrade do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes rollback_node_pool_upgrade with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:rollback_node_pool_upgrade, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("rollback_node_pool_upgrade")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.rollback_node_pool_upgrade
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_node_pool_management' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_node_pool_management."

    it 'invokes set_node_pool_management without error' do
      # Create request parameters
      management = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolManagementRequest, request)
        assert_equal(Google::Gax::to_proto(management, Google::Container::V1::NodeManagement), request.management)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_management, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_management")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_node_pool_management(management)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_node_pool_management(management) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_node_pool_management with error' do
      # Create request parameters
      management = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolManagementRequest, request)
        assert_equal(Google::Gax::to_proto(management, Google::Container::V1::NodeManagement), request.management)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_management, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_management")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_node_pool_management(management)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_labels' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_labels."

    it 'invokes set_labels without error' do
      # Create request parameters
      resource_labels = {}
      label_fingerprint = ''

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLabelsRequest, request)
        assert_equal(resource_labels, request.resource_labels.to_h)
        assert_equal(label_fingerprint, request.label_fingerprint)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_labels, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_labels")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_labels(resource_labels, label_fingerprint)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_labels(resource_labels, label_fingerprint) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_labels with error' do
      # Create request parameters
      resource_labels = {}
      label_fingerprint = ''

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLabelsRequest, request)
        assert_equal(resource_labels, request.resource_labels.to_h)
        assert_equal(label_fingerprint, request.label_fingerprint)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_labels, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_labels")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_labels(resource_labels, label_fingerprint)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_legacy_abac' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_legacy_abac."

    it 'invokes set_legacy_abac without error' do
      # Create request parameters
      enabled = false

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLegacyAbacRequest, request)
        assert_equal(enabled, request.enabled)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_legacy_abac, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_legacy_abac")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_legacy_abac(enabled)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_legacy_abac(enabled) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_legacy_abac with error' do
      # Create request parameters
      enabled = false

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetLegacyAbacRequest, request)
        assert_equal(enabled, request.enabled)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_legacy_abac, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_legacy_abac")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_legacy_abac(enabled)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'start_ip_rotation' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#start_ip_rotation."

    it 'invokes start_ip_rotation without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:start_ip_rotation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("start_ip_rotation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.start_ip_rotation

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.start_ip_rotation do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes start_ip_rotation with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:start_ip_rotation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("start_ip_rotation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.start_ip_rotation
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'complete_ip_rotation' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#complete_ip_rotation."

    it 'invokes complete_ip_rotation without error' do
      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:complete_ip_rotation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("complete_ip_rotation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.complete_ip_rotation

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.complete_ip_rotation do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes complete_ip_rotation with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:complete_ip_rotation, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("complete_ip_rotation")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.complete_ip_rotation
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_node_pool_size' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_node_pool_size."

    it 'invokes set_node_pool_size without error' do
      # Create request parameters
      node_count = 0

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolSizeRequest, request)
        assert_equal(node_count, request.node_count)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_size, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_size")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_node_pool_size(node_count)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_node_pool_size(node_count) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_node_pool_size with error' do
      # Create request parameters
      node_count = 0

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNodePoolSizeRequest, request)
        assert_equal(node_count, request.node_count)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_node_pool_size, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_node_pool_size")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_node_pool_size(node_count)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_network_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_network_policy."

    it 'invokes set_network_policy without error' do
      # Create request parameters
      network_policy = {}

      # Create expected grpc response
      name = "name3373707"
      zone = "zone3744684"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNetworkPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(network_policy, Google::Container::V1::NetworkPolicy), request.network_policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_network_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_network_policy")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_network_policy(network_policy)

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_network_policy(network_policy) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_network_policy with error' do
      # Create request parameters
      network_policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetNetworkPolicyRequest, request)
        assert_equal(Google::Gax::to_proto(network_policy, Google::Container::V1::NetworkPolicy), request.network_policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_network_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_network_policy")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_network_policy(network_policy)
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'set_maintenance_policy' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#set_maintenance_policy."

    it 'invokes set_maintenance_policy without error' do
      # Create request parameters
      project_id = ''
      zone = ''
      cluster_id = ''
      maintenance_policy = {}

      # Create expected grpc response
      name = "name3373707"
      zone_2 = "zone2-696322977"
      detail = "detail-1335224239"
      status_message = "statusMessage-239442758"
      self_link = "selfLink-1691268851"
      target_link = "targetLink-2084812312"
      location = "location1901043637"
      start_time = "startTime-1573145462"
      end_time = "endTime1725551537"
      expected_response = {
        name: name,
        zone: zone_2,
        detail: detail,
        status_message: status_message,
        self_link: self_link,
        target_link: target_link,
        location: location,
        start_time: start_time,
        end_time: end_time
      }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::Operation)

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMaintenancePolicyRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(zone, request.zone)
        assert_equal(cluster_id, request.cluster_id)
        assert_equal(Google::Gax::to_proto(maintenance_policy, Google::Container::V1::MaintenancePolicy), request.maintenance_policy)
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_maintenance_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_maintenance_policy")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.set_maintenance_policy(
            project_id,
            zone,
            cluster_id,
            maintenance_policy
          )

          # Verify the response
          assert_equal(expected_response, response)

          # Call method with block
          client.set_maintenance_policy(
            project_id,
            zone,
            cluster_id,
            maintenance_policy
          ) do |response, operation|
            # Verify the response
            assert_equal(expected_response, response)
            refute_nil(operation)
          end
        end
      end
    end

    it 'invokes set_maintenance_policy with error' do
      # Create request parameters
      project_id = ''
      zone = ''
      cluster_id = ''
      maintenance_policy = {}

      # Mock Grpc layer
      mock_method = proc do |request|
        assert_instance_of(Google::Container::V1::SetMaintenancePolicyRequest, request)
        assert_equal(project_id, request.project_id)
        assert_equal(zone, request.zone)
        assert_equal(cluster_id, request.cluster_id)
        assert_equal(Google::Gax::to_proto(maintenance_policy, Google::Container::V1::MaintenancePolicy), request.maintenance_policy)
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:set_maintenance_policy, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("set_maintenance_policy")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.set_maintenance_policy(
              project_id,
              zone,
              cluster_id,
              maintenance_policy
            )
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end

  describe 'list_usable_subnetworks' do
    custom_error = CustomTestError_v1.new "Custom test error for Google::Cloud::Container::V1::ClusterManagerClient#list_usable_subnetworks."

    it 'invokes list_usable_subnetworks without error' do
      # Create expected grpc response
      next_page_token = ""
      subnetworks_element = {}
      subnetworks = [subnetworks_element]
      expected_response = { next_page_token: next_page_token, subnetworks: subnetworks }
      expected_response = Google::Gax::to_proto(expected_response, Google::Container::V1::ListUsableSubnetworksResponse)

      # Mock Grpc layer
      mock_method = proc do
        OpenStruct.new(execute: expected_response)
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_usable_subnetworks, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_usable_subnetworks")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          response = client.list_usable_subnetworks

          # Verify the response
          assert(response.instance_of?(Google::Gax::PagedEnumerable))
          assert_equal(expected_response, response.page.response)
          assert_nil(response.next_page)
          assert_equal(expected_response.subnetworks.to_a, response.to_a)
        end
      end
    end

    it 'invokes list_usable_subnetworks with error' do
      # Mock Grpc layer
      mock_method = proc do
        raise custom_error
      end
      mock_stub = MockGrpcClientStub_v1.new(:list_usable_subnetworks, mock_method)

      # Mock auth layer
      mock_credentials = MockClusterManagerCredentials_v1.new("list_usable_subnetworks")

      Google::Container::V1::ClusterManager::Stub.stub(:new, mock_stub) do
        Google::Cloud::Container::V1::Credentials.stub(:default, mock_credentials) do
          client = Google::Cloud::Container.new(version: :v1)

          # Call method
          err = assert_raises Google::Gax::GaxError, CustomTestError_v1 do
            client.list_usable_subnetworks
          end

          # Verify the GaxError wrapped the custom error that was raised.
          assert_match(custom_error.message, err.message)
        end
      end
    end
  end
end