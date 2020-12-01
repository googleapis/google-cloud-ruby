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

# [START storage_lock_retention_policy]
def lock_retention_policy bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  # Warning: Once a retention policy is locked it cannot be unlocked
  # and retention period can only be increased.
  # Uses Bucket#metageneration as a precondition.
  bucket.lock_retention_policy!

  puts "Retention policy for #{bucket_name} is now locked."
  puts "Retention policy effective as of #{bucket.retention_effective_at}."
end
# [END storage_lock_retention_policy]

lock_retention_policy bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
