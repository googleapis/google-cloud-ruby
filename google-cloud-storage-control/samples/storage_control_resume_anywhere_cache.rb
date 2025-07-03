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
def resume_anywhere_cache bucket_name:, anywhere_cache_id:
  require "google/cloud/storage/control/v2"

  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # A value that, along with the bucket's name, uniquely identifies the cache
  # anywhere_cache_id = value that, along with the bucket's name, uniquely identifies the cache

  # Create a client object. The client can be reused for multiple calls.
  client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{anywhere_cache_id}"

  # Create a request. Replace the placeholder values with actual data.
  request = Google::Cloud::Storage::Control::V2::ResumeAnywhereCacheRequest.new(
    name: name
  )
  # The request resumes the cache, which was previously paused.
  # The cache is resumed in the specified bucket.
  # The cache is identified by the specified ID.
  # Call the resume_anywhere_cache method.
  result = client.resume_anywhere_cache request
  puts "AnywhereCache #{result.name} #{result.state}"
end
# [END storage_control_resume_anywhere_cache]

resume_anywhere_cache bucket_name: ARGV.shift, anywhere_cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
