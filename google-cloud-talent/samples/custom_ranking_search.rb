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

def sample_custom_ranking_search project_id, tenant_id
  # [START job_search_custom_ranking_search]
  require "google/cloud/talent"

  # Instantiate a client
  job_service = Google::Cloud::Talent.job_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  parent = job_service.tenant_path project: project_id, tenant: tenant_id
  domain = "www.example.com"
  session_id = "Hashed session identifier"
  user_id = "Hashed user identifier"
  request_metadata = {
    domain:     domain,
    session_id: session_id,
    user_id:    user_id
  }
  importance_level = :EXTREME
  ranking_expression = "(someFieldLong + 25) * 0.25"
  custom_ranking_info = {
    importance_level:   importance_level,
    ranking_expression: ranking_expression
  }
  order_by = "custom_ranking desc"

  # Iterate over all results.
  response = job_service.search_jobs parent:              parent,
                                     request_metadata:    request_metadata,
                                     custom_ranking_info: custom_ranking_info,
                                     order_by:            order_by
  response.matching_jobs.each do |element|
    puts "Job summary: #{element.job_summary}"
    puts "Job title snippet: #{element.job_title_snippet}"
    job = element.job
    puts "Job name: #{job.name}"
    puts "Job title: #{job.title}"
  end
  # [END job_search_custom_ranking_search]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is required)"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.parse!
  end


  sample_custom_ranking_search project_id, tenant_id
end
