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

def generate_signed_url_v4 bucket_name:, file_name:
  # [START storage_generate_signed_url_v4]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Google Cloud Storage bucket"
  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  storage_expiry_time = 5 * 60 # 5 minutes

  url = storage.signed_url bucket_name, file_name, method: "GET",
                           expires: storage_expiry_time, version: :v4

  puts "Generated GET signed url:"
  puts url
  puts "You can use this URL with any user agent, for example:"
  puts "curl #{url}"
  # [END storage_generate_signed_url_v4]
end

generate_signed_url_v4 bucket_name: ARGV.shift, file_name: ARGV.shift if $PROGRAM_NAME == __FILE__
