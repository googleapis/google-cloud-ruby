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

require "google/cloud/storage"

def storage_get_object_contexts bucket_name:, file_name:
  # [START storage_get_object_contexts]
  # bucket_name = "my-bucket"
  # file_name   = "my-file.txt"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "File name: #{file.name}"
  puts "Bucket name: #{file.bucket}"
  puts "Generation: #{file.generation}"
  puts "Metageneration: #{file.metageneration}"
  puts "Content Type: #{file.content_type}"
  puts "Size: #{file.size}"
  puts "Created at: #{file.created_at}"
  puts "Updated at: #{file.updated_at}"
  puts "MD5: #{file.md5}"
  puts "CRC32c: #{file.crc32c}"
  puts "Metadata: #{file.metadata}"
  # [END storage_get_object_contexts]
end

if $PROGRAM_NAME == __FILE__
  storage_get_object_contexts bucket_name: ARGV[0], file_name: ARGV[1]
end
