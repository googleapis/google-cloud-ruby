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

# [START parametermanager_update_param_kms_key]
require "google/cloud/parameter_manager"

##
# Update the KMS key of a parameter
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param kms_key [String] The KMS key name
# (e.g. "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key")
#
def update_param_kms_key project_id:, parameter_id:, kms_key:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  name = client.parameter_path project: project_id, location: "global", parameter: parameter_id

  parameter = {
    name: name,
    kms_key: kms_key
  }

  update_mask = {
    paths: ["kms_key"]
  }

  # Update the parameter.
  param = client.update_parameter parameter: parameter, update_mask: update_mask

  # Print the parameter name.
  puts "Updated parameter #{param.name} with kms_key #{param.kms_key}"
end
# [END parametermanager_update_param_kms_key]

if $PROGRAM_NAME == __FILE__
  update_param_kms_key(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    kms_key: ARGV.shift
  )
end
