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

def delete_file_archived_generation bucket_name:, file_name:, generation:
  # [START storage_delete_file_archived_generation]
  # bucket_name = "your-bucket-name"
  # file_name = "your-file-name"
  # generation = 1579287380533984

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  file = bucket.file file_name

  file.delete generation: generation

  puts "Generation #{generation} of file #{file_name} was deleted from #{bucket_name}"
  # [END storage_delete_file_archived_generation]
  file
end

if $PROGRAM_NAME == __FILE__
  delete_file_archived_generation bucket_name: ARGV.shift, file_name: ARGV.shift, generation: ARGV.shift
end
