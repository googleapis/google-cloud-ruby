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

# [START storage_list_buckets_partial_success]
# Demonstrates listing buckets from Google Cloud Storage with partial success enabled.
#
# Behavior:
# - Initializes a Storage client.
# - Uses `Storage#buckets(return_partial_success: true)` to request buckets.
# - Prints one unreachable bucket name per line to standard output.


def list_buckets_with_partial_success
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket_list = storage.buckets return_partial_success: true

  puts "Bucket Names:"
  bucket_list.each do |bucket|
    puts bucket.name
  end

  puts "Unreachable bucket names:" 
  bucket_list.unreachable.each do |unreachable_bucket_name|
    puts unreachable_bucket_name
  end
end
# [END storage_list_buckets_partial_success]

list_buckets_with_partial_success if $PROGRAM_NAME == __FILE__
