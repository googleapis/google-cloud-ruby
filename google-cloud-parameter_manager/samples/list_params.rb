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

# [START parametermanager_list_params]
require "google/cloud/parameter_manager"

##
# List a parameters
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
#
def list_params project_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  # List the parameters.
  param_list = client.list_parameters parent: parent

  # Print out all parameters.
  param_list.each do |param|
    puts "Found parameter #{param.name} with format #{param.format}"
  end
end
# [END parametermanager_list_params]

if $PROGRAM_NAME == __FILE__
  list_params(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT")
  )
end
