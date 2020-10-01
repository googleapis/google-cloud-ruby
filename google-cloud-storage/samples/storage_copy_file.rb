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

def copy_file source_bucket_name:, source_file_name:, dest_bucket_name:, dest_file_name:
  # [START storage_copy_file]
  # source_bucket_name = "Source bucket to copy file from"
  # source_file_name   = "Source file name"
  # dest_bucket_name   = "Destination bucket to copy file to"
  # dest_file_name     = "Destination file name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket source_bucket_name
  file    = bucket.file source_file_name

  destination_bucket = storage.bucket dest_bucket_name
  destination_file   = file.copy destination_bucket.name, dest_file_name

  puts "#{file.name} in #{bucket.name} copied to " \
       "#{destination_file.name} in #{destination_bucket.name}"
  # [END storage_copy_file]
end

if $PROGRAM_NAME == __FILE__
  copy_file source_bucket_name: ARGV.shift,
            source_file_name:   ARGV.shift,
            dest_bucket_name:   ARGV.shift,
            dest_file_name:     ARGV.shift
end
