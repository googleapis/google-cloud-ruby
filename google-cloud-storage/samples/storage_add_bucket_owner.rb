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

def add_bucket_owner bucket_name:, email:
  # [START storage_add_bucket_owner]
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"
  # email       = "Google Cloud Storage ACL Entity email"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket  = storage.bucket bucket_name

  bucket.acl.add_owner email

  puts "Added OWNER permission for #{email} to #{bucket_name}"
  # [END storage_add_bucket_owner]
end

add_bucket_owner bucket_name: arguments.shift, email: arguments.shift if $PROGRAM_NAME == __FILE__
