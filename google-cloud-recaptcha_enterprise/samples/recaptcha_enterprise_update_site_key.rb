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

# [START recaptcha_enterprise_update_site_key]
require "google/cloud/recaptcha_enterprise"

# Update a site key registered for a domain/app to use recaptcha services.
#
# @param project_id [String] GCloud Project ID.
# @param site_key [String] Site key to be updated.
# @param domain [String] Domain to register for recaptcha services.
# @return [void]
def update_site_key project_id:, site_key:, domain:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  request_key = client.get_key name: "projects/#{project_id}/keys/#{site_key}"
  request_key.web_settings.allowed_domains.push domain
  request_key.web_settings.allow_amp_traffic = true

  client.update_key key: request_key

  # Retrieve the key and check if the property is updated.
  response = client.get_key name: "projects/#{project_id}/keys/#{site_key}"
  web_settings = response.web_settings

  puts "reCAPTCHA Site key successfully updated with allow_amp_traffic to #{web_settings.allow_amp_traffic}!"
end
# [END recaptcha_enterprise_update_site_key]

update_site_key project_id: ARGV.shift, site_key: ARGV.shift, domain: ARGV.shift if $PROGRAM_NAME == __FILE__
