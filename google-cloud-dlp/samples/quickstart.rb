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

# [START dlp_quickstart]
# Imports the Google Cloud client library
require "google/cloud/dlp"

# Instantiates a client
dlp = Google::Cloud::Dlp.dlp_service

request_configuration = {
  # The types of information to match
  info_types:     [{ name: "PERSON_NAME" }, { name: "US_STATE" }],

  # Only return results above a likelihood threshold (0 for all)
  min_likelihood: :LIKELIHOOD_UNSPECIFIED,

  # Limit the number of findings (0 for no limit)
  limits:         { max_findings_per_request: 0 },

  # Whether to include the matching string in the response
  include_quote:  true
}

# The items to inspect
item_to_inspect = { value: "Robert Frost" }

# Run request
parent = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}/locations/global"
response = dlp.inspect_content parent:         parent,
                               inspect_config: request_configuration,
                               item:           item_to_inspect

# Print the results
response.result.findings.each do |finding|
  puts "Quote:      #{finding.quote}"
  puts "Info type:  #{finding.info_type.name}"
  puts "Likelihood: #{finding.likelihood}"
end
# [END dlp_quickstart]
