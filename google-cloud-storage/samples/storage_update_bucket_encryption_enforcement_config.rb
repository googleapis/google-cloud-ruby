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

require "google/cloud/storage"

# [START storage_update_bucket_encryption_enforcement_config]

def update_bucket_encryption_enforcement_config bucket_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name
  # Update a specific type (e.g., change GMEK to NotRestricted)
  new_config =  {
    google_managed_encryption_enforcement_config: { restriction_mode: "NotRestricted" }
  }

  bucket.update_bucket_encryption_enforcement_config new_config

  puts "Updated google_managed_config to " \
       "#{bucket.google_managed_encryption_enforcement_config.restriction_mode} " \
       "for bucket #{bucket.name}."
end
# [END storage_update_bucket_encryption_enforcement_config]

if $PROGRAM_NAME == __FILE__
  update_bucket_encryption_enforcement_config bucket_name: ARGV.shift
end
