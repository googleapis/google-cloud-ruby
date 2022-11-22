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

# [START storage_download_file]
def download_file bucket_name:, file_name:, local_file_path:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The path to which the file should be downloaded
  # local_file_path = "/local/path/to/file.txt"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true
  file    = bucket.file file_name

  file.download local_file_path

  puts "Downloaded #{file.name} to #{local_file_path}"
end
# [END storage_download_file]

download_file bucket_name: ARGV.shift, file_name: ARGV.shift, local_file_path: ARGV.shift if $PROGRAM_NAME == __FILE__
