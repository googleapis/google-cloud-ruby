# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Project, :query_job, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM [some_project:some_dataset.users]" }
  let(:udfs) { ["var someCode = 'here';", "gs://some-bucket/js/lib.js"] }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "queries the data" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["priority"].must_equal "INTERACTIVE"
      json["configuration"]["query"]["useQueryCache"].must_equal true
      json["configuration"]["query"]["destinationTable"].must_be :nil?
      json["configuration"]["query"]["createDisposition"].must_be :nil?
      json["configuration"]["query"]["writeDisposition"].must_be :nil?
      json["configuration"]["query"]["allowLargeResults"].must_be :nil?
      json["configuration"]["query"]["flattenResults"].must_be :nil?
      json["configuration"]["query"]["defaultDataset"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job query
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with options set" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["priority"].must_equal "BATCH"
      json["configuration"]["query"]["useQueryCache"].must_equal false
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job query, priority: :batch, cache: false
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with table options" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["destinationTable"].wont_be :nil?
      json["configuration"]["query"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["query"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["query"]["destinationTable"]["tableId"].must_equal   table.table_id
      json["configuration"]["query"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["query"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"]["query"]["allowLargeResults"].must_equal true
      json["configuration"]["query"]["flattenResults"].must_equal false
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job query, table: table,
                                create: :never, write: :truncate,
                                large_results: true, flatten: false
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with dataset option as a Dataset" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["defaultDataset"].wont_be :nil?
      json["configuration"]["query"]["defaultDataset"]["projectId"].must_equal dataset.project_id
      json["configuration"]["query"]["defaultDataset"]["datasetId"].must_equal dataset.dataset_id
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job query, dataset: dataset
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with dataset option as a String" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["defaultDataset"].wont_be :nil?
      json["configuration"]["query"]["defaultDataset"]["projectId"].must_be :nil?
      json["configuration"]["query"]["defaultDataset"]["datasetId"].must_equal dataset_id
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job query, dataset: dataset_id
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with udf option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["userDefinedFunctionResources"].must_equal [{"inlineCode" => udfs[0]}, {"resourceUri" => udfs[1]}]
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query_job(query, {udfs: udfs})
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  def query_job_json query
    hash = random_job_hash
    hash["configuration"]["query"] = {
      "query" => query,
      # "defaultDataset" => {
      #   "datasetId" => string,
      #   "projectId" => string
      # },
      # "destinationTable" => {
      #   "projectId" => string,
      #   "datasetId" => string,
      #   "tableId" => string
      # },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY",
      "priority" => "INTERACTIVE",
      "allowLargeResults" => true,
      "useQueryCache" => true,
      "flattenResults" => true
    }
    hash.to_json
  end
end
