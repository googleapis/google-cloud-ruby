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

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/cloud/automl"

describe "AutoML V1beta1 smoke test" do
  it "runs one smoke test with list_datasets" do
    client = Google::Cloud::AutoML.auto_ml
    parent = client.location_path project: ENV["AUTOML_PROJECT"], location: "us-central1"
    results = client.list_datasets parent: parent, page_size: 2
    page = results.page
    assert(page.to_a.size > 0)
  end
end
