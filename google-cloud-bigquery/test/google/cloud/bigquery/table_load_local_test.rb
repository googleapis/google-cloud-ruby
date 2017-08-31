# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a load of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Table, :load, :local, :mock_bigquery do
  let(:dataset) { "dataset" }
  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:labels) { { "foo" => "bar" } }

  it "can upload a csv file" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.csv"),
        [project, load_job_gapi(table_gapi.table_reference, "CSV"), upload_source: file, content_type: "text/comma-separated-values"]

      job = table.load file, format: :csv
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify
  end

  it "can upload a csv file with CSV options" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.csv"),
        [project, load_job_csv_options_gapi(table_gapi.table_reference), upload_source: file, content_type: "text/comma-separated-values"]

      job = table.load file, format: :csv, jagged_rows: true, quoted_newlines: true, autodetect: true,
        encoding: "ISO-8859-1", delimiter: "\t", ignore_unknown: true, max_bad_records: 42, null_marker: "\N",
        quote: "'", skip_leading: 1
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify

    temp_csv do |file|

    end
  end

  it "can upload a json file" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json"),
        [project, load_job_gapi(table_gapi.table_reference), upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON"
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify
  end

  it "can upload a json file and derive the format" do
    mock = Minitest::Mock.new
    mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json"),
      [project, load_job_gapi(table_gapi.table_reference), upload_source: "acceptance/data/kitten-test-data.json", content_type: "application/json"]
    table.service.mocked_service = mock

    local_json = "acceptance/data/kitten-test-data.json"
    job = table.load local_json
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can upload a json file with job_id option" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = load_job_gapi table_gapi.table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON", job_id: job_id
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.job_id.must_equal job_id
    end

    mock.verify
  end

  it "can upload a json file with prefix option" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    table.service.mocked_service = mock
    job_gapi = load_job_gapi table_gapi.table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON", prefix: prefix
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.job_id.must_equal job_id
    end

    mock.verify
  end

  it "can upload a json file with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = load_job_gapi table_gapi.table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON", job_id: job_id, prefix: "IGNORED"
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.job_id.must_equal job_id
    end

    mock.verify
  end

  it "can upload a json file with the job labels option" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock
    job_gapi = load_job_gapi(table_gapi.table_reference)
    job_gapi.configuration.labels = labels

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json", labels: labels),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON", labels: labels
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.labels.must_equal labels
    end

    mock.verify
  end

  def load_job_resp_gapi table, load_url, job_id: "job_9876543210", labels: nil
    hash = random_job_hash job_id
    hash["configuration"]["load"] = {
      "sourceUris" => [load_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
    }
    resp = Google::Apis::BigqueryV2::Job.from_json hash.to_json
    resp.configuration.labels = labels if labels
    resp
  end
end
