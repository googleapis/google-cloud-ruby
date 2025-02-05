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

# [START secretmanager_edit_secret_annotations]
require "google/cloud/secret_manager"

##
# Edits a secret annotations.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
# @param annotation_key [String] Your annotation key (e.g. "my-annotation-key")
# @param annotation_value [String] Your annotation value (e.g. "my-annotation-value")
#
def edit_secret_annotations project_id:, secret_id:, annotation_key:, annotation_value:
  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Get the existing secret.
  existing_secret = client.get_secret name: name

  # Get the existing secret's annotations.
  existing_secret_annotations = existing_secret.annotations.to_h

  # Add a new annotation key and value.
  existing_secret_annotations[annotation_key] = annotation_value

  # Updates the secret.
  secret = client.update_secret(
    secret: {
      name: name,
      annotations: existing_secret_annotations
    },
    update_mask: {
      paths: ["annotations"]
    }
  )

  # Print the updated secret name and annotations.
  puts "Updated secret: #{secret.name}"
  puts "New updated annotations: #{secret.annotations}"
end
# [END secretmanager_edit_secret_annotations]
