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

def rotate_encryption_key bucket_name:, file_name:, current_encryption_key:, new_encryption_key:
  # [START storage_rotate_encryption_key]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The Base64 encoded AES-256 encryption key originally used to encrypt the object.
  # See the documentation on Customer-Supplied Encryption keys for more info:
  # https://cloud.google.com/storage/docs/encryption/using-customer-supplied-keys
  # current_encryption_key = "TIbv/fjexq+VmtXzAlc63J4z5kFmWJ6NdAPQulQBT7g="

  # The new encryption key to use
  # new_encryption_key = "0mMWhFvQOdS4AmxRpo8SJxXn5MjFhbz7DkKBUdUIef8="

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name, encryption_key: current_encryption_key

  file.rotate encryption_key:     current_encryption_key,
              new_encryption_key: new_encryption_key

  puts "The encryption key for #{file.name} in #{bucket.name} was rotated."
  # [END storage_rotate_encryption_key]
end

if $PROGRAM_NAME == __FILE__
  rotate_encryption_key bucket_name:            ARGV.shift,
                        file_name:              ARGV.shift,
                        current_encryption_key: ARGV.shift,
                        new_encryption_key:     ARGV.shift
end
