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

describe Google::Cloud::Logging::Resource, :mock_logging do
  let(:resource_hash) { random_resource_hash }
  let(:resource_grpc) { Google::Api::MonitoredResource.new resource_hash }
  let(:resource) { Google::Cloud::Logging::Resource.from_grpc resource_grpc }

  it "knows its attributes" do
    _(resource.type).must_equal resource_hash[:type]
    _(resource.labels.keys.sort).must_equal   resource_hash[:labels].keys.sort
    _(resource.labels.values.sort).must_equal resource_hash[:labels].values.sort
  end

  it "can export to a grpc object" do
    grpc = resource.to_grpc
    _(grpc.type).must_equal resource_hash[:type]
    _(grpc.labels.keys.sort).must_equal   resource_hash[:labels].keys.sort
    _(grpc.labels.values.sort).must_equal resource_hash[:labels].values.sort
  end
end
