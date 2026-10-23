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

describe "#get_regional_param_tags", :regional_parameter_manager_snippet do
  before do
    param = client.create_parameter parent: location_name, parameter_id: parameter_id
    tag_bindings_client.create_tag_binding(
      tag_binding: { parent: "//parametermanager.googleapis.com/#{param.name}", tag_value: tag_value }
    ).wait_until_done!
  end

  it "gets the tags of a regional parameter" do
    sample = SampleLoader.load "get_regional_param_tags.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, parameter_id: parameter_id
    end

    assert_includes out, "Found regional parameter tag #{tag_value}\n"
  end
end
