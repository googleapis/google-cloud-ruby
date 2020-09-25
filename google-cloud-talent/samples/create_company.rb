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

def sample_create_company project_id, tenant_id, display_name, external_id
  # [START job_search_create_company]
  require "google/cloud/talent"

  # Instantiate a client
  company_service = Google::Cloud::Talent.company_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  parent = company_service.tenant_path project: project_id, tenant: tenant_id

  # display_name = "My Company Name"
  # external_id = "Identifier of this company in my system"
  company = { display_name: display_name, external_id: external_id }

  response = company_service.create_company parent: parent, company: company
  puts "Created Company"
  puts "Name: #{response.name}"
  puts "Display Name: #{response.display_name}"
  puts "External ID: #{response.external_id}"
  # [END job_search_create_company]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is required)"
  display_name = "My Company Name"
  external_id = "Identifier of this company in my system"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--display_name=val") { |val| display_name = val }
    opts.on("--external_id=val") { |val| external_id = val }
    opts.parse!
  end


  sample_create_company project_id, tenant_id, display_name, external_id
end
