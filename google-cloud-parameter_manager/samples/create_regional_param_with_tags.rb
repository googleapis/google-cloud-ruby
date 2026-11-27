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

# [START parametermanager_create_regional_param_with_tags]
require "google/cloud/parameter_manager"

##
# Create a regional parameter with tags
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param location_id [String] The location name (e.g. "us-central1")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param tag_key [String] The tag key (e.g. "tagKeys/123456789")
# @param tag_value [String] The tag value (e.g. "tagValues/123456789")
#
def create_regional_param_with_tags project_id:, location_id:, parameter_id:, tag_key:, tag_value:
  # Endpoint for the regional parameter manager service.
  api_endpoint = "parametermanager.#{location_id}.rep.googleapis.com"

  # Create the Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: location_id

  # Create the parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id,
                                  parameter: { tags: { tag_key => tag_value } }

  # Print the new parameter name.
  puts "Created regional parameter #{param.name} with tag #{tag_key}: #{tag_value}"
end
# [END parametermanager_create_regional_param_with_tags]

if $PROGRAM_NAME == __FILE__
  create_regional_param_with_tags(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    location_id: ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1",
    parameter_id: ARGV.shift,
    tag_key: ARGV.shift,
    tag_value: ARGV.shift
  )
end
