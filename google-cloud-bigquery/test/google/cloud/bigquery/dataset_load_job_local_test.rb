# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a load of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Dataset, :load_job, :local, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "table_id" }
  let(:table_reference) { Google::Apis::BigqueryV2::TableReference.new(
    project_id: "test-project",
    dataset_id: "my_dataset",
    table_id: "table_id"
  ) }

  it "can upload a csv file" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.csv"),
        [project, load_job_gapi(table_reference, "CSV"), upload_source: file, content_type: "text/comma-separated-values"]

      job = dataset.load_job table_id, file, format: :csv
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end
    mock.verify
  end

  it "can upload a csv file with CSV options" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.csv"),
        [project, load_job_csv_options_gapi(table_reference), upload_source: file, content_type: "text/comma-separated-values"]

      job = dataset.load_job table_id, file, format: :csv, jagged_rows: true, quoted_newlines: true, autodetect: true,
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
    dataset.service.mocked_service = mock

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.json"),
        [project, load_job_gapi(table_reference), upload_source: file, content_type: "application/json"]

      job = dataset.load_job table_id, file, format: "JSON"
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify
  end

  it "can upload a json file with encryption configuration" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_json do |file|
      encrypt_config = Google::Cloud::Bigquery::EncryptionConfiguration.new
      encrypt_config.kms_key_name =  "projects/1/locations/1/keyRings/1/cryptoKeys/1"

      load_job_req = load_job_gapi(table_reference)
      load_job_req.configuration.load.destination_encryption_configuration = encrypt_config.to_gapi
      load_job_resp = load_job_resp_gapi("some/file/path.json")
      load_job_resp.configuration.load.destination_encryption_configuration = encrypt_config.to_gapi
      mock.expect :insert_job, load_job_resp,
        [project, load_job_req, upload_source: file, content_type: "application/json"]

      job = dataset.load_job table_id, file, format: "JSON",
                             destination_encryption_configuration: encrypt_config
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.destination_encryption_configuration.kms_key_name.must_equal "projects/1/locations/1/keyRings/1/cryptoKeys/1"
    end

    mock.verify
  end

  it "can upload a json file and derive the format" do
    mock = Minitest::Mock.new
    mock.expect :insert_job, load_job_resp_gapi("some/file/path.json"),
      [project, load_job_gapi(table_reference), upload_source: "acceptance/data/kitten-test-data.json", content_type: "application/json"]
    dataset.service.mocked_service = mock

    local_json = "acceptance/data/kitten-test-data.json"
    job = dataset.load_job table_id, local_json
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can upload a json file with job_id option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = load_job_gapi table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = dataset.load_job table_id, file, format: "JSON", job_id: job_id
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
    dataset.service.mocked_service = mock
    job_gapi = load_job_gapi table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = dataset.load_job table_id, file, format: "JSON", prefix: prefix
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.job_id.must_equal job_id
    end

    mock.verify
  end

  it "can upload a json file with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = load_job_gapi table_reference, job_id: job_id

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi("some/file/path.json", job_id: job_id),
        [project, job_gapi, upload_source: file, content_type: "application/json"]

      job = dataset.load_job table_id, file, format: "JSON", job_id: job_id, prefix: "IGNORED"
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      job.job_id.must_equal job_id
    end

    mock.verify
  end
end
