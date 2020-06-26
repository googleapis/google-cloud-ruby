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

require "google/cloud/talent"
require "minitest/autorun"
require "securerandom"

require_relative "../autocomplete_job_title"
require_relative "../batch_create_jobs"
require_relative "../batch_delete_job"
require_relative "../batch_update_jobs"
require_relative "../commute_search"
require_relative "../create_client_event"
require_relative "../create_company"
require_relative "../create_job"
require_relative "../create_job_custom_attributes"
require_relative "../create_tenant"
require_relative "../custom_ranking_search"
require_relative "../delete_company"
require_relative "../delete_job"
require_relative "../delete_tenant"
require_relative "../get_company"
require_relative "../get_job"
require_relative "../get_tenant"
require_relative "../histogram_search"
require_relative "../list_companies"
require_relative "../list_jobs"
require_relative "../list_tenants"

def tenant_service
  Google::Cloud::Talent.tenant_service
end

def job_service
  Google::Cloud::Talent.job_service
end

def company_service
  Google::Cloud::Talent.company_service
end

def create_tenant_helper tenant_name, external_id
  tenant_path = tenant_service.tenant_path project: project_id, tenant: tenant_name
  tenant = {
    name:        tenant_path,
    external_id: external_id
  }

  tenant_service.create_tenant parent: project_path, tenant: tenant
end

def get_tenant_helper tenant_name
  timed_retry do
    found_tenant = tenant_service.get_tenant name: tenant_name
    raise Google::Cloud::NotFoundError unless found_tenant
    return found_tenant
  end
end

def list_tenants_helper
  timed_retry do
    project_path = tenant_service.project_path project: project_id
    tenants = tenant_service.list_tenants parent: project_path
    return tenants.response.tenants
  end
end

def delete_tenant_helper tenant
  timed_retry do
    return tenant_service.delete_tenant name: tenant.name
  end
end

def delete_all_tenants_helper
  list_tenants_helper.each { |tenant| delete_tenant_helper tenant }
end

def create_job_helper tenant_name, company_name, job_name, requisition_id
  job = {
    title:             job_name,
    company:           company_name,
    description:       "doin stuff for money",
    requisition_id:    requisition_id,
    addresses:         ["1600 Ampitheatre Parkway"],
    application_info:  {
      emails: ["get-a-job@example.com"]
    },
    compensation_info: {
      entries: [
        {
          type:   :BASE,
          amount: {
            currency_code: "USD",
            units:         16
          }
        }
      ]
    }
  }
  tenant_path = tenant_service.tenant_path project: project_id, tenant: tenant_name
  job_service.create_job parent: tenant_path, job: job
end

def get_job_helper job_name
  timed_retry do
    job = job_service.get_job name: job_name
    raise Google::Cloud::NotFoundError unless job
    return job
  end
end

def create_company_helper tenant_name, company_name, external_id
  company = {
    display_name: company_name,
    external_id:  external_id
  }
  tenant_path = tenant_service.tenant_path project: project_id, tenant: tenant_name
  company_service.create_company parent: tenant_path, company: company
end

def get_company_helper company_name
  timed_retry do
    found_company = company_service.get_company name: company_name
    raise Google::Cloud::NotFoundError unless found_company
    return found_company
  end
end

def timed_retry
  5.times do
    begin
      return yield
    rescue StandardError => e
      puts "\n#{e} Gonna try again"
      sleep 5
    end
  end
  raise Google::Cloud::NotFoundError
end

def project_id
  ENV["GOOGLE_CLOUD_PROJECT"]
end

def project_path
  tenant_service.project_path project: project_id
end
