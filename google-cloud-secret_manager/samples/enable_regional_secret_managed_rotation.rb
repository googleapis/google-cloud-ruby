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
# Enable managed rotation for a Cloud SQL DB credentials secret. This
# links the secret to a Cloud SQL instance and database user, and can only
# be called once per secret. It adds the secret's first version and sets
# the matching password on the Cloud SQL user, taking the place of a
# manually added secret version, which this secret type doesn't support.
# Afterwards, use rotate_regional_secret to trigger further rotations.
#
# instance_id is the bare Cloud SQL instance ID (e.g. "my-instance") --
# not a connection name. Neither the project nor the region should be
# included: passing "PROJECT_ID:INSTANCE_ID" or the full
# "PROJECT_ID:LOCATION_ID:INSTANCE_ID" connection name both fail -- the
# service already knows the project from the secret's own path, and
# prepends it internally, so a qualified value ends up double-prefixed.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your Cloud SQL DB credentials secret name (e.g. "my-secret")
# @param instance_id [String] Your bare Cloud SQL instance id (e.g. "my-instance")
# @param username [String] Your Cloud SQL database username (e.g. "my-user")
#
def enable_regional_secret_managed_rotation project_id:, location_id:, secret_id:, instance_id:, username:
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

  # Enable managed rotation. Leaving password unset lets Secret Manager
  # generate a secure password itself.
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
