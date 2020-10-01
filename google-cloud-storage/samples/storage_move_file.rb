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

def move_file bucket_name:, file_name:, new_name:
  # [START storage_move_file]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to rename"
  # new_name    = "File will be renamed to this new name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  renamed_file = file.copy new_name

  file.delete

  puts "#{file_name} has been renamed to #{renamed_file.name}"
  # [END storage_move_file]
end

if $PROGRAM_NAME == __FILE__
  move_file bucket_name: ARGV.shift, file_name: ARGV.shift, new_name: ARGV.shift
end
