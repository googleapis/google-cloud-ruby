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

# [START storage_control_list_anywhere_caches]
def list_anywhere_caches bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage/control/v2"

  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control::V2::StorageControl::Client.new
  parent = "projects/_/buckets/#{bucket_name}"

  request = Google::Cloud::Storage::Control::V2::ListAnywhereCachesRequest.new(
    parent: parent
  )
  # The request lists all caches in the specified bucket.
  # The caches are identified by the specified bucket name.
  # Call the list_anywhere_caches method.
  result = storage_control_client.list_anywhere_caches request

  result.response.anywhere_caches.each do |item|
    puts item.name
  end
end
# [END storage_control_list_anywhere_caches]
list_anywhere_caches bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
