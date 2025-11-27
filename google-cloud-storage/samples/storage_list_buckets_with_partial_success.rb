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
# This method initializes a Google Cloud Storage client and requests a list of buckets
# which are present in unreachable locations.
# If `return_partial_success_flag` is true, the Storage API will return a list of buckets which are
# unreachable in the `unreachable` field of the response.
#
# If `return_partial_success_flag` is false the method will return nil.
#
# @param return_partial_success_flag [Boolean] Whether to allow partial success from the API.
#   - true: returns the available buckets and populates `unreachable` with bucket names.
#   - false: the method returns nil.

def list_buckets_with_partial_success return_partial_success_flag:
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket_list = storage.buckets return_partial_success: return_partial_success_flag

  bucket_list.unreachable&.each do |unreachable_bucket_name|
    puts unreachable_bucket_name
  end
end
# [END storage_list_buckets_partial_success]

list_buckets_with_partial_success return_partial_success_flag: ARGV.shift if $PROGRAM_NAME == __FILE__
