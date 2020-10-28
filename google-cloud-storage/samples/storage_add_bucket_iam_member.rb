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

# [START storage_add_bucket_iam_member]
def add_bucket_iam_member bucket_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  role   = "roles/storage.objectViewer"
  member = "group:example@google.com"

  bucket.policy requested_policy_version: 3 do |policy|
    policy.bindings.insert role: role, members: [member]
  end

  puts "Added #{member} with role #{role} to #{bucket_name}"
end
# [END storage_add_bucket_iam_member]

if $PROGRAM_NAME == __FILE__
  add_bucket_iam_member bucket_name: ARGV.shift
end
