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

def inspect_string project_id: nil, content: nil, max_findings: 0
  # [START dlp_inspect_string]
  # project_id   = "Your Google Cloud project ID"
  # content      = "The text to inspect"
  # max_findings = "Maximum number of findings to report per request (0 = server maximum)"

  require "google/cloud/dlp"

  dlp = Google::Cloud::Dlp.dlp_service
  inspect_config = {
    # The types of information to match
    info_types:     [{ name: "PERSON_NAME" }, { name: "US_STATE" }],

    # Only return results above a likelihood threshold (0 for all)
    min_likelihood: :POSSIBLE,

    # Limit the number of findings (0 for no limit)
    limits:         { max_findings_per_request: max_findings },

    # Whether to include the matching string in the response
    include_quote:  true
  }

  # The item to inspect
  item_to_inspect = { value: content }

  # Run request
  parent = "projects/#{project_id}/locations/global"
  response = dlp.inspect_content parent:         parent,
                                 inspect_config: inspect_config,
                                 item:           item_to_inspect

  # Print the results
  if response.result.findings.empty?
    puts "No findings"
  else
    response.result.findings.each do |finding|
      puts "Quote:      #{finding.quote}"
      puts "Info type:  #{finding.info_type.name}"
      puts "Likelihood: #{finding.likelihood}"
    end
  end
  # [END dlp_inspect_string]
end

def inspect_file project_id: nil, filename: nil, max_findings: 0
  # [START dlp_inspect_file]
  # project_id   = "Your Google Cloud project ID"
  # filename     = "The file path to the file to inspect"
  # max_findings = "Maximum number of findings to report per request (0 = server maximum)"

  require "google/cloud/dlp"

  dlp = Google::Cloud::Dlp.dlp_service
  inspect_config = {
    # The types of information to match
    info_types:     [{ name: "PERSON_NAME" }, { name: "PHONE_NUMBER" }],

    # Only return results above a likelihood threshold (0 for all)
    min_likelihood: :POSSIBLE,

    # Limit the number of findings (0 for no limit)
    limits:         { max_findings_per_request: max_findings },

    # Whether to include the matching string in the response
    include_quote:  true
  }

  # The item to inspect
  file = File.open filename, "rb"
  item_to_inspect = { byte_item: { type: :BYTES_TYPE_UNSPECIFIED, data: file.read } }

  # Run request
  parent = "projects/#{project_id}/locations/global"
  response = dlp.inspect_content parent:         parent,
                                 inspect_config: inspect_config,
                                 item:           item_to_inspect

  # Print the results
  if response.result.findings.empty?
    puts "No findings"
  else
    response.result.findings.each do |finding|
      puts "Quote:      #{finding.quote}"
      puts "Info type:  #{finding.info_type.name}"
      puts "Likelihood: #{finding.likelihood}"
    end
  end
  # [END dlp_inspect_file]
end

if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "inspect_string"
    inspect_string(
      project_id:   project_id,
      content:      ARGV.shift.to_s,
      max_findings: ARGV.shift.to_i
    )
  when "inspect_file"
    inspect_file(
      project_id:   project_id,
      filename:     ARGV.shift.to_s,
      max_findings: ARGV.shift.to_i
    )
  else
    puts <<~USAGE
      Usage: ruby sample.rb <command> [arguments]

      Commands:
        inspect_string <content> <max_findings> Inspect a string.
        inspect_file <filename> <max_findings> Inspect a local file.

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
        GOOGLE_APPLICATION_CREDENTIALS set to the path to your JSON credentials
    USAGE
  end
end
