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

def upload_file bucket_name:, local_file_path:, storage_file_path: nil
  # [START storage_upload_file]
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path

  puts "Uploaded #{local_file_path} as #{file.name} in bucket #{bucket_name}"
  # [END storage_upload_file]
end

if $PROGRAM_NAME == __FILE__
  upload_file bucket_name: ARGV.shift, local_file_path: ARGV.shift, storage_file_path: ARGV.shift
end
