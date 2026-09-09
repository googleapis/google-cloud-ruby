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

# [START secretmanager_update_secret_with_delayed_destroy]
require "google/cloud/secret_manager"

##
# Update secret with delayed destroy.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param updated_time_to_live [Integer] Your ttl in seconds for new secret versions (e.g., 86400)
#
def update_secret_with_delayed_destroy project_id:, secret_id:, updated_time_to_live:
  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Updates the secret.
  secret = client.update_secret(
    secret: {
      name: name,
      version_destroy_ttl: {
        seconds: updated_time_to_live
      }
    },
    update_mask: {
      paths: ["version_destroy_ttl"]
    }
  )

  # Print the updated secret name and annotations.
  puts "Updated secret: #{secret.name}"
  puts "New updated secret version ttl: #{secret.version_destroy_ttl}"
end
# [END secretmanager_update_secret_with_delayed_destroy]
