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

# [START parametermanager_render_regional_param_template_version]
require "google/cloud/parameter_manager"

##
# Render a regional template version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param template_id [String] The template name (e.g. "my-template")
# @param version_id [String] The version name (e.g. "my-version")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param parameter_version_id [String] The parameter version name (e.g. "my-parameter-version")
#
def render_regional_param_template_version project_id:, location_id:, template_id:, version_id:, parameter_id:,
                                           parameter_version_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the template version.
  name = client.template_version_path project: project_id, location: location_id, template: template_id,
                                      template_version: version_id

  # Build the resource name of the parameter version that supplies the values.
  parameter_version = client.parameter_version_path project: project_id, location: location_id, parameter: parameter_id,
                                                    parameter_version: parameter_version_id

  # Render the template version.
  response = client.render_template_version name: name, parameter_version: parameter_version

  # Print the template payload and the rendered payload.
  puts "Template payload: #{response.payload.data}"
  puts "Rendered payload: #{response.rendered_payload}"
end
# [END parametermanager_render_regional_param_template_version]

if $PROGRAM_NAME == __FILE__
  render_regional_param_template_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    template_id: ARGV.shift,
    version_id: ARGV.shift,
    parameter_id: ARGV.shift,
    parameter_version_id: ARGV.shift
  )
end
