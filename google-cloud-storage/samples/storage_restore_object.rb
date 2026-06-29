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

# [START storage_restore_object]
def restore_object bucket_name:, file_name:, generation:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The name of the soft-deleted file to restore
  # file_name = "your-file-name"

  # The generation of the soft-deleted file to restore
  # generation = 1600000000000000

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  file = bucket.restore_file file_name, generation

  puts "Restored file #{file.name} with generation #{file.generation} in bucket #{bucket_name}."
end
# [END storage_restore_object]

if $PROGRAM_NAME == __FILE__
  restore_object bucket_name: ARGV.shift, file_name: ARGV.shift, generation: ARGV.shift
end
