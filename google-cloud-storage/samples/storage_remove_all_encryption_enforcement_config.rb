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

# [START storage_remove_all_encryption_enforcement_config]
def remove_all_encryption_enforcement_config bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name do |b|
    b.customer_managed_encryption_enforcement_config = nil
    b.customer_supplied_encryption_enforcement_config = nil
    b.google_managed_encryption_enforcement_config = nil
  end
  puts "Removed Encryption Enforcement Config from bucket #{bucket.name}."
end
# [END storage_remove_all_encryption_enforcement_config]

if $PROGRAM_NAME == __FILE__
  remove_all_encryption_enforcement_config bucket_name: ARGV.shift
end
