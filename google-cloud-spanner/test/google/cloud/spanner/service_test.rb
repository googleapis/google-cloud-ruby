# Copyright 2019 Google LLC
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

describe Google::Cloud::Spanner::Service, :mock_spanner do
  it "creates and cache service client connection based on endpoint uri" do
    endpoint_uri = Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
    api_call_count = 0
    spanner_client_newe_stub = proc do |credentials: nil, timeout: nil,
        client_config: nil, service_address: nil, service_port: nil,
        lib_name: nil, lib_version: nil|
      service_address.must_equal endpoint_uri
      api_call_count += 1
      OpenStruct.new(endpoint_uri: service_address)
    end

    Google::Cloud::Spanner::V1::SpannerClient.stub :new, spanner_client_newe_stub do
      spanner.service.service endpoint_uri
      spanner_clients = spanner.service.instance_variable_get("@spanner_clients")
      spanner_clients.must_include endpoint_uri
      spanner_clients.length.must_equal 1
      api_call_count.must_equal 1

      spanner.service.service endpoint_uri
      api_call_count.must_equal 1
    end
  end

  it "creates and cache service client connection for diffrent endpoint uris" do
    endpoint_uris = ["name1.test-spanner.com", "nam2.test-spanner.com"]
    api_call_count = 0
    spanner_client_newe_stub = proc do |credentials: nil, timeout: nil,
        client_config: nil, service_address: nil, service_port: nil,
        lib_name: nil, lib_version: nil|
      endpoint_uris.must_include service_address
      api_call_count += 1
      OpenStruct.new(endpoint_uri: service_address)
    end

    Google::Cloud::Spanner::V1::SpannerClient.stub :new, spanner_client_newe_stub do
      spanner.service.service endpoint_uris[0]
      spanner.service.service endpoint_uris[1]
      spanner_clients = spanner.service.instance_variable_get("@spanner_clients")
      spanner_clients.length.must_equal 2

      endpoint_uris.each_with_index do |endpoint_uri|
        spanner_clients.must_include endpoint_uri
      end

      api_call_count.must_equal 2
    end
  end
end
