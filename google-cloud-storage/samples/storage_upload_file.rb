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

# [START storage_upload_file]
def upload_file bucket_name:, local_file_path:, file_name: nil
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The path to your file to upload
  # local_file_path = "/local/path/to/file.txt"

  # The ID of your GCS object
  # file_name = "your-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true

  file = bucket.create_file local_file_path, file_name

  puts "Uploaded #{local_file_path} as #{file.name} in bucket #{bucket_name}"
end
# [END storage_upload_file]

upload_file bucket_name: ARGV.shift, local_file_path: ARGV.shift, file_name: ARGV.shift if $PROGRAM_NAME == __FILE__
