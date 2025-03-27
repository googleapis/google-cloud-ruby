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

describe "#regional_quickstart", :regional_parameter_manager_snippet do
  it "regional_quickstart" do
    sample = SampleLoader.load "regional_quickstart.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id, version_id: version_id
    end

    assert_includes out,
                    "Created regional parameter projects/#{project_id}/locations/#{location_id}" \
                    "/parameters/#{parameter_id}\n"
    assert_includes out,
                    "Created regional parameter version projects/#{project_id}/locations/#{location_id}" \
                    "/parameters/#{parameter_id}/versions/#{version_id}\n"
    assert_includes out,
                    "Regional parameter version projects/#{project_id}/locations/#{location_id}" \
                    "/parameters/#{parameter_id}/versions/#{version_id} with payload #{json_payload}\n"
  end
end
