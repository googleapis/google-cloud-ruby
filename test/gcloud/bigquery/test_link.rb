# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a link of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Table, :link, :mock_bigquery do
  let(:source_url) { "http://example.com/data.json" }
  let(:dataset) { "dataset" }
  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_hash) { random_table_hash dataset,
                                       table_id,
                                       table_name,
                                       description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "can link itself" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].wont_include "createDisposition"
      json["configuration"]["link"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can link itself as a dryrun" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].wont_include "createDisposition"
      json["configuration"]["link"].wont_include "writeDisposition"
      json["configuration"].must_include "dryRun"
      json["configuration"]["dryRun"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url, dryrun: true
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can link itself with create disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].must_include "createDisposition"
      json["configuration"]["link"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["link"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url, create: "CREATE_NEVER"
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can link itself with create disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].must_include "createDisposition"
      json["configuration"]["link"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["link"].wont_include "writeDisposition"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url, create: :never
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can link itself with write disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].wont_include "createDisposition"
      json["configuration"]["link"].must_include "writeDisposition"
      json["configuration"]["link"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url, write: "WRITE_TRUNCATE"
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can link itself with write disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["link"]["sourceUri"].must_equal [source_url]
      json["configuration"]["link"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["link"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["link"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["link"].wont_include "createDisposition"
      json["configuration"]["link"].must_include "writeDisposition"
      json["configuration"]["link"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       link_job_json(table, source_url)]
    end

    job = table.link source_url, write: :truncate
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  def link_job_json table, source_url
    hash = random_job_hash
    hash["configuration"]["link"] = {
      "sourceUri" => [source_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY"
    }
    hash.to_json
  end
end
