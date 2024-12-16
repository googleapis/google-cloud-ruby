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

def access_regional_secret_version project_id:, location_id:, secret_id:, version_id:
  # [START secretmanager_access_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Access the secret version.
  version = client.access_secret_version name: name

  # Print the secret payload.
  #
  # WARNING: Do not print the secret in a production environment - this
  # snippet is showing how to access the secret material.
  payload = version.payload.data
  puts "Plaintext: #{payload}"
  # [END secretmanager_access_regional_secret_version]

  version
end

def add_regional_secret_version project_id:, location_id:, secret_id:
  # [START secretmanager_add_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Add the secret version.
  version = client.add_secret_version(
    parent:  name,
    payload: {
      data: "my super secret data"
    }
  )

  # Print the new secret version name.
  puts "Added regional secret version: #{version.name}"
  # [END secretmanager_add_regional_secret_version]

  version
end

def create_regional_secret project_id:, location_id:, secret_id:
  # [START secretmanager_create_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")sss
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

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
    secret:    {}
  )

  # Print the new secret name.
  puts "Created regional secret: #{secret.name}"
  # [END secretmanager_create_regional_secret]

  secret
end

def delete_regional_secret_with_etag project_id:, location_id:, secret_id:, etag:
  # [START secretmanager_delete_regional_secret_with_etag]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # etag        = "YOUR-ETAG-ASSOCIATED-WITH-SECRET"  # (e.g. "\"1234\"")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Delete the secret.
  client.delete_secret name: name, etag: etag

  # Print a success message.
  puts "Deleted regional secret #{name}"
  # [END secretmanager_delete_regional_secret_with_etag]
end

def delete_regional_secret project_id:, location_id:, secret_id:
  # [START secretmanager_delete_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Delete the secret.
  client.delete_secret name: name

  # Print a success message.
  puts "Deleted regional secret #{name}"
  # [END secretmanager_delete_regional_secret]
end

def destroy_regional_secret_version_with_etag project_id:, location_id:, secret_id:, version_id:, etag:
  # [START secretmanager_destroy_regional_secret_version_with_etag]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"         # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION"        # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"                    # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"                      # (e.g. "5" or "latest")
  # etag        = "YOUR-ETAG-ASSOCIATED-WITH-SECRET"  # (e.g. "\"1234\"")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Destroy the secret version.
  response = client.destroy_secret_version name: name, etag: etag

  # Print a success message.
  puts "Destroyed regional secret version: #{response.name}"
  # [END secretmanager_destroy_regional_secret_version_with_etag]

  response
end

def destroy_regional_secret_version project_id:, location_id:, secret_id:, version_id:
  # [START secretmanager_destroy_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Destroy the secret version.
  response = client.destroy_secret_version name: name

  # Print a success message.
  puts "Destroyed regional secret version: #{response.name}"
  # [END secretmanager_destroy_regional_secret_version]

  response
end

def disable_regional_secret_version_with_etag project_id:, location_id:, secret_id:, version_id:, etag:
  # [START secretmanager_disable_regional_secret_version_with_etag]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"         # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION"        # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"                    # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"                      # (e.g. "5" or "latest")
  # etag        = "YOUR-ASSOCIATED-ETAG WITH SECRET"  # (e.g. "\"1234\"")


  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Disable the secret version.
  response = client.disable_secret_version name: name, etag: etag

  # Print a success message.
  puts "Disabled regional secret version: #{response.name}"
  # [END secretmanager_disable_regional_secret_version_with_etag]

  response
end

def disable_regional_secret_version project_id:, location_id:, secret_id:, version_id:
  # [START secretmanager_disable_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"   # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION"  # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"              # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"                # (e.g. "5" or "latest")


  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Disable the secret version.
  response = client.disable_secret_version name: name

  # Print a success message.
  puts "Disabled regional secret version: #{response.name}"
  # [END secretmanager_disable_regional_secret_version]

  response
end

def enable_regional_secret_version_with_etag project_id:, location_id:, secret_id:, version_id:, etag:
  # [START secretmanager_enable_regional_secret_version_with_etag]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"               # (e.g. "5" or "latest")
  # etag        = "YOUR-ETAG-ASSOCIATED-WITH-SECRET"  # (e.g. "\"1234\"")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Enable the secret version.
  response = client.enable_secret_version name: name, etag: etag

  # Print a success message.
  puts "Enabled regional secret version: #{response.name}"
  # [END secretmanager_enable_regional_secret_version_with_etag]

  response
end

def enable_regional_secret_version project_id:, location_id:, secret_id:, version_id:
  # [START secretmanager_enable_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Enable the secret version.
  response = client.enable_secret_version name: name

  # Print a success message.
  puts "Enabled regional secret version: #{response.name}"
  # [END secretmanager_enable_regional_secret_version]

  response
end

