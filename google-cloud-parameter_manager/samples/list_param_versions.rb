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

# [START parametermanager_list_param_versions]
require "google/cloud/parameter_manager"

##
# List a parameter versions
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter ID (e.g. "my-parameter")
#
def list_param_versions project_id:, parameter_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.parameter_path project: project_id, location: "global", parameter: parameter_id

  # List the parameter versions.
  param_version_list = client.list_parameter_versions parent: parent

  # Print out all parameter versions.
  param_version_list.each do |param_version|
    puts "Found parameter version #{param_version.name} with state #{param_version.disabled ? 'disabled' : 'enabled'}"
  end
end
# [END parametermanager_list_param_versions]

if $PROGRAM_NAME == __FILE__
  list_param_versions(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift
  )
end
