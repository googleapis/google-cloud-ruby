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

# [START parametermanager_template_quickstart]
require "google/cloud/parameter_manager"

##
# Create a template, a parameter and render the template
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
#
def template_quickstart project_id:, template_id:, parameter_id:, version_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  # Create a template in JSON format.
  template = client.create_template parent: parent, template_id: template_id,
                                    template: { format: :TEMPLATE_FORMAT_JSON }
  puts "Created template #{template.name}"

  # Create a template version with placeholders.
  template_payload = '{"username": "{{.username}}", "host": "{{.host}}"}'
  template_version = client.create_template_version parent: template.name, template_version_id: version_id,
                                                    template_version: { payload: { data: template_payload } }
  puts "Created template version #{template_version.name}"

  # Create a JSON parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id, parameter: { format: :JSON }
  puts "Created parameter #{param.name}"

  # Create a parameter version that holds the values for the placeholders.
  values = '{"username": "test-user", "host": "localhost"}'
  param_version = client.create_parameter_version parent: param.name, parameter_version_id: version_id,
                                                  parameter_version: { payload: { data: values } }
  puts "Created parameter version #{param_version.name}"

  # Render the template version with the parameter version's values.
  response = client.render_template_version name: template_version.name, parameter_version: param_version.name
  puts "Rendered payload: #{response.rendered_payload}"
end
# [END parametermanager_template_quickstart]

if $PROGRAM_NAME == __FILE__
  template_quickstart(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift,
    parameter_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
