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

# [START storage_control_create_anywhere_cache]
require "google/cloud/storage/control"

def create_anywhere_cache bucket_name:, zone:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # Zone where you want to create cache
  # zone = "your-zone-name"

  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  parent = "projects/_/buckets/#{bucket_name}"
  name = "#{parent}/anywhereCaches/#{zone}"

  anywhere_cache = Google::Cloud::Storage::Control::V2::AnywhereCache.new(
    name: name,
    zone: zone
  )
  # Create a request.
  request = Google::Cloud::Storage::Control::V2::CreateAnywhereCacheRequest.new(
    parent: parent,
    anywhere_cache: anywhere_cache
  )
  # The request creates a new cache in the specified zone.
  # The cache is created in the specified bucket.
  begin
    operation = storage_control_client.create_anywhere_cache request

    puts "********************AnywhereCache operation created - #{operation.name}"
    while !operation.done?
      sleep 3600 # Wait for 1 hour before checking again
      operation.refresh!
    end
    puts "********************AnywhereCache create operation completed - #{operation.name}"

  rescue StandardError => e
    puts "Error creating AnywhereCache: #{e.message}"
  end
end
# [END storage_control_create_anywhere_cache]
create_anywhere_cache bucket_name: ARGV.shift, zone: ARGV.shift if $PROGRAM_NAME == __FILE__
