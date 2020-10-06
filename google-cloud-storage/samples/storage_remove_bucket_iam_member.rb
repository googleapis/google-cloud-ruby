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

def remove_bucket_iam_member bucket_name:, role:, member:
  # [START storage_remove_bucket_iam_member]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.bindings.each do |binding|
      if binding.role == role && binding.condition.nil?
        binding.members.delete member
      end
    end
  end

  puts "Removed #{member} with role #{role} from #{bucket_name}"
  # [END storage_remove_bucket_iam_member]
end

if $PROGRAM_NAME == __FILE__
  remove_bucket_iam_member bucket_name: ARGV.shift, role: ARGV.shift, member: ARGV.shift
end
