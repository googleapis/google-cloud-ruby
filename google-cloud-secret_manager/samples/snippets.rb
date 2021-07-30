# Copyright 2020 Google, Inc
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

def access_secret_version project_id:, secret_id:, version_id:
  # [START secretmanager_access_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
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
  # [END secretmanager_access_secret_version]

  version
end

def add_secret_version project_id:, secret_id:
  # [START secretmanager_add_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_path project: project_id, secret: secret_id

  # Add the secret version.
  version = client.add_secret_version(
    parent:  name,
    payload: {
      data: "my super secret data"
    }
  )

  # Print the new secret version name.
  puts "Added secret version: #{version.name}"
  # [END secretmanager_add_secret_version]

  version
end

def create_secret project_id:, secret_id:
  # [START secretmanager_create_secret]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

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
      }
    }
  )

  # Print the new secret name.
  puts "Created secret: #{secret.name}"
  # [END secretmanager_create_secret]

  secret
end

def delete_secret project_id:, secret_id:
  # [START secretmanager_delete_secret]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Delete the secret.
  client.delete_secret name: name

  # Print a success message.
  puts "Deleted secret #{name}"
  # [END secretmanager_delete_secret]
end

def destroy_secret_version project_id:, secret_id:, version_id:
  # [START secretmanager_destroy_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Destroy the secret version.
  response = client.destroy_secret_version name: name

  # Print a success message.
  puts "Destroyed secret version: #{response.name}"
  # [END secretmanager_destroy_secret_version]

  response
end

def disable_secret_version project_id:, secret_id:, version_id:
  # [START secretmanager_disable_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Disable the secret version.
  response = client.disable_secret_version name: name

  # Print a success message.
  puts "Disabled secret version: #{response.name}"
  # [END secretmanager_disable_secret_version]

  response
end

def enable_secret_version project_id:, secret_id:, version_id:
  # [START secretmanager_enable_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Enable the secret version.
  response = client.enable_secret_version name: name

  # Print a success message.
  puts "Enabled secret version: #{response.name}"
  # [END secretmanager_enable_secret_version]

  response
end

def get_secret project_id:, secret_id:
  # [START secretmanager_get_secret]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Get the secret.
  secret = client.get_secret name: name

  # Get the replication policy.
  if !secret.replication.automatic.nil?
    replication = "automatic"
  elsif !secret.replication.user_managed.nil?
    replication = "user managed"
  else
    raise "Unknown replication #{secret.replication}"
  end

  # Print a success message.
  puts "Got secret #{secret.name} with replication policy #{replication}"
  # [END secretmanager_get_secret]

  secret
end

def get_secret_version project_id:, secret_id:, version_id:
  # [START secretmanager_get_secret_version]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # version_id = "YOUR-VERSION"               # (e.g. "5" or "latest")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret version.
  name = client.secret_version_path(
    project:        project_id,
    secret:         secret_id,
    secret_version: version_id
  )

  # Get the secret version.
  version = client.get_secret_version name: name

  # Get the state.
  state = version.state.to_s.downcase

  # Print a success message.
  puts "Got secret version #{version.name} with state #{state}"
  # [END secretmanager_get_secret_version]

  version
end

def iam_grant_access project_id:, secret_id:, member:
  # [START secretmanager_iam_grant_access]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # member     = "USER-OR-ACCOUNT"            # (e.g. "user:foo@example.com")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

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
  new_policy = client.set_iam_policy resource: name, policy: policy

  # Print a success message.
  puts "Updated IAM policy for #{secret_id}"
  # [END secretmanager_iam_grant_access]

  new_policy
end

def iam_revoke_access project_id:, secret_id:, member:
  # [START secretmanager_iam_revoke_access]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")
  # member     = "USER-OR-ACCOUNT"            # (e.g. "user:foo@example.com")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

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
  puts "Updated IAM policy for #{secret_id}"
  # [END secretmanager_iam_revoke_access]

  new_policy
end

def list_secret_versions project_id:, secret_id:
  # [START secretmanager_list_secret_versions]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the parent.
  parent = client.secret_path project: project_id, secret: secret_id

  # Get the list of secret versions.
  list = client.list_secret_versions parent: parent

  # List all secret versions.
  list.each do |version|
    puts "Got secret version #{version.name}"
  end
  # [END secretmanager_list_secret_versions]
end

def list_secrets project_id:
  # [START secretmanager_list_secrets]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the parent.
  parent = client.project_path project: project_id

  # Get the list of secrets.
  list = client.list_secrets parent: parent

  # Print out all secrets.
  list.each do |secret|
    puts "Got secret #{secret.name}"
  end
  # [END secretmanager_list_secrets]
end

def update_secret project_id:, secret_id:
  # [START secretmanager_update_secret]
  # project_id = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id  = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Require the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

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
  puts "Updated secret: #{secret.name}"
  # [END secretmanager_update_secret]

  secret
end

if $PROGRAM_NAME == __FILE__
  args    = ARGV.dup
  command = args.shift

  case command
  when "access_secret_version"
    access_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "add_secret_version"
    add_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  when "create_secret"
    create_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  when "delete_secret"
    delete_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  when "destroy_secret_version"
    destroy_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "enable_secret_version"
    enable_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "disable_secret_version"
    disable_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "get_secret"
    get_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  when "get_secret_version"
    get_secret_version(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      version_id: args.shift
    )
  when "iam_grant_access"
    iam_grant_access(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      member:     args.shift
    )
  when "iam_revoke_access"
    iam_revoke_access(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift,
      member:     args.shift
    )
  when "list_secret_versions"
    list_secret_versions(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  when "list_secrets"
    list_secrets(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"]
    )
  when "update_secret"
    update_secret(
      project_id: ENV["GOOGLE_CLOUD_PROJECT"],
      secret_id:  args.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby #{__FILE__} [command] [arguments]

      Commands:
        access_secret_version <secret> <version>           Access a secret version
        add_secret_version <secret>                        Add a new secret version
        create_secret <secret>                             Create a new secret
        delete_secret <secret>                             Delete an existing secret
        destroy_secret_version <secret> <version>          Destroy a secret version
        disable_secret_version <secret> <version>          Disable a secret version
        enable_secret_version <secret> <version>           Enable a secret version
        get_secret <secret>                                Get a secret
        get_secret_version <secret> <version>              Get a secret version
        iam_grant_access <secret> <version> <member>       Grant the member access to the secret
        iam_revoke_access <secret> <version> <member>      Revoke the member access to the secret
        list_secret_versions <secret>                      List all versions for a secret
        list_secrets                                       List all secrets
        update_secret <secret>                             Update a secret

      Environment variables:
        GOOGLE_CLOUD_PROJECT    ID of the Google Cloud project to run snippets
    USAGE
  end
end
