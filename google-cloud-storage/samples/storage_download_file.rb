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

def download_file bucket_name:, file_name:, local_file_path:
  # [START storage_download_file]
  # bucket_name     = "Your Google Cloud Storage bucket name"
  # file_name       = "Name of file in Google Cloud Storage to download locally"
  # local_file_path = "Destination path for downloaded file"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.download local_file_path

  puts "Downloaded #{file.name} to #{local_file_path}"
  # [END storage_download_file]
end

download_file bucket_name: ARGV.shift, file_name: ARGV.shift, local_file_path: ARGV.shift if $PROGRAM_NAME == __FILE__
