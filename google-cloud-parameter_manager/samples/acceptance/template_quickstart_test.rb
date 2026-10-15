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

describe "#template_quickstart", :parameter_manager_snippet do
  let(:version_id) { template_version_id }

  it "runs the template quickstart" do
    sample = SampleLoader.load "template_quickstart.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, template_id: template_id, parameter_id: parameter_id, version_id: version_id
    end

    assert_includes out, "Created template #{template_name}\n"
    assert_includes out, "Created template version #{template_version_name}\n"
    assert_includes out, "Created parameter #{parameter_name}\n"
    assert_includes out, "Created parameter version #{parameter_version_name}\n"
    assert_includes out, "Rendered payload: {\"username\": \"test-user\", \"host\": \"localhost\"}\n"
  end
end
