# Copyright 2025 Google LLC
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

# [START secretmanager_view_regional_secret_annotations]
require "google/cloud/secret_manager"

##
# Edit a regional secret annotations
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west11")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def view_regional_secret_annotations project_id:, location_id:, secret_id:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # Get the existing secret.
  existing_secret = client.get_secret name: name

  # Get the existing secret's annotations.
  existing_secret_annotations = existing_secret.annotations.to_h

  # Print the secret name and the annotations.
  puts "Regional Secret: #{existing_secret.name}"
  existing_secret_annotations.each do |key, value|
    puts "Annotation Key: #{key}, Annotation Value: #{value}"
  end
end
# [END secretmanager_view_regional_secret_annotations]
