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

def upload_with_kms_key bucket_name:, local_file_path:, file_name: nil, kms_key:
  # [START storage_upload_with_kms_key]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The path to your file to upload
  # local_file_path = "/local/path/to/file.txt"

  # The ID of your GCS object
  # file_name = "your-file-name"

  # The name of the KMS key to manage this object with
  # kms_key = "projects/your-project-id/locations/global/keyRings/your-key-ring/cryptoKeys/your-key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name

  file = bucket.create_file local_file_path, file_name, kms_key: kms_key

  puts "Uploaded #{file.name} and encrypted service side using #{file.kms_key}"
  # [END storage_upload_with_kms_key]
end

if $PROGRAM_NAME == __FILE__
  upload_with_kms_key bucket_name:     ARGV.shift,
                      local_file_path: ARGV.shift,
                      file_name:       ARGV.shift,
                      kms_key:         ARGV.shift
end
