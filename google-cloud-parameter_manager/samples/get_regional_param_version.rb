# Copyright 2025 Google LLC
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

# [START parametermanager_get_regional_param_version]
require "google/cloud/parameter_manager"

##
# Retrieve a regional parameter version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
#
def get_regional_param_version project_id:, location_id:, parameter_id:, version_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  name = client.parameter_version_path project: project_id, location: location_id, parameter: parameter_id,
                                       parameter_version: version_id

  # Retrieve the parameter version.
  param_version = client.get_parameter_version name: name

  # Print the retrieved parameter version name.
  state = param_version.disabled ? "disabled" : "enabled"
  puts "Found regional parameter version #{param_version.name} with state #{state}"

  # Use a guard clause to return early if the parameter version is disabled.
  return if param_version.disabled

  puts "Payload: #{param_version.payload.data}"
end
# [END parametermanager_get_regional_param_version]

if $PROGRAM_NAME == __FILE__
  get_regional_param_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
