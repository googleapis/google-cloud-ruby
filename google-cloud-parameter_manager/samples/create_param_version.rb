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

# [START parametermanager_create_param_version]
require "google/cloud/parameter_manager"

##
# Create a parameter version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
# @param payload [String] The parameter payload (e.g. "test123")
#
def create_param_version project_id:, parameter_id:, version_id:, payload:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.parameter_path project: project_id, location: "global", parameter: parameter_id

  parameter_version = {
    payload: {
      data: payload
    }
  }

  # Create the parameter version.
  param_version = client.create_parameter_version parent: parent, parameter_version_id: version_id,
                                                  parameter_version: parameter_version

  # Print the new parameter version name.
  puts "Created parameter version #{param_version.name}"
end
# [END parametermanager_create_param_version]

if $PROGRAM_NAME == __FILE__
  create_param_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    version_id: ARGV.shift,
    payload: ARGV.shift
  )
end
