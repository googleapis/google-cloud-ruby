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
  let(:job_gapi) { query_job_gapi target_routine: true, target_table: true, statement_type: "CREATE_TABLE", num_dml_affected_rows: 50, ddl_operation_performed: "CREATE" }
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is query job" do
    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "knows its destination table" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, destination_table_gapi, ["target_project_id", "target_dataset_id", "target_table_id"]

    destination = job.destination
    _(destination).must_be_kind_of Google::Cloud::Bigquery::Table
    _(destination.project_id).must_equal "target_project_id"
    _(destination.dataset_id).must_equal "target_dataset_id"
    _(destination.table_id).must_equal   "target_table_id"
    mock.verify
  end

  it "knows its attributes" do
    _(job).must_be :batch?
    _(job).wont_be :interactive?
    _(job).must_be :large_results?
    _(job).must_be :cache?
    _(job).must_be :flatten?
    _(job).wont_be :legacy_sql?
    _(job).must_be :standard_sql?
    _(job.maximum_billing_tier).must_equal 2
    _(job.maximum_bytes_billed).must_equal 12345678901234
  end

  it "knows its statistics data" do
    _(job.bytes_processed).must_equal 123456
    _(job.cache_hit?).must_equal true
    _(job.ddl_operation_performed).must_equal "CREATE"
    _(job.ddl_target_table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(job.ddl_target_table.project_id).must_equal "target_project_id"
    _(job.ddl_target_table.dataset_id).must_equal "target_dataset_id"
    _(job.ddl_target_table.table_id).must_equal "target_table_id"
    _(job.num_dml_affected_rows).must_equal 50
    _(job.statement_type).must_equal "CREATE_TABLE"
    _(job.ddl?).must_equal true
    _(job.dml?).must_equal false
    # in real life this example does not create a routine, but test the attribute here anyway
    _(job.ddl_target_routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(job.ddl_target_routine.project_id).must_equal "target_project_id"
    _(job.ddl_target_routine.dataset_id).must_equal "target_dataset_id"
    _(job.ddl_target_routine.routine_id).must_equal "target_routine_id"
  end

  it "knows its query config" do
    _(job.config).must_be_kind_of Hash
    _(job.config["query"]["destinationTable"]["tableId"]).must_equal "target_table_id"
    _(job.config["query"]["createDisposition"]).must_equal "CREATE_IF_NEEDED"
    _(job.config["query"]["priority"]).must_equal "BATCH"
  end

  it "knows its query plan attributes" do
    _(job.query_plan).wont_be_nil
    _(job.query_plan).must_be_kind_of Array
    _(job.query_plan.count).must_equal 1
    stage = job.query_plan.first
    _(stage).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Stage
    _(stage.compute_ratio_avg).must_equal 1.0
    _(stage.compute_ratio_max).must_equal 1.0
    _(stage.id).must_equal 1
    _(stage.name).must_equal "Stage 1"
    _(stage.read_ratio_avg).must_equal 0.2710832227382326
    _(stage.read_ratio_max).must_equal 0.2710832227382326
    _(stage.records_read).must_equal 164656
    _(stage.records_written).must_equal 1
    _(stage.status).must_equal "COMPLETE"
    _(stage.wait_ratio_avg).must_equal 0.007876711656047392
    _(stage.wait_ratio_max).must_equal 0.007876711656047392
    _(stage.write_ratio_avg).must_equal 0.05389444608201358
    _(stage.write_ratio_max).must_equal 0.05389444608201358

    _(stage.steps).wont_be_nil
    _(stage.steps).must_be_kind_of Array
    _(stage.steps.count).must_equal 1
    step = stage.steps.first
    _(step).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Step
    _(step.kind).must_equal "READ"
    _(step.substeps).wont_be_nil
    _(step.substeps).must_be_kind_of Array
    _(step.substeps).must_equal [ "word", "FROM bigquery-public-data:samples.shakespeare" ]
  end

  it "knows its user defined function resources" do
    _(job.udfs).wont_be_nil
    _(job.udfs).must_be_kind_of Array
    _(job.udfs.count).must_equal 2
    _(job.udfs.first).must_equal "return x+1;"
    _(job.udfs.last).must_equal "gs://my-bucket/my-lib.js"
  end

  def query_job_gapi target_routine: false, target_table: false, statement_type: nil, num_dml_affected_rows: nil, ddl_operation_performed: nil
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
    gapi.statistics.query = statistics_query_gapi target_routine: target_routine,
                                                  target_table: target_table,
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
