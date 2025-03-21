# Copyright 2025 Google LLC
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

# [START storage_move_object]
def move_object bucket_name:, source_file_name:, destination_file_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The name of your GCS object
  # source_file_name = "your-file-name"

  # The new object name which you want to craete
  # destination_file_name = "your-new-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true

  bucket.move_file source_file_name, destination_file_name
  fetch_file = bucket.file destination_file_name
  puts "New File #{fetch_file.name} created\n"
end
# [END storage_move_object]

if $PROGRAM_NAME == __FILE__
  move_object bucket_name: ARGV.shift, source_file_name: ARGV.shift,
              destination_file_name: ARGV.shift
end