def get_regional_secret project_id:, location_id:, secret_id:
  # [START secretmanager_get_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the secret.
  secret = client.get_secret name: name

  # Print a success message.
  puts "Got regional secret #{secret.name}"
  # [END secretmanager_get_regional_secret]

  secret
end

def get_regional_secret_version project_id:, location_id:, secret_id:, version_id:
  # [START secretmanager_get_regional_secret_version]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id  = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    location:       location_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Get the secret version.
  version = client.get_secret_version name: name

  # Get the state.
  state = version.state.to_s.downcase

  # Print a success message.
  puts "Got regional secret version #{version.name} with state #{state}"
  # [END secretmanager_get_regional_secret_version]

  version
end

def iam_grant_access_regional project_id:, location_id:, secret_id:, member:
  # [START secretmanager_iam_grant_access_with_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # member      = "USER-OR-ACCOUNT"            # (e.g. "user:foo@example.com")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the current IAM policy.
  policy = client.get_iam_policy resource: name

  # Add new member to current bindings
  policy.bindings << Google::Iam::V1::Binding.new(
    members: [member],
    role:    "roles/secretmanager.secretAccessor"
  )

  # Update IAM policy
  new_policy = client.set_iam_policy resource: name, policy: policy

  # Print a success message.
  puts "Updated regional IAM policy for #{secret_id}"
  # [END secretmanager_iam_grant_access_with_regional_secret]

  new_policy
end

def iam_revoke_access_regional project_id:, location_id:, secret_id:, member:
  # [START secretmanager_iam_revoke_access_with_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # member      = "USER-OR-ACCOUNT"            # (e.g. "user:foo@example.com")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the current IAM policy.
  policy = client.get_iam_policy resource: name

  # Remove the member from the current bindings
  policy.bindings.each do |bind|
    if bind.role == "roles/secretmanager.secretAccessor"
      bind.members.delete member
    end
  end

  # Update IAM policy
  new_policy = client.set_iam_policy resource: name, policy: policy

  # Print a success message.
  puts "Updated regional IAM policy for #{secret_id}"
  # [END secretmanager_iam_revoke_access_with_regional_secret]

  new_policy
end

def list_regional_secret_versions_with_filter project_id:, location_id:, secret_id:, filter:
  # [START secretmanager_list_regional_secret_versions_with_filter]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # filter      = "YOUR-FILTER-TO-APPLY"       # (e.g. "create_time>2024-01-01T00:00:00Z")
  # Note : See https://cloud.google.com/secret-manager/docs/filtering for filter syntax and examples.


  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent.
  parent = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the list of secret versions.
  list = client.list_secret_versions parent: parent, filter: filter

  # List all secret versions.
  list.each do |version|
    puts "Got regional secret version #{version.name}"
  end
  # [END secretmanager_list_regional_secret_versions_with_filter]
end

def list_regional_secret_versions project_id:, location_id:, secret_id:
  # [START secretmanager_list_regional_secret_versions]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent.
  parent = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the list of secret versions.
  list = client.list_secret_versions parent: parent

  # List all secret versions.
  list.each do |version|
    puts "Got regional secret version #{version.name}"
  end
  # [END secretmanager_list_regional_secret_versions]
end

def list_regional_secrets_with_filter project_id:, location_id:, filter:
  # [START secretmanager_list_regional_secrets_with_filter]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # filter      = "YOUR-FILTER-TO-APPLY"       # (e.g. "create_time>2024-01-01T00:00:00Z")
  # Note : See https://cloud.google.com/secret-manager/docs/filtering for filter syntax and examples.

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location_id

  # Get the list of secrets.
  list = client.list_secrets parent: parent, filter: filter

  # Print out all secrets.
  list.each do |secret|
    puts "Got regional secret #{secret.name}"
  end
  # [END secretmanager_list_regional_secrets_with_filter]
end

def list_regional_secrets project_id:, location_id:
  # [START secretmanager_list_regional_secrets]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the parent.
  parent = client.location_path project: project_id, location: location_id

  # Get the list of secrets.
  list = client.list_secrets parent: parent

  # Print out all secrets.
  list.each do |secret|
    puts "Got regional secret #{secret.name}"
  end
  # [END secretmanager_list_regional_secrets]
end

def update_regional_secret project_id:, location_id:, secret_id:
  # [START secretmanager_update_regional_secret]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Create the secret.
  secret = client.update_secret(
    secret: {
      name: name,
      labels: {
        secretmanager: "rocks"
      }
    },
    update_mask: {
      paths: ["labels"]
    }
  )

  # Print the updated secret name.
  puts "Updated regional secret: #{secret.name}"
  # [END secretmanager_update_regional_secret]

  secret
end

