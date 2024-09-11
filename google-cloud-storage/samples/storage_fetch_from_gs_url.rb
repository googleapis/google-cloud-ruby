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

# Sample for storage_fetch_from_gs_url
def fetch_from_gs_url url
  # [START storage_fetch_from_gs_url]
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  #   gs_url= "gs://#{bucket_name}//#{file_name}"
  require "google/cloud/storage"

  file_object = Google::Cloud::Storage::File
  output = file_object.from_gs_url url

  puts "Output json #{output}"
  # [END storage_fetch_from_gs_url]
end

if $PROGRAM_NAME == __FILE__
  fetch_from_gs_url url: ARGV.shift
end
