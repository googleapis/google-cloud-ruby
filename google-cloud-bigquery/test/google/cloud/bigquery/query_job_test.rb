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
require "json"
require "uri"

describe Google::Cloud::Bigquery::QueryJob, :mock_bigquery do
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi query_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is query job" do
    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "knows its destination table" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, destination_table_gapi, ["target_project_id", "target_dataset_id", "target_table_id"]

    destination = job.destination
    destination.must_be_kind_of Google::Cloud::Bigquery::Table
    destination.project_id.must_equal "target_project_id"
    destination.dataset_id.must_equal "target_dataset_id"
    destination.table_id.must_equal   "target_table_id"
    mock.verify
  end

  it "knows its attributes" do
    job.must_be :batch?
    job.wont_be :interactive?
    job.must_be :large_results?
    job.must_be :cache?
    job.must_be :flatten?
    job.must_be :legacy_sql?
    job.wont_be :standard_sql?
  end

  it "knows its statistics data" do
    job.wont_be :cache_hit?
    job.bytes_processed.must_equal 123456
  end

  it "knows its query config" do
    job.config.must_be_kind_of Hash
    job.config["query"]["destinationTable"]["tableId"].must_equal "target_table_id"
    job.config["query"]["createDisposition"].must_equal "CREATE_IF_NEEDED"
    job.config["query"]["priority"].must_equal "BATCH"
  end

  def query_job_gapi
    Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
  end

  def query_job_hash
    hash = random_job_hash
    hash["configuration"]["query"] = {
      "query" => "SELECT name, age, score, active FROM [users]",
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "tableDefinitions" => {},
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY",
      "defaultDataset" => {
        "datasetId" => "my_dataset",
        "projectId" => project
      },
      "priority" => "BATCH",
      "allowLargeResults" => true,
      "useQueryCache" => true,
      "flattenResults" => true,
      "useLegacySql" => nil
    }
    hash["statistics"]["query"] = {
      "cacheHit" => false,
      "totalBytesProcessed" => 123456
    }
    hash
  end

  def destination_table_json
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    hash.to_json
  end
end
