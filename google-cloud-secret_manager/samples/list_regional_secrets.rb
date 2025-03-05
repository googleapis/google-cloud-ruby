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

# [START secretmanager_list_regional_secrets]
require "google/cloud/secret_manager"

##
# List regional secrets in a project
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your secret location (e.g. "us-west1")
#
def list_regional_secrets project_id:, location_id:
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
end
# [END secretmanager_list_regional_secrets]
