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

# [START storage_control_update_rapid_cache]
require "google/cloud/storage/control"

# Updates the time to live (TTL) of a Rapid Cache.
#
# @param bucket_name [String] The name of the bucket.
# @param cache_id [String] The ID of the Rapid Cache.
# @param ttl_seconds [Integer] The new TTL for cache entries, in seconds. The
#   TTL must be between 1 hour and 7 days.
#
# @example
#   update_rapid_cache bucket_name: "your-unique-bucket-name",
#                      cache_id: "your-rapid-cache-id",
#                      ttl_seconds: 172_800 # 2 days
#
def update_rapid_cache bucket_name:, cache_id:, ttl_seconds:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  name = storage_control_client.rapid_cache_path project: "_",
                                                 bucket: bucket_name,
                                                 rapid_cache: cache_id

  rapid_cache = Google::Cloud::Storage::Control::V2::RapidCache.new(
    name: name,
    ttl: Google::Protobuf::Duration.new(seconds: ttl_seconds)
  )
  # Only the fields listed in the update mask are changed.
  update_mask = Google::Protobuf::FieldMask.new paths: ["ttl"]
  request = Google::Cloud::Storage::Control::V2::UpdateRapidCacheRequest.new(
    rapid_cache: rapid_cache,
    update_mask: update_mask
  )

  # Updating a Rapid Cache is a long-running operation. Poll the operation
  # until it completes.
  operation = storage_control_client.update_rapid_cache request
  until operation.done?
    sleep 1
    operation = storage_control_client.operations_client.get_operation name: operation.name
  end
  raise operation.error.message if operation.error?

  result = operation.response
  puts "Updated Rapid Cache: #{result.name}"
  puts "TTL: #{result.ttl.seconds} seconds"
end
# [END storage_control_update_rapid_cache]

if $PROGRAM_NAME == __FILE__
  update_rapid_cache bucket_name: ARGV.shift, cache_id: ARGV.shift, ttl_seconds: Integer(ARGV.shift)
end
