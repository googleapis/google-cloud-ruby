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

# [START parametermanager_list_regional_param_versions]
require "google/cloud/parameter_manager"

##
# List a regional parameter versions
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter ID (e.g. "my-parameter")
#
def list_regional_param_versions project_id:, location_id:, parameter_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  parent = client.parameter_path project: project_id, location: location_id, parameter: parameter_id

  # List the parameter versions.
  param_version_list = client.list_parameter_versions parent: parent

  # Print out all parameter versions.
  param_version_list.each do |param_version|
    state = param_version.disabled ? "disabled" : "enabled"
    puts "Found regional parameter version #{param_version.name} with state #{state}"
  end
end
# [END parametermanager_list_regional_param_versions]

if $PROGRAM_NAME == __FILE__
  list_regional_param_versions(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift
  )
end
