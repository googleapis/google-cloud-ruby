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

# [START storage_control_update_anywhere_cache]
require "google/cloud/storage/control"

# Updates an existing Anywhere Cache for a specified
# bucket. After initiating the update, it polls the cache's status with
# exponential backoff until the cache state becomes "running".
#
# @param bucket_name [String] The name of the GCS bucket containing the cache.
# @param anywhere_cache_id [String] The unique identifier for the Anywhere Cache.
#   e.g. "us-east1-b"
#
# @example
#   update_anywhere_cache(
#     bucket_name: "your-unique-bucket-name",
#     anywhere_cache_id: "us-east1-b"
#   )
#
def update_anywhere_cache bucket_name:, anywhere_cache_id:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{anywhere_cache_id}"
  ttl_in_seconds = 7200

  anywhere_cache = Google::Cloud::Storage::Control::V2::AnywhereCache.new(
    name: name,
    ttl: ttl_in_seconds
  )
  mask = Google::Protobuf::FieldMask.new paths: ["ttl"]
  # Create a request.
  request = Google::Cloud::Storage::Control::V2::UpdateAnywhereCacheRequest.new(
    anywhere_cache: anywhere_cache,
    update_mask: mask
  )
  # The request updates the cache in the specified bucket.
  # The cache is identified by the specified ID.
  begin
    operation = storage_control_client.update_anywhere_cache request
    puts "AnywhereCache operation created - #{operation.name}"
    get_request = Google::Cloud::Storage::Control::V2::GetAnywhereCacheRequest.new(
      name: name
    )
    result = storage_control_client.get_anywhere_cache get_request
    min_delay = 30 # 30 seconds
    max_delay = 600 # 10 minutes
    start_time = Time.now
    while result.state&.downcase != "running"
      unless ["paused", "disabled", "creating"].include? result.state&.downcase
        raise Google::Cloud::Error,
              "AnywhereCache operation failed on the backend with state #{result.state&.downcase}."
      end
      puts "Cache not running yet, current state is #{result.state&.downcase}. Retrying in #{min_delay} seconds."
      sleep min_delay
      min_delay = [min_delay * 2, max_delay].min # Exponential backoff with a max delay
      result = storage_control_client.get_anywhere_cache get_request
    end
    end_time = Time.now
    duration = end_time - start_time
    puts "Total waiting time : #{duration.round(2)} seconds."
    message = "Successfully updated anywhereCache - #{result.name}."
  rescue Google::Cloud::Error => e
    message = "Failed to update AnywhereCache. Error: #{e.message}"
  end
  puts message
end
# [END storage_control_update_anywhere_cache]
update_anywhere_cache bucket_name: ARGV.shift, anywhere_cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
