# Copyright 2022 Google LLC
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

describe Google::Cloud::Bigquery::Table, :copy, :mock_bigquery do
  let(:source_dataset) { "source_dataset" }
  let(:source_table_id) { "source_table_id" }
  let(:source_table_name) { "Source Table" }
  let(:source_description) { "This is the source table" }
  let(:source_table_gapi) { random_table_gapi source_dataset,
                                              source_table_id,
                                              source_table_name,
                                              source_description }
  let(:source_table) { Google::Cloud::Bigquery::Table.from_gapi source_table_gapi,
                                                         bigquery.service }
  let(:target_dataset) { "target_dataset" }
  let(:target_table_id) { "target_table_id" }
  let(:target_table_name) { "Target Table" }
  let(:target_description) { "This is the target table" }
  let(:target_table_gapi) { random_table_gapi target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description }
  let(:target_table) { Google::Cloud::Bigquery::Table.from_gapi target_table_gapi,
                                                         bigquery.service }
  let(:target_table_other_proj_gapi) { random_table_gapi target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description,
                                              "target-project" }
  let(:target_table_other_proj) { Google::Cloud::Bigquery::Table.from_gapi target_table_other_proj_gapi,
                                                         bigquery.service }

  it "can snapshot itself" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    result = source_table.snapshot target_table
    mock.verify

    _(result).must_equal true
  end

  it "can snapshot to a table identified by a string" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table_other_proj)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"
    mock.expect :insert_job, job_resp_gapi, ["test-project", job_gapi]

    result = source_table.snapshot "target-project:target_dataset.target_table_id"
    mock.verify

    _(result).must_equal true
  end

  it "can snapshot to a table name string only" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    new_target_table = Google::Cloud::Bigquery::Table.from_gapi(
      random_table_gapi(source_dataset,
                        "new_target_table_id",
                        target_table_name,
                        target_description),
      bigquery.service
    )

    job_gapi = copy_job_gapi(source_table, new_target_table)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    result = source_table.snapshot "new_target_table_id"
    mock.verify

    _(result).must_equal true
  end

  def copy_job_gapi source, target, job_id: "job_9876543210", location: "US"
    Google::Apis::BigqueryV2::Job.from_json copy_job_json(source, target, job_id, location: location)
  end

  def copy_job_json source, target, job_id, location: "US"
    {
      "jobReference" => {
        "projectId" => project,
        "jobId" => job_id,
        "location" => location
      },
      "configuration" => {
        "copy" => {
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
          "createDisposition" => nil,
          "writeDisposition" => nil,
          "operationType" => "SNAPSHOT"
        },
        "dryRun" => nil
      }
    }.to_json
  end
end
