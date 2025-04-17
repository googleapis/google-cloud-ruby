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

# [START parametermanager_create_param_with_kms_key]
require "google/cloud/parameter_manager"

##
# Create a parameter with a KMS key
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param kms_key [String] The KMS key name
# (e.g. "projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key")
#
def create_param_with_kms_key project_id:, parameter_id:, kms_key:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: "global"

  parameter = {
    kms_key: kms_key
  }

  # Create the parameter.
  param = client.create_parameter parent: parent, parameter_id: parameter_id, parameter: parameter

  # Print the new parameter name.
  puts "Created parameter #{param.name} with kms_key #{param.kms_key}"
end
# [END parametermanager_create_param_with_kms_key]

if $PROGRAM_NAME == __FILE__
  create_param_with_kms_key(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    kms_key: ARGV.shift
  )
end
