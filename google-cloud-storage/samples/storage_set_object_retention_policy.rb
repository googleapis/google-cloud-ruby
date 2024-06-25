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

# [START storage_set_object_retention_policy]
def set_object_retention_policy bucket_name:, content:, destination_file_name:
  # The ID to give your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # The content to upload to the file
  # content = "this is my content"

  # The ID of your GCS object
  # destination_file_name = "storage-object-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file_content = StringIO.new content
  file = bucket.create_file file_content, destination_file_name

  # Set the retention policy for the file.
  retention_params = { mode: "Unlocked", retain_until_time: DateTime.now + 10 }
  file.retention = retention_params

  puts "Retention policy for file #{destination_file_name} was set to: #{file.retention.mode}."

  # To modify an existing policy on an unlocked file object, pass in the
  # override parameter.
  new_retention_date = DateTime.now + 9 # 9 days
  new_retention_params = {
    mode: "Unlocked",
    retain_until_time: new_retention_date,
    override_unlocked_retention: true
  }
  file.retention = new_retention_params

  puts "Retention policy for file #{destination_file_name} was updated to: #{file.retention.retain_until_time}."
end
# [END storage_set_object_retention_policy]

if $PROGRAM_NAME == __FILE__
  create_bucket_class_location bucket_name: ARGV.shift
end
