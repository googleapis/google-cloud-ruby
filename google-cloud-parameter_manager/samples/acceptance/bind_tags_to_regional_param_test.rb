# Copyright 2026 Google LLC
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

describe "#bind_tags_to_regional_param", :regional_parameter_manager_snippet do
  it "creates a regional parameter and binds a tag" do
    sample = SampleLoader.load "bind_tags_to_regional_param.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id, tag_value: tag_value
    end

    assert_includes out, "Created regional parameter #{parameter_name}\n"
    assert_includes out, "Created tag binding "

    param = client.get_parameter name: parameter_name
    bindings = tag_bindings_client.list_tag_bindings parent: "//parametermanager.googleapis.com/#{param.name}"
    assert_includes bindings.map(&:tag_value), tag_value
  end
end