def update_regional_secret_with_alias project_id:, location_id:, secret_id:
  # [START secretmanager_update_regional_secret_with_alias]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION" # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Create the secret.
  secret = client.update_secret(
    secret: {
      name: name,
      version_aliases: {
        test: 1
      }
    },
    update_mask: {
      paths: ["version_aliases"]
    }
  )

  # Print the updated secret name.
  puts "Updated regional secret: #{secret.name}"
  # [END secretmanager_update_regional_secret_with_alias]

  secret
end

def update_regional_secret_with_etag project_id:, location_id:, secret_id:, etag:
  # [START secretmanager_update_regional_secret_with_etag]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"         # (e.g. "my-project")
  # location_id = "YOUR-GOOGLE-CLOUD-LOCATION"        # (e.g. "us-west1")
  # secret_id   = "YOUR-SECRET-ID"                    # (e.g. "my-secret")
  # etag        = "YOUR-ETAG-ASSOCIATED-WITH-SECRET"  # (e.g. "\"1234\"")


  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Create the secret.
  secret = client.update_secret(
    secret: {
      name: name,
      etag: etag,
      labels: {
        secretmanager: "rocks"
      }
    },
    update_mask: {
      paths: ["labels"]
    }
  )

  # Print the updated secret name.
  puts "Updated regional secret: #{secret.name}"
  # [END secretmanager_update_regional_secret_with_etag]

  secret
end

if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "access_regional_secret_version"
    access_regional_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "add_regional_secret_version"
    add_regional_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "create_regional_secret"
    create_regional_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "delete_regional_secret_with_etag"
    delete_regional_secret_with_etag(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      etag: args.shift
    )
  when "delete_regional_secret"
    delete_regional_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "destroy_regional_secret_version_with_etag"
    destroy_regional_secret_version_with_etag(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift,
      etag: args.shift
    )
  when "destroy_regional_secret_version"
    destroy_regional_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "enable_regional_secret_version_with_etag"
    enable_regional_secret_version_with_etag(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift,
      etag: args.shift
    )
  when "enable_regional_secret_version"
    enable_regional_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "disable_regional_secret_version_with_etag"
    disable_regional_secret_version_with_etag(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift,
      etag: args.shift
    )
  when "disable_secret_version"
    disable_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "get_regional_secret"
    get_regional_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "get_regional_secret_version"
    get_regional_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "iam_grant_access_regional"
    iam_grant_access_regional(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      member:     args.shift
    )
  when "iam_revoke_access_regional"
    iam_revoke_access_regional(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      member:     args.shift
    )
  when "list_regional_secret_versions_with_filter"
    list_regional_secret_versions_with_filter(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      filter: args.shift
    )
  when "list_regional_secret_versions"
    list_regional_secret_versions(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "list_regional_secrets_with_filter"
    list_regional_secrets(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      filter: args.shift
    )
  when "list_regional_secrets"
    list_regional_secrets(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"]
    )
  when "update_regional_secret_with_alias"
    update_regional_secret_with_alias(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  when "update_regional_secret_with_etag"
    update_regional_secret_with_etag(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift,
      etag: args.shift
    )
  when "update_regional_secret"
    update_regional_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      location_id: ENV["GOOGLE_CLOUD_LOCATION"],
      secret_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        access_regional_secret_version <secret> <version>                       Access a regional secret version
        add_regional_secret_version <secret>                                    Add a new regional secret version
        create_regional_secret <secret>                                         Create a new regional secret
        delete_regional_secret_with_etag <secret> <etag>                        Delete an existing regional secret with associated etag
        delete_regional_secret <secret>                                         Delete an existing regional secret
        destroy_regional_secret_version_with_etag <secret> <version> <etag>     Destroy a regional secret version
        destroy_regional_secret_version <secret> <version> <etag>               Destroy a regional secret version
        disable_regional_secret_version_with_etag <secret> <version> <etag>     Disable a regional secret version
        disable_regional_secret_version <secret> <version>                      Disable a regional secret version
        enable_regional_secret_version_with_etag <secret> <version> <etag>      Enable a regional secret version
        enable_regional_secret_version <secret> <version>                       Enable a regional secret version
        get_regional_secret <secret>                                            Get a regional secret
        get_regional_secret_version <secret> <version>                          Get a regional secret version
        iam_grant_access_regional <secret> <version> <member>                   Grant the member access to the regional secret
        iam_revoke_access_regional <secret> <version> <member>                  Revoke the member access to the regional secret
        list_regional_secret_versions_with_filter <secret> <filter>             List all versions for a regional secret
        list_regional_secret_versions <secret>                                  List all versions for a regional secret
        list_regional_secrets_with_filter <filter>                              List all  regional secrets
        list_regional_secrets                                                   List all  regional secrets
        update_regional_secret_with_alias <secret>                              Update a regional secret
        update_regional_secret_with_etag <secret> <etag>                        Update a regional secret
        update_regional_secret <secret>                                         Update a regional secret

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run the regional snippets
        GOOGLE_CLOUD_LOCATION   ID of the Google Cloud location to run the regional snippets
    USAGE
  end
end
