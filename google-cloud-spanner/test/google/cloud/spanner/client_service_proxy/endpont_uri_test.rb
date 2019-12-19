# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::ClientServiceProxy, :endpoint_uri, :mock_spanner do
  let(:instance_id) { "my-instance-id" }

  after do
    ENV.delete "GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"
  end

  it "gets default endpoint uri" do
    client_service_proxy = Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id
    client_service_proxy.endpoint_uri.must_equal \
      Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
  end

  it "gets default endpoint uri if resource based routing disabled" do
    client_service_proxy = Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id, enable_resource_based_routing: false
    client_service_proxy.endpoint_uri.must_equal \
      Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
  end

  it "gets endpoint uri if resource based routing enabled" do
    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: ["test.host.com"]
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    client_service_proxy = Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id, enable_resource_based_routing: true

    client_service_proxy.endpoint_uri.must_equal "test.host.com"

    mock.verify
  end

  it "gets endpoint uri if resource based routing enabled using an environment variable" do
    ENV["GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"] = "YES"

    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: ["test.host.com"]
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    client_service_proxy = Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id, enable_resource_based_routing: true

    client_service_proxy.endpoint_uri.must_equal "test.host.com"

    mock.verify
  end

  it "gets default endpoint uri if resource based routing enabled and instance endpoint uris not present" do
    get_res = Google::Spanner::Admin::Instance::V1::Instance.new \
      name: instance_path(instance_id), endpoint_uris: []
    mock = Minitest::Mock.new
    mock.expect :get_instance, get_res, [
      instance_path(instance_id),
      field_mask: Google::Protobuf::FieldMask.new(paths: ["endpoint_uris"])
    ]
    spanner.service.mocked_instances = mock

    client_service_proxy = Google::Cloud::Spanner::ClientServiceProxy.new \
      spanner, instance_id, enable_resource_based_routing: true

    client_service_proxy.endpoint_uri.must_equal \
      Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS

    mock.verify
  end
end
