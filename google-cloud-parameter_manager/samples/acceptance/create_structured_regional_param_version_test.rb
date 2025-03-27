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

describe "#create_structured_regional_param_version", :regional_parameter_manager_snippet do
  before do
    client.create_parameter parent: location_name, parameter_id: parameter_id,
                            parameter: { format: format }
  end

  it "creates a structured regional parameter version" do
    sample = SampleLoader.load "create_structured_regional_param_version.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, parameter_id: parameter_id, location_id: location_id, version_id: version_id,
                 json_payload: json_payload
    end

    assert_equal "Created regional parameter version projects/#{project_id}/locations/#{location_id}/" \
                 "parameters/#{parameter_id}/versions/#{version_id}\n",
                 out
  end
end
