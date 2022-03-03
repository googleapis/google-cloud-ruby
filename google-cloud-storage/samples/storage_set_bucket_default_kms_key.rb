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

# [START storage_set_bucket_default_kms_key]
def set_bucket_default_kms_key bucket_name:, default_kms_key:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The name of the KMS key to manage this object with
  # default_kms_key = "projects/your-project-id/locations/global/keyRings/your-key-ring/cryptoKeys/your-key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.default_kms_key = default_kms_key

  puts "Default KMS key for #{bucket.name} was set to #{bucket.default_kms_key}"
end
# [END storage_set_bucket_default_kms_key]

set_bucket_default_kms_key bucket_name: ARGV.shift, default_kms_key: ARGV.shift if $PROGRAM_NAME == __FILE__
