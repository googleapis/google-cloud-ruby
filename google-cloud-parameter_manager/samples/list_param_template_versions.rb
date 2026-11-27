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

# [START parametermanager_list_param_template_versions]
require "google/cloud/parameter_manager"

##
# List template versions
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
#
def list_param_template_versions project_id:, template_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the template.
  parent = client.template_path project: project_id, location: "global", template: template_id

  # List the template versions.
  versions = client.list_template_versions parent: parent

  # Print out all template versions.
  versions.each do |version|
    puts "Found template version #{version.name}"
  end
end
# [END parametermanager_list_param_template_versions]

if $PROGRAM_NAME == __FILE__
  list_param_template_versions(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift
  )
end
