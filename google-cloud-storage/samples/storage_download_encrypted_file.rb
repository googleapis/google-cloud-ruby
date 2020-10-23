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

def download_encrypted_file bucket_name:, file_name:, local_file_path:, encryption_key:
  # [START storage_download_encrypted_file]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The path to which the file should be downloaded
  # local_file_path = "/local/path/to/file.txt"

  # The Base64 encoded decryption key, which should be the same key originally used to encrypt the object
  # encryption_key = "TIbv/fjexq+VmtXzAlc63J4z5kFmWJ6NdAPQulQBT7g="

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name

  file = bucket.file file_name, encryption_key: encryption_key
  file.download local_file_path, encryption_key: encryption_key

  puts "Downloaded encrypted #{file.name} to #{local_file_path}"
  # [END storage_download_encrypted_file]
end

if $PROGRAM_NAME == __FILE__
  download_encrypted_file bucket_name:     ARGV.shift,
                          file_name:       ARGV.shift,
                          local_file_path: ARGV.shift,
                          encryption_key:  ARGV.shift
end
