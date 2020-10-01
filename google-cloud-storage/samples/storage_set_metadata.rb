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

def set_metadata bucket_name:, file_name:, content_type:, metadata_key:, metadata_value:
  # [START storage_set_metadata]
  # bucket_name    = "Your Google Cloud Storage bucket name"
  # file_name      = "Name of file in Google Cloud Storage"
  # content_type   = "file Content-Type"
  # metadata_key   = "Custom metadata key"
  # metadata_value = "Custom metadata value"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.update do |file|
    # Fixed key file metadata
    file.content_type = content_type

    # Custom file metadata
    file.metadata[metadata_key] = metadata_value
  end

  puts "Metadata for #{file_name} has been updated."
  # [END storage_set_metadata]
end

if $PROGRAM_NAME == __FILE__
  set_metadata bucket_name:    ARGV.shift,
               file_name:      ARGV.shift,
               content_type:   ARGV.shift,
               metadata_key:   ARGV.shift,
               metadata_value: ARGV.shift
end
