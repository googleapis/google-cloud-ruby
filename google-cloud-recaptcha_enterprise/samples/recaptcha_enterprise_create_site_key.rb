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

# [START recaptcha_enterprise_create_site_key]
require "google/cloud/recaptcha_enterprise"

# Create a site key by registering a domain/app to use recaptcha services.
#
# @param project_id [String] GCloud Project ID.
# @param domain [String] Domain to register for recaptcha services.
# @return [void]
def create_site_key project_id:, domain:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  request = {
    parent: "projects/#{project_id}",
    key: {
      display_name: "any descriptive name for the key",
      web_settings: {
        allowed_domains: [domain],
        allow_amp_traffic: false,
        integration_type: 1
      }
    }
  }

  # Get the name of the created reCAPTCHA site key.
  response = client.create_key request
  recaptcha_site_key = response.name.split("/").last
  puts "reCAPTCHA Site key created successfully. Site Key: #{recaptcha_site_key}"
end
# [END recaptcha_enterprise_create_site_key]

create_site_key project_id: ARGV.shift, domain: ARGV.shift if $PROGRAM_NAME == __FILE__
