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

# [START parametermanager_remove_regional_param_kms_key]
require "google/cloud/parameter_manager"

##
# Remove the KMS key from a regional parameter
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
#
def remove_regional_param_kms_key project_id:, location_id:, parameter_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  name = client.parameter_path project: project_id, location: location_id, parameter: parameter_id

  parameter = {
    name: name
  }

  update_mask = {
    paths: ["kms_key"]
  }

  # Update the parameter.
  param = client.update_parameter parameter: parameter, update_mask: update_mask

  # Print the parameter name.
  puts "Removed kms_key for regional parameter #{param.name}"
end
# [END parametermanager_remove_regional_param_kms_key]

if $PROGRAM_NAME == __FILE__
  remove_regional_param_kms_key(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift
  )
end
