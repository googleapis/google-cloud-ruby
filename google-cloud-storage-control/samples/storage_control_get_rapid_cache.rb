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

# [START storage_control_get_rapid_cache]
require "google/cloud/storage/control"

# Retrieves the metadata of a Rapid Cache.
#
# @param bucket_name [String] The name of the bucket.
# @param cache_id [String] The ID of the Rapid Cache, which is the same as its
#   zone (e.g., "us-east1-b").
#
# @example
#   get_rapid_cache bucket_name: "your-unique-bucket-name", cache_id: "us-east1-b"
#
def get_rapid_cache bucket_name:, cache_id:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  name = storage_control_client.rapid_cache_path project: "_",
                                                 bucket: bucket_name,
                                                 rapid_cache: cache_id

  request = Google::Cloud::Storage::Control::V2::GetRapidCacheRequest.new name: name
  rapid_cache = storage_control_client.get_rapid_cache request

  puts "Got Rapid Cache: #{rapid_cache.name}"
  puts "Zone: #{rapid_cache.zone}"
  puts "Cache type: #{rapid_cache.cache_type}"
  puts "State: #{rapid_cache.state}"
end
# [END storage_control_get_rapid_cache]

get_rapid_cache bucket_name: ARGV.shift, cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
