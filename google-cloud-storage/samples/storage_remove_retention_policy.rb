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

# [START storage_remove_retention_policy]
def remove_retention_policy bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  if !bucket.retention_policy_locked?
    bucket.retention_period = nil
    puts "Retention policy for #{bucket_name} has been removed."
  else
    puts "Policy is locked and retention policy can't be removed."
  end
end
# [END storage_remove_retention_policy]

remove_retention_policy bucket_name: ARGV.shift if $PROGRAM_NAME == __FILE__
