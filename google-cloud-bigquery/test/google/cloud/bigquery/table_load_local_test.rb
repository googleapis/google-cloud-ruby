# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Table, :load, :local, :mock_bigquery do
  let(:dataset) { "dataset" }
  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "can upload a csv file" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.csv"),
        [project, load_job_gapi(table_gapi.table_reference, "CSV")], upload_source: file, content_type: "text/csv"

      result = table.load file, format: :csv
      _(result).must_equal true
    end

    mock.verify
  end

  it "can upload a csv file with CSV options" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.csv"),
        [project, load_job_csv_options_gapi(table_gapi.table_reference)], upload_source: file, content_type: "text/csv"

      result = table.load file, format: :csv, jagged_rows: true, quoted_newlines: true, autodetect: true,
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
    table.service.mocked_service = mock

    temp_json do |file|
      mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json"),
        [project, load_job_gapi(table_gapi.table_reference)], upload_source: file, content_type: "application/json"

      result = table.load file, format: "JSON"
      _(result).must_equal true
    end

    mock.verify
  end

  it "can upload a json file and derive the format" do
    mock = Minitest::Mock.new
    mock.expect :insert_job, load_job_resp_gapi(table, "some/file/path.json"),
      [project, load_job_gapi(table_gapi.table_reference)], upload_source: "acceptance/data/kitten-test-data.json", content_type: "application/json"
    table.service.mocked_service = mock

    local_json = "acceptance/data/kitten-test-data.json"
    result = table.load local_json
    _(result).must_equal true

    mock.verify
  end
end
