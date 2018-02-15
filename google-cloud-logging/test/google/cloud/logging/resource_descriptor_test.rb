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

describe Google::Cloud::Logging::ResourceDescriptor, :mock_logging do
  let(:resource_descriptor_hash) { random_resource_descriptor_hash }
  let(:resource_descriptor_json) { resource_descriptor_hash.to_json }
  let(:resource_descriptor_grpc) { Google::Api::MonitoredResourceDescriptor.decode_json resource_descriptor_json }
  let(:resource_descriptor) { Google::Cloud::Logging::ResourceDescriptor.from_grpc resource_descriptor_grpc }

  it "knows its attributes" do
    resource_descriptor.type.must_equal        "cloudsql_database"
    resource_descriptor.name.must_equal        "Cloud SQL Database"
    resource_descriptor.description.must_equal "This resource is a Cloud SQL Database"
  end

  it "has label descriptors" do
    labels = resource_descriptor.labels
    labels.must_be_kind_of Array
    labels.wont_be :empty?
    labels.count.must_equal 4
    labels[0].must_be_kind_of Google::Cloud::Logging::ResourceDescriptor::LabelDescriptor
    labels[0].key.must_equal "database_id"
    labels[0].type.must_equal :string # defaults to string...
    labels[0].description.must_equal "The ID of the database."
    labels[1].key.must_equal "zone"
    labels[1].type.must_equal :string
    labels[1].description.must_equal "The GCP zone in which the database is running."
    labels[2].key.must_equal "active"
    labels[2].type.must_equal :boolean
    labels[2].description.must_equal "Whether the database is active."
    labels[3].key.must_equal "max_connections"
    labels[3].type.must_equal :integer
    labels[3].description.must_equal "The maximum number of connections it supports."
  end
end
