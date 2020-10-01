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
  # bucket_name            = "Your Google Cloud Storage bucket name"
  # file_name              = "Name of a file in the Cloud Storage bucket"
  # current_encryption_key = "Encryption key currently being used"
  # new_encryption_key     = "New encryption key to use"

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
