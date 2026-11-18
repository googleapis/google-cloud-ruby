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

# [START storage_control_create_rapid_cache]
require "google/cloud/storage/control"

# Creates a Rapid Cache for a bucket in the given zone.
#
# @param bucket_name [String] The name of the bucket. Rapid Cache Ultra
#   requires a bucket with hierarchical namespace enabled.
# @param zone [String] The zone in which to create the Rapid Cache. The zone
#   must be in the same region as the bucket (e.g., "us-east1-b").
#
# @example
#   create_rapid_cache bucket_name: "your-unique-bucket-name", zone: "us-east1-b"
#
def create_rapid_cache bucket_name:, zone:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = storage_control_client.bucket_path project: "_", bucket: bucket_name
  # The Rapid Cache ID must be the same as the zone.
  cache_id = zone
  name = storage_control_client.rapid_cache_path project: "_",
                                                 bucket: bucket_name,
                                                 rapid_cache: cache_id

  # Only the required fields are set. Optional settings, such as the time to
  # live (TTL), use their default values and can be changed later with
  # UpdateRapidCache.
  rapid_cache = Google::Cloud::Storage::Control::V2::RapidCache.new(
    name: name,
    zone: zone,
    cache_type: "rapid-cache-ultra"
  )
  request = Google::Cloud::Storage::Control::V2::CreateRapidCacheRequest.new(
    parent: parent,
    rapid_cache: rapid_cache
  )

  # Creating a Rapid Cache is a long-running operation. Poll the operation
  # until it completes.
  operation = storage_control_client.create_rapid_cache request
  until operation.done?
    sleep 1
    operation = storage_control_client.operations_client.get_operation name: operation.name
  end
  raise operation.error.message if operation.error?

  result = operation.response
  puts "Created Rapid Cache: #{result.name}"
  puts "Cache type: #{result.cache_type}"
end
# [END storage_control_create_rapid_cache]

create_rapid_cache bucket_name: ARGV.shift, zone: ARGV.shift if $PROGRAM_NAME == __FILE__
