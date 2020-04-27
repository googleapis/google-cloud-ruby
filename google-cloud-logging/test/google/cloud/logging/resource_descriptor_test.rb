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
  let(:resource_descriptor_grpc) { Google::Api::MonitoredResourceDescriptor.new resource_descriptor_hash }
  let(:resource_descriptor) { Google::Cloud::Logging::ResourceDescriptor.from_grpc resource_descriptor_grpc }

  it "knows its attributes" do
    _(resource_descriptor.type).must_equal        "cloudsql_database"
    _(resource_descriptor.name).must_equal        "Cloud SQL Database"
    _(resource_descriptor.description).must_equal "This resource is a Cloud SQL Database"
  end

  it "has label descriptors" do
    labels = resource_descriptor.labels
    _(labels).must_be_kind_of Array
    _(labels).wont_be :empty?
    _(labels.count).must_equal 4
    _(labels[0]).must_be_kind_of Google::Cloud::Logging::ResourceDescriptor::LabelDescriptor
    _(labels[0].key).must_equal "database_id"
    _(labels[0].type).must_equal :string # defaults to string...
    _(labels[0].description).must_equal "The ID of the database."
    _(labels[1].key).must_equal "zone"
    _(labels[1].type).must_equal :string
    _(labels[1].description).must_equal "The GCP zone in which the database is running."
    _(labels[2].key).must_equal "active"
    _(labels[2].type).must_equal :boolean
    _(labels[2].description).must_equal "Whether the database is active."
    _(labels[3].key).must_equal "max_connections"
    _(labels[3].type).must_equal :integer
    _(labels[3].description).must_equal "The maximum number of connections it supports."
  end
end
