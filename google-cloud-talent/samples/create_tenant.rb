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

def sample_create_tenant project_id, external_id
  # [START job_search_create_tenant]
  require "google/cloud/talent"

  # Instantiate a client
  tenant_service = Google::Cloud::Talent.tenant_service

  # project_id = "Your Google Cloud Project ID"
  # external_id = "Your Unique Identifier for Tenant"
  parent = tenant_service.project_path project: project_id
  tenant = { external_id: external_id }

  response = tenant_service.create_tenant parent: parent, tenant: tenant
  puts "Created Tenant"
  puts "Name: #{response.name}"
  puts "External ID: #{response.external_id}"
  # [END job_search_create_tenant]
end

require "optparse"

if $PROGRAM_NAME == __FILE__

  project_id = "Your Google Cloud Project ID"
  external_id = "Your Unique Identifier for Tenant"

  ARGV.options do |opts|
    opts.on("--project_id=val") { |val| project_id = val }
    opts.on("--external_id=val") { |val| external_id = val }
    opts.parse!
  end

  sample_create_tenant project_id, external_id
end
