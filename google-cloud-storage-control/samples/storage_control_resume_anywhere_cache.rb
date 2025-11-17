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

# [START storage_control_resume_anywhere_cache]
require "google/cloud/storage/control"

# Resumes a paused Anywhere Cache instance.
#
# This method sends a request to the Storage Control API to resume a
# specific Anywhere Cache that was previously paused.
#
# @param bucket_name [String] The name of the bucket
#   containing the cache.
# @param anywhere_cache_id [String] The unique identifier for the Anywhere
#   Cache instance within the bucket. For example: "us-east1-b".
#
# @example
#   resume_anywhere_cache(
#     bucket_name: "your-unique-bucket-name",
#     anywhere_cache_id: "us-east1-b"
#   )
#
def resume_anywhere_cache bucket_name:, anywhere_cache_id:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{anywhere_cache_id}"

  # Create a request.
  request = Google::Cloud::Storage::Control::V2::ResumeAnywhereCacheRequest.new(
    name: name
  )
  # The request resumes the cache, which was previously paused.
  # The cache is resumed in the specified bucket.
  # The cache is identified by the specified ID.
  begin
    result = storage_control_client.resume_anywhere_cache request
    puts "Successfully resumed anywhereCache - #{result.name}."
  rescue Google::Cloud::Error => e
    puts "Failed to resume AnywhereCache. Error: #{e.message}"
  end
end
# [END storage_control_resume_anywhere_cache]
resume_anywhere_cache bucket_name: ARGV.shift, anywhere_cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
