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

def sample_create_job_with_custom_attributes project_id,
                                             tenant_id,
                                             company_name,
                                             requisition_id,
                                             language_code,
                                             title,
                                             description
  # [START job_search_create_job_custom_attributes]
  require "google/cloud/talent"

  # Instantiate a client
  job_service = Google::Cloud::Talent.job_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is optional)"
  parent = job_service.tenant_path project: project_id, tenant: tenant_id

  # title = "Software Engineer"
  # description = "This is a description of this <i>wonderful</i> job!"
  # company_name = "Company name, e.g. projects/your-project/companies/company-id"
  # requisition_id = "Job requisition ID, aka Posting ID. Unique per job."
  # language_code = "en-US"
  job = {
    title:          title,
    description:    description,
    company:        company_name,
    requisition_id: requisition_id,
    language_code:  language_code
  }

  response = job_service.create_job parent: parent, job: job
  puts "Created job: #{response.name}"
  # [END job_search_create_job_custom_attributes]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is optional)"
  company_name = "Company name, e.g. projects/your-project/companies/company-id"
  requisition_id = "Job requisition ID, aka Posting ID. Unique per job."
  language_code = "en-US"
  title = "The job title"
  description = "The job description"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--company_name=val") { |val| company_name = val }
    opts.on("--requisition_id=val") { |val| requisition_id = val }
    opts.on("--language_code=val") { |val| language_code = val }
    opts.on("--title=val") { |val| title = val }
    opts.on("--description=val") { |val| description = val }
    opts.parse!
  end


  sample_create_job_with_custom_attributes project_id, tenant_id, company_name,
                                           requisition_id, language_code, title,
                                           description
end
