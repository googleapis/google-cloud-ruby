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

# [START storage_list_unreachable_buckets]
def list_unreachable_buckets
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket_list = storage.buckets(return_partial_success: true)
  bucket_list.unreachable.each do |bucket|
    puts bucket
  end
end
# [END storage_list_unreachable_buckets]

list_unreachable_buckets if $PROGRAM_NAME == __FILE__
