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

# [START secretmanager_iam_grant_access]
require "google/cloud/secret_manager"

##
# Update the IAM policy to grant access to a user
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param member [String] User or account (e.g. "user:foo@example.com")
#
def iam_grant_access project_id:, secret_id:, member:
  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Get the current IAM policy.
  policy = client.get_iam_policy resource: name

  # Add new member to current bindings
  policy.bindings << Google::Iam::V1::Binding.new(
    members: [member],
    role:    "roles/secretmanager.secretAccessor"
  )

  # Update IAM policy
  client.set_iam_policy resource: name, policy: policy

  # Print a success message.
  puts "Updated IAM policy for #{secret_id}"
end
# [END secretmanager_iam_grant_access]
