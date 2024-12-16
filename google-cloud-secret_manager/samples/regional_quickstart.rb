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

# [START secretmanager_regional_quickstart]
require "google/cloud/secret_manager"

##
# Secret manager regional quickstart
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def regional_quickstart project_id:, location_id:, secret_id:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the parent name from the project.
  parent = "projects/#{project_id}/locations/#{location_id}"

  # Create the parent secret.
  secret = client.create_secret(
    parent:    parent,
    secret_id: secret_id,
    secret:    {}
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
end
# [END secretmanager_regional_quickstart]
