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

# [START recaptcha_enterprise_get_metrics_site_key]
require "google/cloud/recaptcha_enterprise"

#  Get metrics specific to a recaptcha site key.
#  E.g: score bucket count for a key or number of
#  times the checkbox key failed/ passed etc.,
#
# @param project_id [String] GCloud Project ID.
# @param site_key [String] Site key to be updated.
# @return [void]
def get_metrics_site_key project_id:, site_key:
  # Create the reCAPTCHA client.
  client = ::Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service

  response = client.get_metrics name: "projects/#{project_id}/keys/#{site_key}/metrics"

  # Retrieve the metrics you want from the key.
  # If the site key is checkbox type: then use response.challenge_metrics
  # instead of response.score_metrics
  puts "Retrieved the bucket count for score based key: #{site_key}"
  response.score_metrics.each do |day_metric|
    # Each 'day_metric' is in the granularity of one day.
    score_bucket_count = day_metric.overall_metrics.score_buckets
    puts score_bucket_count.inspect
  end
end
# [END recaptcha_enterprise_get_metrics_site_key]

get_metrics_site_key project_id: ARGV.shift, site_key: ARGV.shift if $PROGRAM_NAME == __FILE__
