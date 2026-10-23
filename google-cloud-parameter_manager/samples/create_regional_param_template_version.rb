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

# [START parametermanager_create_regional_param_template_version]
require "google/cloud/parameter_manager"

##
# Create a regional template version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param template_id [String] The template name (e.g. "my-template")
# @param version_id [String] The version name (e.g. "my-version")
#
def create_regional_param_template_version project_id:, location_id:, template_id:, version_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the template.
  parent = client.template_path project: project_id, location: location_id, template: template_id

  # Define the template payload with placeholders.
  payload = '{"username": "{{.username}}", "host": "{{.host}}"}'
  template_version = {
    payload: {
      data: payload
    }
  }

  # Create the template version.
  version = client.create_template_version parent: parent, template_version_id: version_id,
                                           template_version: template_version

  # Print the new template version name.
  puts "Created regional template version #{version.name}"
end
# [END parametermanager_create_regional_param_template_version]

if $PROGRAM_NAME == __FILE__
  create_regional_param_template_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    template_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
