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

# [START secretmanager_create_regional_secret_with_tags]
require "google/cloud/secret_manager"

##
# Create a regional secret with tags
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param tag_key [String] Your tag key (e.g. "my-tag-key")
# @param tag_value [String] Your tag value (e.g "my-tag-value")
#
def create_regional_secret_with_tags project_id:, location_id:, secret_id:, tag_key:, tag_value:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent project.
  parent = client.location_path project: project_id, location: location_id

  # Create the secret.
  secret = client.create_secret(
    parent:    parent,
    secret_id: secret_id,
    secret: {
      tags: {
        tag_key.name => tag_value.name
      }
    }
  )

  # Print the new secret name.
  puts "Created regional secret with tags: #{secret.name}"
end
# [END secretmanager_create_regional_secret_with_tags]
