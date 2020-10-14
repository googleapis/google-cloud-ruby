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

def sample_batch_delete_jobs project_id, tenant_id, job_name_one, job_name_two
  # [START job_search_batch_delete_jobs]
  require "google/cloud/talent"

  # Instantiate a client
  job_service = Google::Cloud::Talent.job_service

  # project_id = "Your Google Cloud Project ID"
  # tenant_id = "Your Tenant ID (using tenancy is required)"
  formatted_parent = job_service.tenant_path project: project_id, tenant: tenant_id

  # the name of jobs to be deleted.
  names = [job_name_one, job_name_two]

  # Make the long-running operation request
  operation = job_service.batch_delete_jobs parent: formatted_parent, names: names

  # Block until operation complete
  operation.wait_until_done!

  raise operation.results.message if operation.error?

  response = operation.response

  puts "Batch response: #{response.inspect}"
  # [END job_search_batch_delete_jobs]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  tenant_id = "Your Tenant ID (using tenancy is required)"
  job_name_one = "Job name 1, e.g. projects/your-project/tenant/tenant-id/jobs/job-id-1"
  job_name_two = "Job name 2, e.g. projects/your-project/tenant/tenant-id/jobs/job-id-2"
  s
  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--tenant_id=val") { |val| tenant_id = val }
    opts.on("--job_name_one=val") { |val| job_name_one = val }
    opts.on("--job_name_two=val") { |val| job_name_two = val }
    opts.parse!
  end

  sample_batch_delete_jobs project_id, tenant_id, job_name_one, job_name_two
end
