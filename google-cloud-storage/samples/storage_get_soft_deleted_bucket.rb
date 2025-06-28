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

# [START storage_get_soft_deleted_bucket]
def get_soft_deleted_bucket bucket_name:, generation:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # The generation no of your GCS bucket
  # generation = "1234567896987"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  # fetching soft deleted bucket with soft_delete_time and hard_delete_time
  deleted_bucket_fetch = storage.bucket bucket_name, generation: generation, soft_deleted: true

  soft_delete_time = deleted_bucket_fetch.soft_delete_time
  hard_delete_time = deleted_bucket_fetch.hard_delete_time

  if (soft_delete_time && hard_delete_time).nil?
    puts "Not Found"
  else
    puts "soft_delete_time for #{deleted_bucket_fetch.name} is - #{soft_delete_time}"
    puts "hard_delete_time for #{deleted_bucket_fetch.name} is - #{hard_delete_time}"
  end
end
# [END storage_get_soft_deleted_bucket]


get_soft_deleted_bucket bucket_name: ARGV.shift, generation: ARGV.shift if $PROGRAM_NAME == __FILE__
