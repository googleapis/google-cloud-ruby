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

# [START parametermanager_disable_param_version]
require "google/cloud/parameter_manager"

##
# Disable a parameter version
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
#
def disable_param_version project_id:, parameter_id:, version_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  name = client.parameter_version_path project: project_id, location: "global", parameter: parameter_id,
                                       parameter_version: version_id

  parameter_version = {
    name: name,
    disabled: true
  }

  update_mask = {
    paths: ["disabled"]
  }

  # Disabled the parameter version
  param_version = client.update_parameter_version parameter_version: parameter_version, update_mask: update_mask

  # Print the parameter version name.
  puts "Disabled parameter version #{version_id} for parameter #{parameter_id}"
end
# [END parametermanager_disable_param_version]

if $PROGRAM_NAME == __FILE__
  disable_param_version(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
