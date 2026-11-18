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

# [START storage_control_list_rapid_caches]
require "google/cloud/storage/control"

# Lists the Rapid Caches of a bucket.
#
# @param bucket_name [String] The name of the bucket.
#
# @example
#   list_rapid_caches bucket_name: "your-unique-bucket-name"
#
def list_rapid_caches bucket_name:
  # Create a client object. The client can be reused for multiple calls.
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = storage_control_client.bucket_path project: "_", bucket: bucket_name

  request = Google::Cloud::Storage::Control::V2::ListRapidCachesRequest.new parent: parent

  # The returned enumerable fetches additional pages as needed.
  rapid_caches = storage_control_client.list_rapid_caches request
  rapid_caches.each do |rapid_cache|
    puts rapid_cache.name
  end

  puts "Listed Rapid Caches in bucket #{bucket_name}"
end
# [END storage_control_list_rapid_caches]

list_rapid_caches bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
