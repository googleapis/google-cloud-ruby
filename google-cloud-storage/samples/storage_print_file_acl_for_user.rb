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

def print_file_acl_for_user bucket_name:, file_name:, email:
  # [START storage_print_file_acl_for_user]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # file_name   = "Name of a file in the Storage bucket"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "Permissions for #{email}:"
  puts "OWNER"  if file.acl.owners.include?  email
  puts "READER" if file.acl.readers.include? email
  # [END storage_print_file_acl_for_user]
end

if $PROGRAM_NAME == __FILE__
  print_file_acl_for_user bucket_name: arguments.shift, file_name: arguments.shift,
                          email: arguments.shift
end
