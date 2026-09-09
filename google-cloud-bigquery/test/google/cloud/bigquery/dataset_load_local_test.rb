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

describe Google::Cloud::Bigquery::Dataset, :load, :local, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "table_id" }
  let(:session_id) { "mysessionid" }
  let(:table_reference) { Google::Apis::BigqueryV2::TableReference.new(
    project_id: "test-project",
    dataset_id: "my_dataset",
    table_id: "table_id"
  ) }

  it "can upload a csv file" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv"),
        [project, load_job_gapi(table_reference, "CSV")], upload_source: file, content_type: "text/csv"

      result = dataset.load table_id, file, format: :csv
      _(result).must_equal true
    end
    mock.verify
  end

  it "can upload a csv file with CSV options" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv"),
        [project, load_job_csv_options_gapi(table_reference)], upload_source: file, content_type: "text/csv"

      result = dataset.load table_id, file, format: :csv, jagged_rows: true, quoted_newlines: true, autodetect: true,
        encoding: "ISO-8859-1", delimiter: "\t", ignore_unknown: true, max_bad_records: 42, null_marker: "\N",
        quote: "'", skip_leading: 1
      _(result).must_equal true
    end

    mock.verify

    temp_csv do |file|

    end
  end

  it "can upload a json file" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.json"),
        [project, load_job_gapi(table_reference)], upload_source: file, content_type: "application/json"

      result = dataset.load table_id, file, format: "JSON"
      _(result).must_equal true
    end

    mock.verify
  end

  it "can upload a json file and derive the format" do
    mock = Minitest::Mock.new
    mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.json"),
      [project, load_job_gapi(table_reference)], upload_source: "acceptance/data/kitten-test-data.json", content_type: "application/json"
    dataset.service.mocked_service = mock

    local_json = "acceptance/data/kitten-test-data.json"
    result = dataset.load table_id, local_json
    _(result).must_equal true

    mock.verify
  end

  it "load the data with create_session option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv", session_id: session_id),
        [project, load_job_gapi(table_reference, "CSV", create_session: true)], upload_source: file, content_type: "text/csv"

      job = dataset.load_job table_id, file, format: :csv, create_session: true
      _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
      _(job.session_id).must_equal session_id
    end
    mock.verify
  end

  it "load the data with create_session in block" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv", session_id: session_id),
        [project, load_job_gapi(table_reference, "CSV", create_session: true)], upload_source: file, content_type: "text/csv"

      job = dataset.load_job table_id, file, format: :csv do |j|
            j.create_session = true
        end
      _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
      _(job.session_id).must_equal session_id
    end
    mock.verify
  end

  it "load the data with session_id option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv", session_id: session_id),
        [project, load_job_gapi(table_reference, "CSV", session_id: session_id)], upload_source: file, content_type: "text/csv"

      job = dataset.load_job table_id, file, format: :csv, session_id: session_id
      _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
      _(job.session_id).must_equal session_id
    end
    mock.verify
  end

  it "load the data with session_id in block" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table_reference, "some/file/path.csv", session_id: session_id),
        [project, load_job_gapi(table_reference, "CSV", session_id: session_id)], upload_source: file, content_type: "text/csv"

      job = dataset.load_job table_id, file, format: :csv do |j|
            j.session_id = session_id
            j.session_id = nil
            j.session_id = session_id
        end
      _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
      _(job.session_id).must_equal session_id
    end
    mock.verify
  end
end
