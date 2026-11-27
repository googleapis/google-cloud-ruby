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

# [START parametermanager_create_param_template]
require "google/cloud/parameter_manager"

##
# Create a template
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
# @param format [Google::Cloud::ParameterManager::V1::TemplateFormat::]
# The type of template format (YAML, JSON)
#
def create_param_template project_id:, template_id:, format:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  # Create the template.
  template = client.create_template parent: parent, template_id: template_id, template: { format: format }

  # Print the new template name.
  puts "Created template #{template.name} with format #{template.format}"
end
# [END parametermanager_create_param_template]

if $PROGRAM_NAME == __FILE__
  create_param_template(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift,
    format: :TEMPLATE_FORMAT_JSON
  )
end
