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

describe "#get_regional_param_template", :regional_parameter_manager_snippet do
  before do
    client.create_template parent: location_name, template_id: template_id,
                           template: { format: :TEMPLATE_FORMAT_JSON }
  end

  it "gets a regional template" do
    sample = SampleLoader.load "get_regional_param_template.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, template_id: template_id
    end

    assert_equal "Got regional template #{template_name} with format TEMPLATE_FORMAT_JSON\n", out
  end
end
