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

# [START storage_copy_file]
def copy_file source_bucket_name:, source_file_name:, destination_bucket_name:, destination_file_name:
  # The ID of the bucket the original object is in
  # source_bucket_name = "source-bucket-name"

  # The ID of the GCS object to copy
  # source_file_name = "source-file-name"

  # The ID of the bucket to copy the object to
  # destination_bucket_name = "destination-bucket-name"

  # The ID of the new GCS object
  # destination_file_name = "destination-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket source_bucket_name, skip_lookup: true
  file    = bucket.file source_file_name

  destination_bucket = storage.bucket destination_bucket_name
  destination_file   = file.copy destination_bucket.name, destination_file_name

  puts "#{file.name} in #{bucket.name} copied to " \
       "#{destination_file.name} in #{destination_bucket.name}"
end
# [END storage_copy_file]

if $PROGRAM_NAME == __FILE__
  copy_file source_bucket_name:      ARGV.shift,
            source_file_name:        ARGV.shift,
            destination_bucket_name: ARGV.shift,
            destination_file_name:   ARGV.shift
end
