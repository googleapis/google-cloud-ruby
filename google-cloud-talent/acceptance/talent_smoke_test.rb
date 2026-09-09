# Copyright 2021 Google LLC
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

require_relative "helper"
require "securerandom"

describe "smoke test" do
  it "creates tenants" do
    tenant_service = Google::Cloud::Talent.tenant_service
    project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    external_id = "test_tenant_#{SecureRandom.hex}"
    tenant = {
      external_id: external_id
    }
    project_path = tenant_service.project_path project: project_id
    created_tenant = tenant_service.create_tenant parent: project_path, tenant: tenant
    assert_equal external_id, created_tenant.external_id
    got_tenant = tenant_service.get_tenant name: created_tenant.name
    assert_equal created_tenant.name, got_tenant.name
    assert_equal external_id, got_tenant.external_id
    tenant_service.delete_tenant name: got_tenant.name
  end
end
