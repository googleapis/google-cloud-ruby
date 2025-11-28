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
# Demonstrates listing Google Cloud Storage buckets with support for partial success.
#
# This method initializes a Google Cloud Storage client and requests a list of buckets.
# When `return_partial_success` is true, the API will return available buckets
# and a list of any buckets that were unreachable.
#
# @param return_partial_success_flag [Boolean] Whether to allow partial success from the API.
#   - true: returns the available buckets and populates `unreachable` with bucket names if any.
#   - false: throws an error if any buckets are unreachable.
def list_buckets_with_partial_success return_partial_success_flag:
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket_list = storage.buckets return_partial_success: return_partial_success_flag

  puts "Reachable buckets:"
  # limiting the bucket count to be printed to 10 for brevity
  bucket_list.take(10).each do |bucket|
    puts bucket.name
  end

  if bucket_list.unreachable
    puts "\nUnreachable buckets:"
    # limiting the bucket count to be printed to 10 for brevity
    bucket_list.unreachable.take(10).each do |unreachable_bucket_name|
      puts unreachable_bucket_name
    end
  end
end
# [END storage_list_buckets_partial_success]

list_buckets_with_partial_success return_partial_success_flag: ARGV.shift if $PROGRAM_NAME == __FILE__
