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

# [START storage_generate_signed_post_policy_v4]
def generate_signed_post_policy_v4 bucket_name:, file_name:
  # The ID of the GCS bucket to upload to
  # bucket_name = "your-unique-bucket-name"

  # The name to give the object uploaded to GCS
  # file_name = "your-file-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new

  bucket = storage.bucket bucket_name
  post_object = bucket.generate_signed_post_policy_v4 file_name,
                                                      expires: 600,
                                                      fields:  { "x-goog-meta-test": "data" }

  html_form = "<form action='#{post_object.url}' method='POST' enctype='multipart/form-data'>\n"
  post_object.fields.each do |name, value|
    html_form += "  <input name='#{name}' value='#{value}' type='hidden'/>\n"
  end
  html_form += "  <input type='file' name='file'/><br />\n"
  html_form += "  <input type='submit' value='Upload File'/><br />\n"
  html_form += "</form>\n"

  puts "You can use the following form to upload an object to bucket #{bucket_name} for the next 10 minutes:\n"
  puts html_form
end
# [END storage_generate_signed_post_policy_v4]

generate_signed_post_policy_v4 bucket_name: ARGV.shift, file_name: ARGV.shift if $PROGRAM_NAME == __FILE__
