# Copyright 2020 Google LLC
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

require "google/cloud/recaptcha_enterprise/v1"

def create_assessment
  ### Create an assessment to analyze the risk of a UI action.

  # Args:
  # project_id: GCloud Project ID
  # site_key: Site key obtained by registering a domain/app to use recaptcha services.
  # token: The token obtained from the client on passing the recaptcha site_key.
  # recaptcha_action: Action name corresponding to the token.
  # assessment_name: Specify a name for this assessment.
  ###

  site_key = "your_site_key"
  token = "user_response_token"
  project_id = "your_project_id"
  recaptcha_action = "action_name"
  assessment_name = "assessment_name"
  project_name = "projects/#{project_id}"

  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client.new

  # Set the properties of the event to be tracked.
  event = ::Google::Cloud::RecaptchaEnterprise::V1::Event.new
  event.site_key = site_key
  event.token = token

  assessment = ::Google::Cloud::RecaptchaEnterprise::V1::Assessment.new
  assessment.event = event
  assessment.name = assessment_name

  # Build the assessment request.
  request = ::Google::Cloud::RecaptchaEnterprise::V1::CreateAssessmentRequest.new
  request.parent = project_name
  request.assessment = assessment

  response = client.create_assessment request

  # Check if the token is valid.
  if !response.token_properties.valid
    puts "The create_assessment() call failed because the token was invalid with the following reason: #{response.token_properties.invalid_reason}"
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
