# Copyright 2025 Google LLC
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

require_relative "regional_helper"

describe "#list_regional_param_versions", :regional_parameter_manager_snippet do
  before do
    client.create_parameter parent: location_name, parameter_id: parameter_id
    client.create_parameter_version parent: parameter_name, parameter_version_id: version_id,
                                    parameter_version: { payload: { data: payload } }
    client.create_parameter_version parent: parameter_name, parameter_version_id: version_id_1,
                                    parameter_version: { payload: { data: payload } }
  end

  it "list a regional parameter versions" do
    sample = SampleLoader.load "list_regional_param_versions.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id
    end

    assert_includes out,
                    "Found regional parameter version projects/#{project_id}/locations/#{location_id}" \
                    "/parameters/#{parameter_id}/versions/#{version_id} with state enabled\n"
    assert_includes out,
                    "Found regional parameter version projects/#{project_id}/locations/#{location_id}" \
                    "/parameters/#{parameter_id}/versions/#{version_id_1} with state enabled\n"
  end
end
