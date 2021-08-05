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

def quickstart project_id: nil, secret_id: nil
  # [START secretmanager_quickstart]
  # project_id  = "YOUR-GOOGLE-CLOUD-PROJECT"  # (e.g. "my-project")
  # secret_id   = "YOUR-SECRET-ID"             # (e.g. "my-secret")

  # Import the Secret Manager client library.
  require "google/cloud/secret_manager"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the parent name from the project.
  parent = "projects/#{project_id}"

  # Create the parent secret.
  secret = client.create_secret(
    parent:    parent,
    secret_id: secret_id,
    secret:    {
      replication: {
        automatic: {}
      }
    }
  )

  # Add a secret version.
  version = client.add_secret_version(
    parent:  secret.name,
    payload: {
      data: "hello world!"
    }
  )

  # Access the secret version.
  response = client.access_secret_version name: version.name

  # Print the secret payload.
  #
  # WARNING: Do not print the secret in a production environment - this
  # snippet is showing how to access the secret material.
  payload = response.payload.data
  puts "Plaintext: #{payload}"
  # [END secretmanager_quickstart]
end

if $PROGRAM_NAME == __FILE__
  quickstart(
    project_id: ENV["GOOGLE_CLOUD_PROJECT"],
    secret_id:  "my-secret-#{Time.now.to_i}"
  )
end
