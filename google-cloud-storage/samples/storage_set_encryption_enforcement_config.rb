# Copyright 2026 Google LLC
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

# [START storage_set_encryption_enforcement_config]
def set_encryption_enforcement_config bucket_name:, restriction_mode: nil
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  customer_managed_encryption_enforcement_config = Google::Apis::StorageV1::Bucket::Encryption::CustomerManagedEncryptionEnforcementConfig.new restriction_mode: "NotRestricted"
  customer_supplied_encryption_enforcement_config = Google::Apis::StorageV1::Bucket::Encryption::CustomerSuppliedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted"
  google_managed_encryption_enforcement_config = Google::Apis::StorageV1::Bucket::Encryption::GoogleManagedEncryptionEnforcementConfig.new restriction_mode: "FullyRestricted"
  bucket = storage.create_bucket bucket_name 
  bucket.customer_managed_encryption_enforcement_config = customer_managed_encryption_enforcement_config
  bucket.customer_supplied_encryption_enforcement_config = customer_supplied_encryption_enforcement_config
  bucket.google_managed_encryption_enforcement_config = google_managed_encryption_enforcement_config
  puts "Created bucket #{bucket.name} with Encryption Enforcement Config."
end
# [END storage_set_encryption_enforcement_config]

if $PROGRAM_NAME == __FILE__
  set_encryption_enforcement_config bucket_name: ARGV.shift
end
