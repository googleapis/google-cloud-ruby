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

require_relative "helper"

describe "#render_param_template_version", :parameter_manager_snippet do
  before do
    client.create_template parent: location_name, template_id: template_id,
                           template: { format: :TEMPLATE_FORMAT_JSON }
    client.create_template_version parent: template_name, template_version_id: template_version_id,
                                   template_version: { payload: { data: template_payload } }
    client.create_parameter parent: location_name, parameter_id: parameter_id, parameter: { format: format }
    client.create_parameter_version parent: parameter_name, parameter_version_id: version_id,
                                    parameter_version: { payload: { data: json_payload } }
  end

  it "renders a template version" do
    sample = SampleLoader.load "render_param_template_version.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, template_id: template_id, version_id: template_version_id,
                 parameter_id: parameter_id, parameter_version_id: version_id
    end

    assert_includes out, "Template payload: #{template_payload}\n"
    assert_includes out, "Rendered payload: {\"username\": \"test-user\", \"host\": \"localhost\"}\n"
  end
end
