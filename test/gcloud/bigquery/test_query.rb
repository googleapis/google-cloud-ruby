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

describe Gcloud::Bigquery::Project, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM [some_project:some_dataset.users]" }

  it "queries the data" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["query"]["query"].must_equal query
      json["configuration"]["query"]["priority"].must_be :nil?
      json["configuration"]["query"]["useQueryCache"].must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       query_job_json(query)]
    end

    job = bigquery.query query
    job.must_be_kind_of Gcloud::Bigquery::Job
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

    job = bigquery.query query, priority: :batch, cache: false
    job.must_be_kind_of Gcloud::Bigquery::Job
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
