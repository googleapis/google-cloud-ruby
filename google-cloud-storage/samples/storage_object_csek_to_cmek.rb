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

def object_csek_to_cmek bucket_name:, file_name:, encryption_key:, kms_key_name:
  # [START storage_object_csek_to_cmek]
  # bucket_name = "your-bucket-name"
  # file_name = "your-file-name"
  # encryption_key = "TIbv/fjexq+VmtXzAlc63J4z5kFmWJ6NdAPQulQBT7g="
  # kms_key_name = "projects/PROJ/locations/LOC/keyRings/RING/cryptoKey/KEY"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  file = bucket.file file_name, encryption_key: encryption_key

  file.rotate encryption_key: encryption_key, new_kms_key: kms_key_name

  puts "File #{file_name} in bucket #{bucket_name} is now managed by the KMS key #{kms_key_name} instead of a " \
       "customer-supplied encryption key"
  # [END storage_object_csek_to_cmek]
end

if $PROGRAM_NAME == __FILE__
  object_csek_to_cmek bucket_name:    ARGV.shift,
                      file_name:      ARGV.shift,
                      encryption_key: ARGV.shift,
                      kms_key_name:   ARGV.shift
end
