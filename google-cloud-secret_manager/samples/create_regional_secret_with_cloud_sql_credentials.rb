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

# [START secretmanager_create_regional_secret_with_cloud_sql_credentials]
require "google/cloud/secret_manager"

##
# Create a regional secret with the Cloud SQL DB credentials secret type.
# This type is required to enable Secret Manager's automatic rotation of
# Cloud SQL passwords. It can only be set when the secret is created, and
# the secret's location must match the region of the target Cloud SQL
# instance.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def create_regional_secret_with_cloud_sql_credentials project_id:, location_id:, secret_id:
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
    secret:    {
      secret_type: :CLOUD_SQL_DB_CREDENTIALS
    }
  )

  # Print the new secret name.
  puts "Created regional secret: #{secret.name}"

  # This built-in identity is what you grant Cloud SQL IAM permissions to,
  # so that Secret Manager can rotate the database password on its behalf.
  puts "Grant this identity Cloud SQL IAM permissions to enable rotation: " \
       "#{secret.policy_member.iam_policy_uid_principal}"

  secret
end
# [END secretmanager_create_regional_secret_with_cloud_sql_credentials]
