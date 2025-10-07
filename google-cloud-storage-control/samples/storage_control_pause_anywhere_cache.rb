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

# [START storage_control_pause_anywhere_cache]
require "google/cloud/storage/control"

# Pauses a specific Anywhere Cache instance in a Cloud Storage bucket.
# This operation does not delete the cache; it can be resumed later using
# the `resume_anywhere_cache` method.
#
# @param bucket_name [String] The name of the Cloud Storage bucket.
# @param anywhere_cache_id [String] The ID of the Anywhere Cache instance to pause.
#   This is often the zone where the cache is located, e.g., "us-east1-b".
#
# @example
#   pause_anywhere_cache(
#     bucket_name: "your-unique-bucket-name",
#     anywhere_cache_id: "us-east1-b"
#   )
#
def pause_anywhere_cache bucket_name:, anywhere_cache_id:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{anywhere_cache_id}"

  # Create a request.
  request = Google::Cloud::Storage::Control::V2::PauseAnywhereCacheRequest.new(
    name: name
  )
  # The request pauses the cache, but does not delete it.
  # The cache can be resumed later.
  # The cache is paused in the specified bucket.
  begin
    result = storage_control_client.pause_anywhere_cache request
    puts "Successfully #{result.state&.downcase} anywhereCache - #{result.name}."
  rescue Google::Cloud::Error => e
    puts "Failed to pause AnywhereCache. Error: #{e.message}"
  end
end
# [END storage_control_pause_anywhere_cache]
pause_anywhere_cache bucket_name: ARGV.shift, anywhere_cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
