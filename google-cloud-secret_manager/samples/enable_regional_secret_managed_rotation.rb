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

# [START secretmanager_enable_regional_secret_managed_rotation]
require "google/cloud/secret_manager"

##
# Enables managed rotation of a CLOUD_SQL_DB_CREDENTIALS typed secret.
# It validates and enables the rotation, adding a version and sets the
# passed password (optional).
# Note: AddSecretVersion is disabled on the CLOUD_SQL_DB_CREDENTIALS
# currently and for any necessary manual rotations please trigger
# rotate_secret.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param instance_id [String] Your Cloud SQL instance id (e.g. "my-instance")
# @param username [String] Your Cloud SQL database username (e.g. "my-user")
#
def enable_regional_secret_managed_rotation project_id:, location_id:, secret_id:, instance_id:, username:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  parent = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Enable managed rotation.
  version = client.enable_managed_rotation(
    parent:                            parent,
    cloud_sql_single_user_credentials: {
      instance_id: instance_id,
      username:    username
    }
  )

  # Print the new secret version name.
  puts "Enabled managed rotation, created secret version: #{version.name}"

  version
end
# [END secretmanager_enable_regional_secret_managed_rotation]
