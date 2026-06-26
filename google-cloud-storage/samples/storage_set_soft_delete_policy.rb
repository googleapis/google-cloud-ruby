# Copyright 2024 Google LLC
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

# [START storage_set_soft_delete_policy]
def set_soft_delete_policy bucket_name:, retention_duration_seconds:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The retention duration for soft-deleted objects in seconds
  # retention_duration_seconds = 604800 # 7 days in seconds

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  binding.pry

  bucket.soft_delete_policy = { retention_duration_seconds: retention_duration_seconds.to_i }

  puts "Soft delete retention duration for #{bucket_name} is now #{bucket.soft_delete_policy.retention_duration_seconds} seconds."
end
# [END storage_set_soft_delete_policy]

if $PROGRAM_NAME == __FILE__
  set_soft_delete_policy bucket_name: ARGV.shift, retention_duration_seconds: ARGV.shift
end
