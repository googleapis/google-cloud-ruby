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

# [START secretmanager_update_secret]
require "google/cloud/secret_manager"

##
# Update a secret's labels
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def update_secret project_id:, secret_id:
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

  # Print the updated secret name and the new label value.
  puts "Updated secret: #{secret.name}"
  puts "New label: #{secret.labels['secretmanager']}"
end
# [END secretmanager_update_secret]
