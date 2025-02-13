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

# [START secretmanager_create_regional_secret_with_annotations]
require "google/cloud/secret_manager"

##
# Create a regional secret with annotations
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param annotation_key [String] Your annotation key (e.g. "my-annotation-key")
# @param annotation_value [String] Your annotation value (e.g "my-annotation-value")
#
def create_regional_secret_with_annotations project_id:, location_id:, secret_id:, annotation_key:, annotation_value:
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
      annotations: {
        annotation_key => annotation_value
      }
    }
  )

  # Print the new secret name.
  puts "Created regional secret with annotations: #{secret.name}"
end
# [END secretmanager_create_regional_secret_with_annotations]
