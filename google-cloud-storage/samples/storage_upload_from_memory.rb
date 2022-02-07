# Copyright 2022 Google LLC
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

def upload_file_from_memory bucket_name:, file_name:, file_content:
  # [START storage_file_upload_from_memory]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The contents to upload to your file
  # file_content = "Hello, world!"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true

  file = bucket.create_file StringIO.new(file_content), file_name

  puts "Uploaded file #{file.name} to bucket #{bucket_name} with content: #{file_content}"
  # [END storage_file_upload_from_memory]
end

if $PROGRAM_NAME == __FILE__
  upload_file_from_memory bucket_name: ARGV.shift, file_name: ARGV.shift,
                          file_content: ARGV.shift
end
