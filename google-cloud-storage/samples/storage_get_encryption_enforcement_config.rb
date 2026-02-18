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

# [START storage_get_encryption_enforcement_config]
def get_encryption_enforcement_config bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name
  puts "Encryption Enforcement Config for bucket #{bucket.name}:"
  puts "Customer-managed encryption enforcement config restriction mode: #{bucket.customer_managed_encryption_enforcement_config.restriction_mode}"
  puts "Customer-supplied encryption enforcement config restriction mode: #{bucket.customer_supplied_encryption_enforcement_config.restriction_mode}"
  puts "Google-managed encryption enforcement config restriction mode: #{bucket.google_managed_encryption_enforcement_config.restriction_mode}"
end
# [END storage_get_encryption_enforcement_config]

if $PROGRAM_NAME == __FILE__
  get_encryption_enforcement_config bucket_name: ARGV.shift
end
