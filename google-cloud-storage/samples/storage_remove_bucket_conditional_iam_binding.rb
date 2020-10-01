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

def remove_bucket_conditional_iam_binding bucket_name:, role:, title:, description:, expression:
  # [START storage_remove_bucket_conditional_iam_binding]
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # title       = "Condition Title"
  # description = "Condition Description"
  # expression  = "Condition Expression"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new
  bucket = storage.bucket bucket_name

  bucket.policy requested_policy_version: 3 do |policy|
    policy.version = 3

    binding_to_remove = nil
    policy.bindings.each do |b|
      condition = {
        title:       title,
        description: description,
        expression:  expression
      }
      if (b.role == role) && (b.condition &&
        b.condition.title == title &&
        b.condition.description == description &&
        b.condition.expression == expression)
        binding_to_remove = b
      end
    end
    if binding_to_remove
      policy.bindings.remove binding_to_remove
      puts "Conditional Binding was removed."
    else
      puts "No matching conditional binding found."
    end
  end
  # [END storage_remove_bucket_conditional_iam_binding]
end

if $PROGRAM_NAME == __FILE__
  remove_bucket_conditional_iam_binding bucket_name: ARGV.shift,
                                        role:        ARGV.shift,
                                        title:       ARGV.shift,
                                        description: ARGV.shift,
                                        expression:  ARGV.shift
end
