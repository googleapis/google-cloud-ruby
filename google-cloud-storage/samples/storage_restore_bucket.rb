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

# [START storage_restore_bucket]
def restore_bucket bucket_name:, generation:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # The generation no of your GCS bucket
  # generation = "1234567896987"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket_restored = storage.restore_bucket bucket_name, generation

  if bucket_restored.name == bucket_name
    puts "#{bucket_name} Bucket restored"
  else
    puts "#{bucket_name} Bucket not restored"
  end
end
# [END storage_restore_bucket]

restore_bucket bucket_name: ARGV.shift, generation: ARGV.shift if $PROGRAM_NAME == __FILE__
