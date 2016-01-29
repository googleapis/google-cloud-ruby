# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Logging::ResourceDescriptor, :mock_logging do
  let(:resource_descriptor_hash) { random_resource_descriptor_hash }
  let(:resource_descriptor) { Gcloud::Logging::ResourceDescriptor.from_gapi resource_descriptor_hash }

  it "knows its attributes" do
    resource_descriptor.type.must_equal        "cloudsql_database"
    resource_descriptor.name.must_equal        "Cloud SQL Database"
    resource_descriptor.description.must_equal "This resource is a Cloud SQL Database"
  end

  it "has label descriptors" do
    labels = resource_descriptor.labels
    labels.must_be_kind_of Array
    labels.wont_be :empty?
    labels.count.must_equal 2
    labels[0].must_be_kind_of Gcloud::Logging::ResourceDescriptor::LabelDescriptor
    labels[0].key.must_equal "database_id"
    labels[0].type.must_be :nil?
    labels[0].description.must_equal "The ID of the database."
    labels[1].key.must_equal "zone"
    labels[1].type.must_equal :string
    labels[1].description.must_equal "The GCP zone in which the database is running."
  end
end
