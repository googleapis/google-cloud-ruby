# Copyright 2015 Google LLC
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
require "json"
require "uri"

describe Google::Cloud::Bigquery::QueryJob, :mock_bigquery do
  let(:job_gapi) { query_job_gapi target_table: true, statement_type: "CREATE_TABLE", num_dml_affected_rows: 50, ddl_operation_performed: "CREATE" }
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi job_gapi,
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
    job.wont_be :legacy_sql?
    job.must_be :standard_sql?
    job.maximum_billing_tier.must_equal 2
    job.maximum_bytes_billed.must_equal 12345678901234
  end

  it "knows its statistics data" do
    job.bytes_processed.must_equal 123456
    job.cache_hit?.must_equal true
    job.ddl_operation_performed.must_equal "CREATE"
    job.ddl_target_table.must_be_kind_of Google::Cloud::Bigquery::Table
    job.ddl_target_table.project_id.must_equal "target_project_id"
    job.ddl_target_table.dataset_id.must_equal "target_dataset_id"
    job.ddl_target_table.table_id.must_equal "target_table_id"
    job.num_dml_affected_rows.must_equal 50
    job.statement_type.must_equal "CREATE_TABLE"
    job.ddl?.must_equal true
    job.dml?.must_equal false
  end

  it "knows its query config" do
    job.config.must_be_kind_of Hash
    job.config["query"]["destinationTable"]["tableId"].must_equal "target_table_id"
    job.config["query"]["createDisposition"].must_equal "CREATE_IF_NEEDED"
    job.config["query"]["priority"].must_equal "BATCH"
  end

  it "knows its query plan attributes" do
    job.query_plan.wont_be_nil
    job.query_plan.must_be_kind_of Array
    job.query_plan.count.must_equal 1
    stage = job.query_plan.first
    stage.must_be_kind_of Google::Cloud::Bigquery::QueryJob::Stage
    stage.compute_ratio_avg.must_equal 1.0
    stage.compute_ratio_max.must_equal 1.0
    stage.id.must_equal 1
    stage.name.must_equal "Stage 1"
    stage.read_ratio_avg.must_equal 0.2710832227382326
    stage.read_ratio_max.must_equal 0.2710832227382326
    stage.records_read.must_equal 164656
    stage.records_written.must_equal 1
    stage.status.must_equal "COMPLETE"
    stage.wait_ratio_avg.must_equal 0.007876711656047392
    stage.wait_ratio_max.must_equal 0.007876711656047392
    stage.write_ratio_avg.must_equal 0.05389444608201358
    stage.write_ratio_max.must_equal 0.05389444608201358

    stage.steps.wont_be_nil
    stage.steps.must_be_kind_of Array
    stage.steps.count.must_equal 1
    step = stage.steps.first
    step.must_be_kind_of Google::Cloud::Bigquery::QueryJob::Step
    step.kind.must_equal "READ"
    step.substeps.wont_be_nil
    step.substeps.must_be_kind_of Array
    step.substeps.must_equal [ "word", "FROM bigquery-public-data:samples.shakespeare" ]
  end

  it "knows its user defined function resources" do
    job.udfs.wont_be_nil
    job.udfs.must_be_kind_of Array
    job.udfs.count.must_equal 2
    job.udfs.first.must_equal "return x+1;"
    job.udfs.last.must_equal "gs://my-bucket/my-lib.js"
  end

  def query_job_gapi target_table: false, statement_type: nil, num_dml_affected_rows: nil, ddl_operation_performed: nil
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
    gapi.statistics.query = statistics_query_gapi target_table: target_table,
                                                  statement_type: statement_type,
                                                  num_dml_affected_rows: num_dml_affected_rows,
                                                  ddl_operation_performed: ddl_operation_performed
    gapi
  end

  def query_job_hash
    hash = random_job_hash
    hash["configuration"]["query"] = {
      "query" => "SELECT name, age, score, active FROM `users`",
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
      "useLegacySql" => false,
      "maximumBillingTier" => 2,
      "maximumBytesBilled" => 12345678901234, # Long
      "userDefinedFunctionResources" => [
        { "inlineCode" => "return x+1;" },
        { "resourceUri" => "gs://my-bucket/my-lib.js" }
      ]
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
