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

# [START parametermanager_quickstart]
require "google/cloud/parameter_manager"

##
# Create a parameter
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
#
def quickstart project_id:, parameter_id:, version_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  parameter = {
    format: Google::Cloud::ParameterManager::V1::ParameterFormat::JSON
  }

  # Create the parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id, parameter: parameter

  # Print the new parameter name.
  puts "Created parameter #{param.name}\n"

  parameter_version = {
    payload: {
      data: '{"username": "test-user", "host": "localhost"}'
    }
  }

  param_version = client.create_parameter_version parent: param.name, parameter_version_id: version_id,
                                                  parameter_version: parameter_version

  # Print the new parameter version name.
  puts "Created parameter version #{param_version.name}\n"

  # Retrieve the parameter version.
  param_version = client.get_parameter_version name: param_version.name

  # Print the parameter version payload.
  puts "Parameter version #{param_version.name} with payload #{param_version.payload.data}\n"
end
# [END parametermanager_quickstart]

if $PROGRAM_NAME == __FILE__
  quickstart(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
