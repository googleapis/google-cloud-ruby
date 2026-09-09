# Copyright 2021 Google LLC
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

# [START recaptcha_enterprise_create_assessment]
require "google/cloud/recaptcha_enterprise"

# Create an assessment to analyze the risk of a UI action.
#
# @param site_key [String] Site key obtained by registering a domain/app to use recaptcha services.
# @param token [String] The token obtained from the client on passing the recaptcha site_key.
# @param project_id [String] GCloud Project ID.
# @param recaptcha_action [String] Action name corresponding to the token.
# @return [void]
def create_assessment site_key:, token:, project_id:, recaptcha_action:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  request = { parent: "projects/#{project_id}",
              assessment: {
                event: {
                  site_key: site_key,
                  token: token
                }
              } }

  response = client.create_assessment request

  # Check if the token is valid.
  if !response.token_properties.valid
    puts "The create_assessment() call failed because the token was invalid with the following reason:" \
         "#{response.token_properties.invalid_reason}"
  # Check if the expected action was executed.
  elsif response.token_properties.action == recaptcha_action
    # Get the risk score and the reason(s).
    # For more information on interpreting the assessment,
    # see: https://cloud.google.com/recaptcha-enterprise/docs/interpret-assessment
    puts "The reCAPTCHA score for this token is: #{response.risk_analysis.score}"
    response.risk_analysis.reasons.each { |reason| puts reason }
  else
    puts "The action attribute in your reCAPTCHA tag does not match the action you are expecting to score"
  end
end
# [END recaptcha_enterprise_create_assessment]

if $PROGRAM_NAME == __FILE__
  create_assessment site_key: ARGV.shift,
                    token: ARGV.shift,
                    project_id: ARGV.shift,
                    recaptcha_action: ARGV.shift
end
