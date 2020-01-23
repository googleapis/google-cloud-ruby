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

require "spanner_helper"
require "concurrent"

describe "Spanner Client", :spanner do
  let(:spanner) { $spanner }
  let(:instance_id) { $spanner_instance_id }
  let(:database_id) { $spanner_database_id }

  it "create client connection without resource based routing" do
    client = spanner.client instance_id, database_id
    client.service.host.must_equal Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
  end

  it "create client connection with resource based routing" do
    client = spanner.client instance_id, database_id, enable_resource_based_routing: true
    client.resource_based_routing_enabled?.must_equal true
    instance = spanner.instance instance_id, fields: ["endpoint_uris"]
    # Set to default if no endpoint uri present.
    host = instance.endpoint_uris.first || Google::Cloud::Spanner::V1::SpannerClient::SERVICE_ADDRESS
    client.service.host.must_equal host
  end
end
