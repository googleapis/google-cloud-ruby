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

# [START parametermanager_get_regional_param_tags]
require "google/cloud/parameter_manager"
require "google/cloud/resource_manager/v3"

##
# Get the tags of a regional parameter
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
#
def get_regional_param_tags project_id:, location_id:, parameter_id:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Create the Resource Manager tag bindings client with the regional endpoint.
  tag_bindings_client = Google::Cloud::ResourceManager::V3::TagBindings::Client.new do |config|
    config.endpoint = "#{location_id}-cloudresourcemanager.googleapis.com"
  end

  # Get the parameter.
  name = client.parameter_path project: project_id, location: location_id, parameter: parameter_id
  param = client.get_parameter name: name

  # List the tag bindings of the parameter.
  bindings = tag_bindings_client.list_tag_bindings parent: "//parametermanager.googleapis.com/#{param.name}"

  # Print the tags of the parameter.
  bindings.each do |binding|
    puts "Found regional parameter tag #{binding.tag_value}"
  end
end
# [END parametermanager_get_regional_param_tags]

if $PROGRAM_NAME == __FILE__
  get_regional_param_tags(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift
  )
end
