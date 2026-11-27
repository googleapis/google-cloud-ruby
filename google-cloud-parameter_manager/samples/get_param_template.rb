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

# [START parametermanager_get_param_template]
require "google/cloud/parameter_manager"

##
# Get a template
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
#
def get_param_template project_id:, template_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the template.
  name = client.template_path project: project_id, location: "global", template: template_id

  # Get the template.
  template = client.get_template name: name

  # Print the template details.
  puts "Got template #{template.name} with format #{template.format}"
end
# [END parametermanager_get_param_template]

if $PROGRAM_NAME == __FILE__
  get_param_template(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift
  )
end
