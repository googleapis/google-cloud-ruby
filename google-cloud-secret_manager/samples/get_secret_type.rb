# Copyright 2026 Google LLC
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

# [START secretmanager_get_secret_type]
require "google/cloud/secret_manager"

##
# Get and print the secret type (e.g. CLOUD_SQL_DB_CREDENTIALS, ACCESS_KEY,
# CERTIFICATE, OTHER_DB_CREDENTIALS, OTHER, or SECRET_TYPE_UNSPECIFIED for
# a secret with no type restriction) of the given secret.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param secret_id [String] Your secret name (e.g. "my-secret")
#
def get_secret_type project_id:, secret_id:
  # Create a Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, secret: secret_id

  # Get the secret.
  secret = client.get_secret name: name

  # Print the secret's type.
  puts "Found secret #{secret.name} with secret type #{secret.secret_type}"

  secret
end
# [END secretmanager_get_secret_type]
