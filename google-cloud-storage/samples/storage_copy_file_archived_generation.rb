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

def copy_file_archived_generation bucket_name:,
                                  file_name:,
                                  destination_bucket_name:,
                                  destination_file_name:,
                                  generation:
  # [START storage_copy_file_archived_generation]
  # bucket_name = "your-bucket-name"
  # file_name = "your-file-name"
  # destination_bucket_name = "destination-bucket-name"
  # destination_file_name = "destination-object-name"
  # generation = 1579287380533984

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  source_bucket = storage.bucket bucket_name
  source_file = source_bucket.file file_name
  destination_bucket = storage.bucket destination_bucket_name

  destination_file = source_file.copy destination_bucket, destination_file_name, generation: generation

  puts "Generation #{generation} of the file #{source_file.name} in bucket #{source_bucket.name} copied to file " \
       "#{destination_file.name} in bucket #{destination_bucket.name}"
  # [END storage_copy_file_archived_generation]
end

if $PROGRAM_NAME == __FILE__
  copy_file_archived_generation bucket_name:             ARGV.shift,
                                file_name:               ARGV.shift,
                                destination_bucket_name: ARGV.shift,
                                destination_file_name:   ARGV.shift,
                                generation:              ARGV.shift
end
