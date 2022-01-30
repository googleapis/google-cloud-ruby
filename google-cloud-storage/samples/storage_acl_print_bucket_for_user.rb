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

def print_bucket_acl_for_user bucket_name:, email:
  # [START storage_print_bucket_acl_for_user]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  puts "Permissions for #{email}:"
  puts "OWNER"  if bucket.acl.owners.include?  email
  puts "WRITER" if bucket.acl.writers.include? email
  puts "READER" if bucket.acl.readers.include? email
  # [END storage_print_bucket_acl_for_user]
end

print_bucket_acl_for_user bucket_name: arguments.shift, email: arguments.shift if $PROGRAM_NAME == __FILE__
