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

def download_public_file bucket_name:, file_name:, local_path:
  # [START storage_download_public_file]
  # bucket_name = "A public Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"
  # local_path  = "Destination path for downloaded file"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.anonymous
  bucket  = storage.bucket bucket_name, skip_lookup: true
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name}"
  # [END storage_download_public_file]
end

if $PROGRAM_NAME == __FILE__
  download_public_file bucket_name: ARGV.shift, file_name: ARGV.shift, local_path: ARGV.shift
end
