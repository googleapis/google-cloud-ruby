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

def list_files_with_prefix bucket_name:, prefix:
  # [START storage_list_files_with_prefix]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # prefix      = "Filter results to files whose names begin with this prefix"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  files   = bucket.files prefix: prefix

  files.each do |file|
    puts file.name
  end
  # [END storage_list_files_with_prefix]
end

list_files_with_prefix bucket_name: ARGV.shift, prefix: ARGV.shift if $PROGRAM_NAME == __FILE__
