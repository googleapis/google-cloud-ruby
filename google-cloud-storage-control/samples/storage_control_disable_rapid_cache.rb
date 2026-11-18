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

# [START storage_control_disable_rapid_cache]
require "google/cloud/storage/control"

# Disables a Rapid Cache.
#
# @param bucket_name [String] The name of the bucket.
# @param cache_id [String] The ID of the Rapid Cache, which is the same as its
#   zone (e.g., "us-east1-b").
#
# @example
#   disable_rapid_cache bucket_name: "your-unique-bucket-name", cache_id: "us-east1-b"
#
def disable_rapid_cache bucket_name:, cache_id:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  name = storage_control_client.rapid_cache_path project: "_",
                                                 bucket: bucket_name,
                                                 rapid_cache: cache_id

  request = Google::Cloud::Storage::Control::V2::DisableRapidCacheRequest.new name: name

  # Disabling a Rapid Cache is a long-running operation. The cache state
  # becomes "disabled" within seconds, but the operation only completes once
  # the cache has been fully removed, which can take over an hour. Start the
  # operation without waiting for it, and use get_rapid_cache to check the
  # cache state.
  operation = storage_control_client.disable_rapid_cache request

  puts "Started disabling Rapid Cache: #{name}"
  puts "Operation: #{operation.name}"
end
# [END storage_control_disable_rapid_cache]

disable_rapid_cache bucket_name: ARGV.shift, cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
