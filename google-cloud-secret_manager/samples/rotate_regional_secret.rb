# Copyright 2026 Google LLC
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

# [START secretmanager_rotate_regional_secret]
require "google/cloud/secret_manager"

##
# Trigger a managed rotation for a Cloud SQL DB credentials secret.
# Managed rotation must already be enabled on the secret (see
# enable_regional_secret_managed_rotation). Each call generates a new
# password, updates the Cloud SQL user, and adds the result as a new
# secret version.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your Cloud SQL DB credentials secret name (e.g. "my-secret")
#
def rotate_regional_secret project_id:, location_id:, secret_id:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret. Despite its name, `parent` here
  # is the full secret resource name, not a collection parent -- the
  # generated request message only defines a `parent` field.
  parent = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Rotate the secret.
  version = client.rotate_secret parent: parent

  # Print the new secret version name.
  puts "Rotated secret, created secret version: #{version.name}"

  version
end
# [END secretmanager_rotate_regional_secret]
