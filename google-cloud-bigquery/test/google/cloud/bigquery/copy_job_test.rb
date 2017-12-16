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

describe Google::Cloud::Bigquery::CopyJob, :mock_bigquery do
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi copy_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is copy job" do
    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "knows its copy tables" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, source_table_gapi, ["source_project_id", "source_dataset_id", "source_table_id"]

    source = job.source
    source.must_be_kind_of Google::Cloud::Bigquery::Table
    source.project_id.must_equal "source_project_id"
    source.dataset_id.must_equal "source_dataset_id"
    source.table_id.must_equal   "source_table_id"

    mock.expect :get_table, destination_table_gapi, ["target_project_id", "target_dataset_id", "target_table_id"]
    destination = job.destination
    destination.must_be_kind_of Google::Cloud::Bigquery::Table
    destination.project_id.must_equal "target_project_id"
    destination.dataset_id.must_equal "target_dataset_id"
    destination.table_id.must_equal   "target_table_id"

    mock.verify
  end

  it "knows its create/write disposition flags" do
    job.must_be :create_if_needed?
    job.wont_be :create_never?
    job.wont_be :write_truncate?
    job.wont_be :write_append?
    job.must_be :write_empty?
  end

  it "knows its copy config" do
    job.config.must_be_kind_of Hash
    job.config["copy"]["sourceTable"]["projectId"].must_equal "source_project_id"
    job.config["copy"]["destinationTable"]["tableId"].must_equal "target_table_id"
    job.config["copy"]["createDisposition"].must_equal "CREATE_IF_NEEDED"
  end

  it "can re-run itself" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    rerun_job_gapi = Google::Apis::BigqueryV2::Job.new(
      job_reference: job_reference_gapi(project, "job_9876543210"),
      configuration: Google::Apis::BigqueryV2::JobConfiguration.from_json(job.configuration.to_json)
    )
    mock.expect :insert_job, copy_job_gapi(job.job_id + "-rerun"), [project, rerun_job_gapi]

    new_job = job.rerun!
    new_job.config["dryRun"].must_equal job.config["dryRun"]
    new_job.job_id.wont_equal job.job_id
    mock.verify
  end

  def copy_job_gapi id = "1234567890"
    Google::Apis::BigqueryV2::Job.from_json copy_job_hash(id).to_json
  end

  def copy_job_hash id
    hash = random_job_hash id
    hash["configuration"]["copy"] = {
      "sourceTable" => {
        "projectId" => "source_project_id",
        "datasetId" => "source_dataset_id",
        "tableId"   => "source_table_id"
      },
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY"
    }
    hash
  end
end
