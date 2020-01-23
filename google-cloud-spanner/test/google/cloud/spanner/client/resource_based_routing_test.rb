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

require "helper"

describe Google::Cloud::Spanner::Client, :resource_based_routing, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:session_id) { "session123" }
  let(:session_grpc) { Google::Spanner::V1::Session.new name: session_path(instance_id, database_id, session_id) }
  let(:session) { Google::Cloud::Spanner::Session.from_grpc session_grpc, spanner.service }
  let(:pool_opts) { { min: 0, max: 4 } }

  before do
    session.instance_variable_set :@last_updated_at, Time.now
    ENV.delete "GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"
  end

  after do
    ENV.delete "GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"
  end


  it "sets service with default host" do
    client = Google::Cloud::Spanner::Client.new \
      spanner, instance_id, database_id, pool_opts: { min: 0, max: 4 }

    client.service.host.must_equal \
      Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
    client.resource_based_routing_enabled?.must_equal false
  end

  it "sets service host to default service uri if resource based routing disabled" do
    client = Google::Cloud::Spanner::Client.new \
      spanner, instance_id, database_id, pool_opts: { min: 0, max: 4 },
      enable_resource_based_routing: false

    client.service.host.must_equal \
      Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
    client.resource_based_routing_enabled?.must_equal false
  end

  it "set service host to instance endpoint uri if resource based routing enabled" do
    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: ["test1.host.com", "test2.host.com"]
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    Google::Cloud::Spanner::Pool.stub :new, Object.new do
      client = Google::Cloud::Spanner::Client.new \
        spanner, instance_id, database_id, enable_resource_based_routing: true
      client.resource_based_routing_enabled?.must_equal true
      client.service.host.must_equal "test1.host.com"
    end

    mock.verify
  end

  it "set service host with instance endpoint uri if resource based routing enabled using an environment variable" do
    ENV["GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"] = "TRUE"

    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: ["test1.host.com", "test2.host.com"]
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    Google::Cloud::Spanner::Pool.stub :new, Object.new do
      client = Google::Cloud::Spanner::Client.new \
        spanner, instance_id, database_id, enable_resource_based_routing: true
      client.resource_based_routing_enabled?.must_equal true
      client.service.host.must_equal "test1.host.com"
    end

    mock.verify
  end

  it "set default endpoint uri if resource based routing enabled and instance endpoint uris not present" do
    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: []
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    Google::Cloud::Spanner::Pool.stub :new, Object.new do
      client = Google::Cloud::Spanner::Client.new \
        spanner, instance_id, database_id, enable_resource_based_routing: true
      client.service.host.must_equal \
        Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
      client.resource_based_routing_enabled?.must_equal true
    end

    mock.verify
  end

  it "returns default endpoint uri if get instance permission denied" do
    stub = OpenStruct.new(api_call_count: 0)

    def stub.get_instance *args
      self.api_call_count += 1
      gax_error = Google::Gax::GaxError.new "permission denied"
      gax_error.instance_variable_set :@cause, GRPC::BadStatus.new(7, "permission denied")
      raise gax_error
    end
    spanner.service.mocked_instances = stub

    Google::Cloud::Spanner::Pool.stub :new, Object.new do
      client = Google::Cloud::Spanner::Client.new \
        spanner, instance_id, database_id, enable_resource_based_routing: true
      client.service.host.must_equal \
        Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
      stub.api_call_count.must_equal 1
      client.resource_based_routing_enabled?.must_equal true
    end
  end
end
