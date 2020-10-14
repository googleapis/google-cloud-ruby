# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def complete_query project_id, tenant_id, query, page_size, language_code
  # [START job_search_autocomplete_job_title]
  require "google/cloud/talent"

  # Instantiate a client
  completion_service = Google::Cloud::Talent.completion

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  formatted_parent = completion_service.tenant_path project: project_id, tenant: tenant_id

  # language_code = "en-US"
  language_codes = [language_code]

  # query = "[partially typed job title]"
  # page_size: page_size = 5
  response = completion_service.complete_query tenant:         formatted_parent,
                                               query:          query,
                                               page_size:      page_size,
                                               language_codes: language_codes

  response.completion_results.each do |result|
    puts "Suggested title: #{result.suggestion}"
    # Suggestion type is JOB_TITLE or COMPANY_NAME
    puts "Suggestion type: #{result.type}"
  end
  # [END job_search_autocomplete_job_title]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is required)"
  query = "[partially typed job title]"
  page_size = 5
  language_code = "en-US"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--query=val") { |val| query = val }
    opts.on("--page_size=val") { |val| page_size = val }
    opts.on("--language_code=val") { |val| language_code = val }
    opts.parse!
  end

  complete_query project_id, tenant_id, query, page_size, language_code
end
