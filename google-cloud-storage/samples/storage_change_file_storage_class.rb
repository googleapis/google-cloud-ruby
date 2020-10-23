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

def change_file_storage_class bucket_name:, file_name:
  # [START storage_change_file_storage_class]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  file = bucket.file file_name

  file.storage_class = "NEARLINE"

  puts "File #{file_name} in bucket #{bucket_name} had its storage class set to #{file.storage_class}"
  # [END storage_change_file_storage_class]
end

if $PROGRAM_NAME == __FILE__
  change_file_storage_class bucket_name: ARGV.shift, file_name: ARGV.shift
end
