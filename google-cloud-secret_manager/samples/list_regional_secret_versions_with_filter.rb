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

# [START secretmanager_list_regional_secret_versions_with_filter]
require "google/cloud/secret_manager"

##
# List versions for a regional secret
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param filter [String] Your filter to be applied (e.g. "create_time>2021-01-01T00:00:00Z")
# Note : See https://cloud.google.com/secret-manager/docs/filtering for filter syntax and examples.
#
def list_regional_secret_versions_with_filter project_id:, location_id:, secret_id:, filter:
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
end
# [END secretmanager_list_regional_secret_versions_with_filter]
