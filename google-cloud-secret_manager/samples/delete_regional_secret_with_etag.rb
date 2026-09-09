# Copyright 2022 Google LLC
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

# [START secretmanager_delete_regional_secret_with_etag]
require "google/cloud/secret_manager"

##
# Delete a regional secret with the passing etag and name
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param etag [String] The e-tag associated with the secret (e.g. "\"1234\"")
#
def delete_regional_secret_with_etag project_id:, location_id:, secret_id:, etag:
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
end
# [END secretmanager_delete_regional_secret_with_etag]
