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

describe Gcloud::Logging::Resource, :mock_logging do
  let(:resource) { Gcloud::Logging::Resource.from_gapi resource_hash }
  let(:resource_hash) { random_resource_hash }

  it "knows its attributes" do
    resource.type.must_equal        resource_hash["type"]
    resource.name.must_equal        resource_hash["displayName"]
    resource.description.must_equal resource_hash["description"]
    resource.labels.must_equal      resource_hash["labels"]
  end
end
