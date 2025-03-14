# frozen_string_literal: true

# Copyright 2021 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!

require "helper"

require "gapic/grpc/service_stub"

require "google/cloud/network_connectivity/v1/hub_service"

class ::Google::Cloud::NetworkConnectivity::V1::HubService::ClientPathsTest < Minitest::Test
  class DummyStub
    def endpoint
      "endpoint.example.com"
    end
  
    def universe_domain
      "example.com"
    end

    def stub_logger
      nil
    end

    def logger
      nil
    end
  end

  def test_group_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.group_path project: "value0", hub: "value1", group: "value2"
      assert_equal "projects/value0/locations/global/hubs/value1/groups/value2", path
    end
  end

  def test_hub_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.hub_path project: "value0", hub: "value1"
      assert_equal "projects/value0/locations/global/hubs/value1", path
    end
  end

  def test_hub_route_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.hub_route_path project: "value0", hub: "value1", route_table: "value2", route: "value3"
      assert_equal "projects/value0/locations/global/hubs/value1/routeTables/value2/routes/value3", path
    end
  end

  def test_instance_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.instance_path project: "value0", zone: "value1", instance: "value2"
      assert_equal "projects/value0/zones/value1/instances/value2", path
    end
  end

  def test_interconnect_attachment_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.interconnect_attachment_path project: "value0", region: "value1", resource_id: "value2"
      assert_equal "projects/value0/regions/value1/interconnectAttachments/value2", path
    end
  end

  def test_location_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.location_path project: "value0", location: "value1"
      assert_equal "projects/value0/locations/value1", path
    end
  end

  def test_network_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.network_path project: "value0", resource_id: "value1"
      assert_equal "projects/value0/global/networks/value1", path
    end
  end

  def test_route_table_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.route_table_path project: "value0", hub: "value1", route_table: "value2"
      assert_equal "projects/value0/locations/global/hubs/value1/routeTables/value2", path
    end
  end

  def test_spoke_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.spoke_path project: "value0", location: "value1", spoke: "value2"
      assert_equal "projects/value0/locations/value1/spokes/value2", path
    end
  end

  def test_vpn_tunnel_path
    grpc_channel = ::GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure
    ::Gapic::ServiceStub.stub :new, DummyStub.new do
      client = ::Google::Cloud::NetworkConnectivity::V1::HubService::Client.new do |config|
        config.credentials = grpc_channel
      end

      path = client.vpn_tunnel_path project: "value0", region: "value1", resource_id: "value2"
      assert_equal "projects/value0/regions/value1/vpnTunnels/value2", path
    end
  end
end
