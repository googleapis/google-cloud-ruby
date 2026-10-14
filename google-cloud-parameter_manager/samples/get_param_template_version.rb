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

# [START parametermanager_get_param_template_version]
require "google/cloud/parameter_manager"

##
# Get a template version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param template_id [String] The template name (e.g. "my-template")
# @param version_id [String] The version name (e.g. "my-version")
#
def get_param_template_version project_id:, template_id:, version_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the template version.
  name = client.template_version_path project: project_id, location: "global", template: template_id,
                                      template_version: version_id

  # Get the template version.
  version = client.get_template_version name: name

  # Print the template version details.
  puts "Got template version #{version.name}"
  puts "Payload: #{version.payload.data}"
end
# [END parametermanager_get_param_template_version]

if $PROGRAM_NAME == __FILE__
  get_param_template_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    template_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
