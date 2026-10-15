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

describe "#create_regional_param_with_tags", :regional_parameter_manager_snippet do
  it "creates a regional parameter with tags" do
    sample = SampleLoader.load "create_regional_param_with_tags.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id, tag_key: tag_key,
                 tag_value: tag_value
    end

    assert_equal "Created regional parameter #{parameter_name} with tag #{tag_key}: #{tag_value}\n", out

    param = client.get_parameter name: parameter_name
    bindings = tag_bindings_client.list_tag_bindings parent: "//parametermanager.googleapis.com/#{param.name}"
    assert_includes bindings.map(&:tag_value), tag_value
  end
end
