# Copyright 2025 Google LLC
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

# [START secretmanager_create_secret_with_delayed_destroy]
require "google/cloud/secret_manager"

##
# Create a secret with delayed destroy.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param time_to_live [Integer] Your delayed destroy ttl in seconds for secret versions (e.g. 86400)
#
def create_secret_with_delayed_destroy project_id:, secret_id:, time_to_live:
  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the parent project.
  parent = client.project_path project: project_id

  # Create the secret.
  secret = client.create_secret(
    parent:    parent,
    secret_id: secret_id,
    secret:    {
      replication: {
        automatic: {}
      },
      version_destroy_ttl: {
        seconds: time_to_live
      }
    }
  )

  # Print the new secret name.
  puts "Created secret: #{secret.name}"
end
# [END secretmanager_create_secret_with_delayed_destroy]
