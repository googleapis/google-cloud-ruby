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

  it "can upload a csv file" do
    mock = Minitest::Mock.new
    insert_job = Google::Apis::BigqueryV2::Job.new(
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_gapi.table_reference,
          source_format: "CSV"
        ),
        dry_run: nil))
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_gapi(table, "some/file/path.csv"),
        [project, insert_job, upload_source: file, content_type: "text/comma-separated-values"]

      job = table.load file, format: :csv
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify
  end

  it "can upload a csv file with CSV options" do
    mock = Minitest::Mock.new
    insert_job = Google::Apis::BigqueryV2::Job.new(
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_gapi.table_reference,
          source_format: "CSV",
          allow_jagged_rows: true,
          allow_quoted_newlines: true,
          encoding: "ISO-8859-1",
          field_delimiter: "\t",
          ignore_unknown_values: true,
          max_bad_records: 42,
          quote: "'",
          skip_leading_rows: 1
        ),
        dry_run: nil))
    table.service.mocked_service = mock

    temp_csv do |file|
      mock.expect :insert_job, load_job_gapi(table, "some/file/path.csv"),
        [project, insert_job, upload_source: file, content_type: "text/comma-separated-values"]

      job = table.load file, format: :csv, jagged_rows: true, quoted_newlines: true,
        encoding: "ISO-8859-1", delimiter: "\t", ignore_unknown: true, max_bad_records: 42,
        quote: "'", skip_leading: 1
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify

    temp_csv do |file|

    end
  end

  it "can upload a json file" do
    mock = Minitest::Mock.new
    insert_job = Google::Apis::BigqueryV2::Job.new(
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_gapi.table_reference,
          source_format: "NEWLINE_DELIMITED_JSON"
        ),
        dry_run: nil))
    table.service.mocked_service = mock

    temp_json do |file|
      mock.expect :insert_job, load_job_gapi(table, "some/file/path.json"),
        [project, insert_job, upload_source: file, content_type: "application/json"]

      job = table.load file, format: "JSON"
      job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    end

    mock.verify
  end

  it "can upload a json file and derive the format" do
    mock = Minitest::Mock.new
    insert_job = Google::Apis::BigqueryV2::Job.new(
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_gapi.table_reference,
          source_format: "NEWLINE_DELIMITED_JSON"
        ),
        dry_run: nil))
    mock.expect :insert_job, load_job_gapi(table, "some/file/path.json"),
      [project, insert_job, upload_source: "acceptance/data/kitten-test-data.json", content_type: "application/json"]
    table.service.mocked_service = mock

    local_json = "acceptance/data/kitten-test-data.json"
    job = table.load local_json
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  def load_job_gapi table, load_url
    hash = random_job_hash
    hash["configuration"]["load"] = {
      "sourceUris" => [load_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
    }
    Google::Apis::BigqueryV2::Job.from_json hash.to_json
  end

  def temp_csv
    Tempfile.open ["import", ".csv"] do |tmpfile|
      tmpfile.puts "id,name"
      1000.times do |x|
        tmpfile.puts "#{x},#{SecureRandom.urlsafe_base64(rand(8..16))}"
      end
      yield tmpfile
    end
  end

  def temp_json
    Tempfile.open ["import", ".json"] do |tmpfile|
      h = {}
      1000.times { |x| h["key-#{x}"] = {name: SecureRandom.urlsafe_base64(rand(8..16)) } }
      tmpfile.write h.to_json
      yield tmpfile
    end
  end
end
