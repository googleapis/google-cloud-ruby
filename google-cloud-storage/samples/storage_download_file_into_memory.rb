# Copyright 2022 Google LLC
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

def download_file_into_memory bucket_name:, file_name:
  # [START storage_file_download_into_memory]
  # The name of the bucket to access
  # bucket_name = "my-bucket"

  # The name of the remote file to download
  # file_name = "file.txt"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name, skip_lookup: true
  file    = bucket.file file_name

  downloaded = file.download
  downloaded.rewind # Optional - not needed on first read
  contents = downloaded.read

  puts "Contents of storage object #{file.name} in bucket #{bucket_name} are: #{contents}"
  # [END storage_file_download_into_memory]
end

if $PROGRAM_NAME == __FILE__
  download_file_into_memory bucket_name: ARGV.shift, file_name: ARGV.shift
end
