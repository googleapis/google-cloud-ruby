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
    job.wont_be :legacy_sql?
    job.must_be :standard_sql?
    job.maximum_billing_tier.must_equal 2
    job.maximum_bytes_billed.must_equal 12345678901234
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
    step.substeps.must_equal [ "word", "FROM publicdata:samples.shakespeare" ]
  end

  def query_job_gapi
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
    gapi.statistics.query = statistics_query_gapi
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
      "maximumBytesBilled" => 12345678901234 # Long
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

  def statistics_query_gapi
    Google::Apis::BigqueryV2::JobStatistics2.new(
      billing_tier: 1,
      cache_hit: false,
      total_bytes_processed: 123456,
      query_plan: [
        Google::Apis::BigqueryV2::ExplainQueryStage.new(
          compute_ratio_avg: 1.0,
          compute_ratio_max: 1.0,
          id: 1,
          name: "Stage 1",
          read_ratio_avg: 0.2710832227382326,
          read_ratio_max: 0.2710832227382326,
          records_read: 164656,
          records_written: 1,
          status: "COMPLETE",
          steps: [
            Google::Apis::BigqueryV2::ExplainQueryStep.new(
              kind: "READ",
              substeps: [
                "word",
                "FROM publicdata:samples.shakespeare"
              ]
            )
          ],
          wait_ratio_avg: 0.007876711656047392,
          wait_ratio_max: 0.007876711656047392,
          write_ratio_avg: 0.05389444608201358,
          write_ratio_max: 0.05389444608201358
        )
      ]
    )
  end
end
