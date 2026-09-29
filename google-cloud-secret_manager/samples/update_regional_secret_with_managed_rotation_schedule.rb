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

# [START secretmanager_update_regional_secret_with_managed_rotation_schedule]
require "google/cloud/secret_manager"

##
# Reconfigure the recurring rotation schedule on a secret that already has
# Cloud SQL managed rotation enabled (see
# enable_regional_secret_managed_rotation). This only applies to regional
# secrets of the CLOUD_SQL_DB_CREDENTIALS type -- calling it on any other
# secret type, or before managed rotation has been enabled, fails.
#
# rotation_period_seconds is the interval between rotations, in whole
# seconds. The service requires it to be at least 3600 (1 hour), and the
# derived next_rotation_time (now + rotation_period_seconds) must be at
# least 300 seconds (5 minutes) in the future -- both are enforced by the
# API, not checked client-side here.
#
# @param project_id [String] Your Google Cloud project (e.g. "my-project")
# @param location_id [String] Your Google Cloud location (e.g. "us-west1")
# @param secret_id [String] Your Cloud SQL DB credentials secret name (e.g. "my-secret")
# @param rotation_period_seconds [Integer] Seconds between rotations (e.g. 3600)
#
def update_regional_secret_with_managed_rotation_schedule project_id:, location_id:, secret_id:,
                                                          rotation_period_seconds:
  # Endpoint for the regional secret manager service.
  api_endpoint = "secretmanager.#{location_id}.rep.googleapis.com"

  # Create the Secret Manager client.
  client = Google::Cloud::SecretManager.secret_manager_service do |config|
    config.endpoint = api_endpoint
  end

  # Build the resource name of the secret.
  name = client.secret_path project: project_id, location: location_id, secret: secret_id

  # next_rotation_time and rotation_period must be set together.
  next_rotation_timestamp = Time.now.to_i + rotation_period_seconds

  # Update the secret's rotation schedule. The update mask names only the
  # two subfields being set here, not the whole "rotation" submessage --
  # that would also include managed_rotation_status, which is output-only
  # and rejects a whole-submessage replace with "immutable and cannot be
  # updated" (confirmed empirically against a live project).
  secret = client.update_secret(
    secret:      {
      name:     name,
      rotation: {
        next_rotation_time: { seconds: next_rotation_timestamp },
        rotation_period:    { seconds: rotation_period_seconds }
      }
    },
    update_mask: {
      paths: ["rotation.next_rotation_time", "rotation.rotation_period"]
    }
  )

  # Print the updated secret name.
  puts "Updated regional secret rotation schedule: #{secret.name}"

  secret
end
# [END secretmanager_update_regional_secret_with_managed_rotation_schedule]
