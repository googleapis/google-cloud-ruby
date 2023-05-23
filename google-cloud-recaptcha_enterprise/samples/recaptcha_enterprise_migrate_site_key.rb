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

# [START recaptcha_enterprise_migrate_site_key]
require "google/cloud/recaptcha_enterprise"

# Migrate a key from reCAPTCHA (non-Enterprise) to reCAPTCHA Enterprise.
#
# @param project_id [String] GCloud Project ID.
# @param site_key [String] Site key to be updated.
# @return [void]
def migrate_site_key project_id:, site_key:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  response = client.migrate_key name: "projects/#{project_id}/keys/#{site_key}"

  # To verify if the site key has been migrated, use 'list_keys' to check if the
  # key is present.
  keys = client.list_keys parent: "projects/#{project_id}"
  keys.each do |key|
    puts "Key migrated successfully: #{site_key}" if key.name == response.name
  end
end
# [END recaptcha_enterprise_migrate_site_key]

migrate_site_key project_id: ARGV.shift, site_key: ARGV.shift if $PROGRAM_NAME == __FILE__
