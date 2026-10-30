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

# [START parametermanager_get_param_version_verify_checksum]
require "google/cloud/parameter_manager"
require "digest/crc32c"

##
# Get a parameter version and verify its checksum
#
# @param project_id [String] The Google Cloud project (e.g. "my-project")
# @param parameter_id [String] The parameter name (e.g. "my-parameter")
# @param version_id [String] The version name (e.g. "my-version")
#
def get_param_version_verify_checksum project_id:, parameter_id:, version_id:
  # Create a Parameter Manager client.
  client = Google::Cloud::ParameterManager.parameter_manager

  # Build the resource name of the parameter version.
  name = client.parameter_version_path project: project_id, location: "global", parameter: parameter_id,
                                       parameter_version: version_id

  # Get the parameter version with the payload and checksum.
  param_version = client.get_parameter_version name: name, view: :FULL

  # Verify the payload checksum.
  computed_crc32c = Digest::CRC32c.checksum param_version.payload.data
  raise "Checksum mismatch for #{param_version.name}" unless computed_crc32c == param_version.payload.data_crc32c

  # Print the verification result and the checksum source.
  puts "Verified checksum for parameter version #{param_version.name}"
  puts "Checksum source: #{param_version.checksum_source}"
end
# [END parametermanager_get_param_version_verify_checksum]

if $PROGRAM_NAME == __FILE__
  get_param_version_verify_checksum(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT"),
    parameter_id: ARGV.shift,
    version_id: ARGV.shift
  )
end
