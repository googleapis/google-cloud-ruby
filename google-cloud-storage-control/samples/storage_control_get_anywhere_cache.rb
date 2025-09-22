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

# [START storage_control_get_anywhere_cache]
require "google/cloud/storage/control"

def get_anywhere_cache bucket_name:, anywhere_cache_id:
  # The Name of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # A value that, along with the bucket's name, uniquely identifies the cache
  # anywhere_cache_id = "us-east1-b"

  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{anywhere_cache_id}"

  # Create a request.
  request = Google::Cloud::Storage::Control::V2::GetAnywhereCacheRequest.new(
    name: name
  )
  # The request retrieves the cache in the specified bucket.
  # The cache is identified by the specified ID.
  # The cache is in the specified bucket.

  begin
    result = storage_control_client.get_anywhere_cache request
    puts "AnywhereCache #{result.name} fetched"
  rescue Google::Cloud::Error => e
    puts "Error fetching AnywhereCache: #{e.message}"
  end
end
# [END storage_control_get_anywhere_cache]
get_anywhere_cache bucket_name: ARGV.shift, anywhere_cache_id: ARGV.shift if $PROGRAM_NAME == __FILE__
