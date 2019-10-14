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

require "grafeas"

describe "GrafeasService V1 smoke test" do
  it "runs one smoke test with list_occurrences" do
    client = Grafeas.new(version: :v1)
    parent = Grafeas::V1::GrafeasClient.project_path(ENV["GRAFEAS_PROJECT"])
    results = client.list_occurrences(parent, page_size: 2)
    page = results.page
    assert(page.to_a.size > 0)
  end
end
