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

def compose_file bucket_name:, first_file_name:, second_file_name:, destination_file_name:
  # [START storage_compose_file]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The ID of the first GCS object to compose
  # first_file_name = "your-first-file-name"

  # The ID of the second GCS object to compose
  # second_file_name = "your-second-file-name"

  # The ID to give the new composite object
  # destination_file_name = "new-composite-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  destination = bucket.compose [first_file_name, second_file_name], destination_file_name do |f|
    f.content_type = "text/plain"
  end

  puts "Composed new file #{destination.name} in the bucket #{bucket_name}"
  # [END storage_compose_file]
end

if $PROGRAM_NAME == __FILE__
  compose_file bucket_name:           ARGV.shift,
               first_file_name:       ARGV.shift,
               second_file_name:      ARGV.shift,
               destination_file_name: ARGV.shift
end
