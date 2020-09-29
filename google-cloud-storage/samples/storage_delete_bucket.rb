# Copyright 2020 Google LLC
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

def delete_bucket bucket_name:
  # [START storage_delete_bucket]
  # bucket_name = "Name of your Google Cloud Storage bucket to delete"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.delete

  puts "Deleted bucket: #{bucket.name}"
  # [END storage_delete_bucket]
end

compose_file bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
