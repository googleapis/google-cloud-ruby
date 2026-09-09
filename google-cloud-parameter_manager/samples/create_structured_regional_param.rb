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

# [START parametermanager_create_structured_regional_param]
require "google/cloud/parameter_manager"

##
# Create a regional parameter
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param format [Google::Cloud::ParameterManager::V1::ParameterFormat::]
# The type of parameter format (UNFORMATTED, YAML, JSON)
#
def create_structured_regional_param project_id:, location_id:, parameter_id:, format:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: location_id

  parameter = {
    format: format
  }

  # Create the parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id, parameter: parameter

  # Print the new parameter name.
  puts "Created regional parameter #{param.name} with format #{param.format}"
end
# [END parametermanager_create_structured_regional_param]

if $PROGRAM_NAME == __FILE__
  create_structured_regional_param(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift,
    format: Google::Cloud::ParameterManager::V1::ParameterFormat::JSON
  )
end
