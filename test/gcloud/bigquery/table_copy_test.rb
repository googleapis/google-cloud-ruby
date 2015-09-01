# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"

describe Gcloud::Bigquery::Table, :copy, :mock_bigquery do
  let(:source_dataset) { "source_dataset" }
  let(:source_table_id) { "source_table_id" }
  let(:source_table_name) { "Source Table" }
  let(:source_description) { "This is the source table" }
  let(:source_table_hash) { random_table_hash source_dataset,
                                              source_table_id,
                                              source_table_name,
                                              source_description }
  let(:source_table) { Gcloud::Bigquery::Table.from_gapi source_table_hash,
                                                         bigquery.connection }
  let(:target_dataset) { "target_dataset" }
  let(:target_table_id) { "target_table_id" }
  let(:target_table_name) { "Target Table" }
  let(:target_description) { "This is the target table" }
  let(:target_table_hash) { random_table_hash target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description }
  let(:target_table) { Gcloud::Bigquery::Table.from_gapi target_table_hash,
                                                         bigquery.connection }
  let(:target_table_other_proj_hash) { random_table_hash target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description,
                                              "target-project" }
  let(:target_table_other_proj) { Gcloud::Bigquery::Table.from_gapi target_table_other_proj_hash,
                                                         bigquery.connection }

  it "can copy itself" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].wont_include "createDisposition"
      json["configuration"]["copy"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "can copy to a table identified by a string" do
      mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
        json = JSON.parse(env.body)
        json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
        json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
        json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
        json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table_other_proj.project_id
        json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table_other_proj.dataset_id
        json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table_other_proj.table_id
        [200, {"Content-Type"=>"application/json"},
         copy_job_json(source_table, target_table_other_proj)]
      end

      job = source_table.copy "target-project:target_dataset.target_table_id"
    end

  it "can copy itself as a dryrun" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].wont_include "createDisposition"
      json["configuration"]["copy"].wont_include "writeDisposition"
      json["configuration"].must_include "dryRun"
      json["configuration"]["dryRun"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table, dryrun: true
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "can copy itself with create disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].must_include "createDisposition"
      json["configuration"]["copy"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["copy"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table, create: "CREATE_NEVER"
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "can copy itself with create disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].must_include "createDisposition"
      json["configuration"]["copy"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["copy"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table, create: :never
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "can copy itself with write disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].wont_include "createDisposition"
      json["configuration"]["copy"].must_include "writeDisposition"
      json["configuration"]["copy"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table, write: "WRITE_TRUNCATE"
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "can copy itself with write disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["copy"]["sourceTable"]["projectId"].must_equal source_table.project_id
      json["configuration"]["copy"]["sourceTable"]["datasetId"].must_equal source_table.dataset_id
      json["configuration"]["copy"]["sourceTable"]["tableId"].must_equal source_table.table_id
      json["configuration"]["copy"]["destinationTable"]["projectId"].must_equal target_table.project_id
      json["configuration"]["copy"]["destinationTable"]["datasetId"].must_equal target_table.dataset_id
      json["configuration"]["copy"]["destinationTable"]["tableId"].must_equal target_table.table_id
      json["configuration"]["copy"].wont_include "createDisposition"
      json["configuration"]["copy"].must_include "writeDisposition"
      json["configuration"]["copy"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       copy_job_json(source_table, target_table)]
    end

    job = source_table.copy target_table, write: :truncate
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  def copy_job_json source, target
    hash = random_job_hash
    hash["configuration"]["copy"] = {
      "sourceTable" => {
        "projectId" => source.project_id,
        "datasetId" => source.dataset_id,
        "tableId" => source.table_id
      },
      "destinationTable" => {
        "projectId" => target.project_id,
        "datasetId" => target.dataset_id,
        "tableId" => target.table_id
      },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY"
    }
    hash.to_json
  end
end
