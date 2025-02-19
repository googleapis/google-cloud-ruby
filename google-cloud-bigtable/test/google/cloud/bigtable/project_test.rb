# Copyright 2018 Google LLC
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


require "helper"

describe Google::Cloud::Bigtable::Project, :mock_bigtable do
  it "knows the project identifier" do
    _(bigtable).must_be_kind_of Google::Cloud::Bigtable::Project
    _(bigtable.project_id).must_equal project_id
  end

  it "returns the default universe domain" do
    _(bigtable.universe_domain).must_equal "googleapis.com"
    tables_stub = bigtable.service.tables.instance_variable_get :@bigtable_table_admin_stub
    _(tables_stub.endpoint).must_equal "bigtableadmin.googleapis.com"
    instances_stub = bigtable.service.instances.instance_variable_get :@bigtable_instance_admin_stub
    _(instances_stub.endpoint).must_equal "bigtableadmin.googleapis.com"
    main_stub = bigtable.service.client("mytable", "myprofile").instance_variable_get :@bigtable_stub
    _(main_stub.endpoint).must_equal "bigtable.googleapis.com"
  end

  it "returns a custom universe domain" do
    universe = "myuniverse.com"
    service = Google::Cloud::Bigtable::Service.new project_id, credentials, universe_domain: universe
    project = Google::Cloud::Bigtable::Project.new service
    _(project.universe_domain).must_equal universe
    tables_stub = service.tables.instance_variable_get :@bigtable_table_admin_stub
    _(tables_stub.endpoint).must_equal "bigtableadmin.myuniverse.com"
    instances_stub = service.instances.instance_variable_get :@bigtable_instance_admin_stub
    _(instances_stub.endpoint).must_equal "bigtableadmin.myuniverse.com"
    main_stub = service.client("mytable", "myprofile").instance_variable_get :@bigtable_stub
    _(main_stub.endpoint).must_equal "bigtable.myuniverse.com"
  end
end
