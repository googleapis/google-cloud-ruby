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

def sample_batch_create_jobs project_id, tenant_id, company_name_one,
                             requisition_id_one, title_one, description_one,
                             job_application_url_one, address_one, language_code_one,
                             company_name_two, requisition_id_two, title_two,
                             description_two, job_application_url_two, address_two,
                             language_code_two
  # [START job_search_batch_create_jobs]
  require "google/cloud/talent"

  # Instantiate a client
  job_service = Google::Cloud::Talent.job_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  formatted_parent = job_service.tenant_path project: project_id, tenant: tenant_id

  # job_application_url_one = "https://www.example.org/job-posting/123"
  uris = [job_application_url_one]
  application_info = { uris: uris }

  # address_one = "1600 Amphitheatre Parkway, Mountain View, CA 94043"
  addresses = [address_one]

  # company_name_one = "Company name, e.g. projects/your-project/companies/company-id"
  # requisition_id_one = "Job requisition ID, aka Posting ID. Unique per job."
  # title_one = "Software Engineer"
  # description_one = "This is a description of this <i>wonderful</i> job!"
  # language_code_one = "en-US"
  jobs_element = {
    company:          company_name_one,
    requisition_id:   requisition_id_one,
    title:            title_one,
    description:      description_one,
    application_info: application_info,
    addresses:        addresses,
    language_code:    language_code_one
  }


  # job_application_url_two = "https://www.example.org/job-posting/123"
  uris_2 = [job_application_url_two]
  application_info_2 = { uris: uris_2 }

  # address_two = "111 8th Avenue, New York, NY 10011"
  addresses_2 = [address_two]

  # company_name_two = "Company name, e.g. projects/your-project/companies/company-id"
  # requisition_id_two = "Job requisition ID, aka Posting ID. Unique per job."
  # title_two = "Quality Assurance"
  # description_two = "This is a description of this <i>wonderful</i> job!"
  # language_code_two = "en-US"
  jobs_element_2 = {
    company:          company_name_two,
    requisition_id:   requisition_id_two,
    title:            title_two,
    description:      description_two,
    application_info: application_info_2,
    addresses:        addresses_2,
    language_code:    language_code_two
  }
  jobs = [jobs_element, jobs_element_2]

  # Make the long-running operation request
  operation = job_service.batch_create_jobs parent: formatted_parent, jobs: jobs

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  puts "Batch response: #{response.inspect}"
  # [END job_search_batch_create_jobs]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is required)"
  company_name_one = "Company name, e.g. projects/your-project/companies/company-id"
  requisition_id_one = "Job requisition ID, aka Posting ID. Unique per job."
  title_one = "Software Engineer"
  description_one = "This is a description of this <i>wonderful</i> job!"
  job_application_url_one = "https://www.example.org/job-posting/123"
  address_one = "1600 Amphitheatre Parkway, Mountain View, CA 94043"
  language_code_one = "en-US"
  company_name_two = "Company name, e.g. projects/your-project/companies/company-id"
  requisition_id_two = "Job requisition ID, aka Posting ID. Unique per job."
  title_two = "Quality Assurance"
  description_two = "This is a description of this <i>wonderful</i> job!"
  job_application_url_two = "https://www.example.org/job-posting/123"
  address_two = "111 8th Avenue, New York, NY 10011"
  language_code_two = "en-US"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--company_name_one=val") { |val| company_name_one = val }
    opts.on("--requisition_id_one=val") { |val| requisition_id_one = val }
    opts.on("--title_one=val") { |val| title_one = val }
    opts.on("--description_one=val") { |val| description_one = val }
    opts.on("--job_application_url_one=val") { |val| job_application_url_one = val }
    opts.on("--address_one=val") { |val| address_one = val }
    opts.on("--language_code_one=val") { |val| language_code_one = val }
    opts.on("--company_name_two=val") { |val| company_name_two = val }
    opts.on("--requisition_id_two=val") { |val| requisition_id_two = val }
    opts.on("--title_two=val") { |val| title_two = val }
    opts.on("--description_two=val") { |val| description_two = val }
    opts.on("--job_application_url_two=val") { |val| job_application_url_two = val }
    opts.on("--address_two=val") { |val| address_two = val }
    opts.on("--language_code_two=val") { |val| language_code_two = val }
    opts.parse!
  end


  sample_batch_create_jobs project_id, tenant_id,
                           company_name_one, requisition_id_one,
                           title_one, description_one,
                           job_application_url_one, address_one,
                           language_code_one, company_name_two,
                           requisition_id_two, title_two,
                           description_two, job_application_url_two,
                           address_two, language_code_two
end
