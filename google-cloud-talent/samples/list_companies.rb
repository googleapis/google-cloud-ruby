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

def sample_list_companies project_id, tenant_id
  # [START job_search_list_companies]
  require "google/cloud/talent"

  # Instantiate a client
  company_service = Google::Cloud::Talent.company_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  formatted_parent = company_service.tenant_path project: project_id, tenant: tenant_id

  # Iterate over all results.
  response = company_service.list_companies parent: formatted_parent
  response.each do |element|
    puts "Company Name: #{element.name}"
    puts "Display Name: #{element.display_name}"
    puts "External ID: #{element.external_id}"
  end
  response
  # [END job_search_list_companies]
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


  sample_list_companies project_id, tenant_id
end
