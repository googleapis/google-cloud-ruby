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

# [START secretmanager_add_secret_version]
require "google/cloud/secret_manager"

##
# Add a new secret version
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def add_secret_version project_id:, secret_id:
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
end
# [END secretmanager_add_secret_version]
