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

def set_bucket_public_iam bucket_name:, role:, member:
  # [START storage_set_bucket_public_iam]
  # bucket_name = "your-bucket-name"
  # role = "IAM role, e.g. roles/storage.objectViewer"
  # member = "IAM identity, e.g. allUsers"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy do |p|
    p.add role, member
  end

  puts "Bucket #{bucket_name} is now publicly readable"
  # [END storage_set_bucket_public_iam]
end

if $PROGRAM_NAME == __FILE__
  set_bucket_public_iam bucket_name: ARGV.shift, role: ARGV.shift, member: ARGV.shift
end
