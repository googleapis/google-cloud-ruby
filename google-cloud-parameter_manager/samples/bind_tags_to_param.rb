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

# [START parametermanager_bind_tags_to_param]
require "google/cloud/parameter_manager"
require "google/cloud/resource_manager/v3"

##
# Create a parameter and bind tags to it
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param tag_value [String] The tag value (e.g. "tagValues/123456789")
#
def bind_tags_to_param project_id:, parameter_id:, tag_value:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Create the Resource Manager tag bindings client.
  tag_bindings_client = Google::Cloud::ResourceManager::V3::TagBindings::Client.new

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  # Create the parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id

  # Print the new parameter name.
  puts "Created parameter #{param.name}"

  # Create the tag binding and wait for the operation to complete.
  operation = tag_bindings_client.create_tag_binding(
    tag_binding: {
      parent:    "//parametermanager.googleapis.com/#{param.name}",
      tag_value: tag_value
    }
  )
  operation.wait_until_done!

  # Print the tag binding.
  puts "Created tag binding #{operation.response.name}"
end
# [END parametermanager_bind_tags_to_param]

if $PROGRAM_NAME == __FILE__
  bind_tags_to_param(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    tag_value: ARGV.shift
  )
end
