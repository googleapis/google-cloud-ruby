# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Service do
  Service = Google::Cloud::Bigquery::Service
  let(:project_id) { "my-project" }
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:project_id_default) { "my-project-default" }
  let(:dataset_id_default) { "my_dataset_default" }
  let(:table_id_default) { "my_table_default" }
  let(:project_default_ref) { Google::Apis::BigqueryV2::ProjectReference.new project_id: project_id_default }
  let(:dataset_default_ref) { Google::Apis::BigqueryV2::DatasetReference.new project_id: project_id_default, dataset_id: dataset_id_default }
  let(:table_default_ref) { Google::Apis::BigqueryV2::TableReference.new project_id: project_id_default, dataset_id: dataset_id_default, table_id: table_id_default }

  it "returns table ref from standard sql format with project, dataset, table and no default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}"
    table_ref.must_be_kind_of Google::Apis::BigqueryV2::TableReference
    table_ref.project_id.must_equal project_id
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from legacy sql format with project, dataset, table and no default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}:#{dataset_id}.#{table_id}"
    table_ref.project_id.must_equal project_id
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and project default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: project_default_ref
    table_ref.project_id.must_equal project_id
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and dataset default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: dataset_default_ref
    table_ref.project_id.must_equal project_id
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with project, dataset, table and table default ref" do
    table_ref = Service.table_ref_from_s "#{project_id}.#{dataset_id}.#{table_id}", default_ref: table_default_ref
    table_ref.project_id.must_equal project_id
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and project default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: project_default_ref
    table_ref.project_id.must_equal project_id_default
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and dataset default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: dataset_default_ref
    table_ref.project_id.must_equal project_id_default
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with dataset, table and table default ref" do
    table_ref = Service.table_ref_from_s "#{dataset_id}.#{table_id}", default_ref: table_default_ref
    table_ref.project_id.must_equal project_id_default
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
  end

  it "raises from standard sql format with table and project default ref" do
    err = expect do
      Service.table_ref_from_s table_id, default_ref: project_default_ref
    end.must_raise ArgumentError
    err.message.must_equal "TableReference is missing dataset_id"
  end

  it "returns table ref from standard sql format with table and dataset default ref" do
    table_ref = Service.table_ref_from_s table_id, default_ref: dataset_default_ref
    table_ref.project_id.must_equal project_id_default
    table_ref.dataset_id.must_equal dataset_id_default
    table_ref.table_id.must_equal table_id
  end

  it "returns table ref from standard sql format with table and table default ref" do
    table_ref = Service.table_ref_from_s table_id, default_ref: table_default_ref
    table_ref.project_id.must_equal project_id_default
    table_ref.dataset_id.must_equal dataset_id_default
    table_ref.table_id.must_equal table_id
  end
end
