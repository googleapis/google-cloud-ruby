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

# [START recaptcha_enterprise_list_site_keys]
require "google/cloud/recaptcha_enterprise"

# List all site keys registered to use recaptcha services.
#
# @param project_id [String] GCloud Project ID.
# @return [void]
def list_site_keys project_id:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  response = client.list_keys parent: "projects/#{project_id}"
  puts "Listing reCAPTCHA site keys: "
  response.each do |key|
    puts key.name
  end
end
# [END recaptcha_enterprise_list_site_keys]

list_site_keys project_id: ARGV.shift if $PROGRAM_NAME == __FILE__
