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

describe Google::Cloud::Bigquery::LoadJob, :mock_bigquery do
  let(:job_gapi) { Google::Apis::BigqueryV2::Job.from_json load_job_hash.to_json }
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi job_gapi, bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is load job" do
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
  end

  it "knows its source uris" do
    job.sources.must_be_kind_of Array
    job.sources.count.must_equal 1
    job.sources.first.must_equal "gs://bucket/file.ext"
  end

  it "knows its destination table" do
    mock = Minitest::Mock.new
    mock.expect :get_table, destination_table_gapi,
      ["target_project_id", "target_dataset_id", "target_table_id"]

    job.service.mocked_service = mock

    table = job.destination
    table.must_be_kind_of Google::Cloud::Bigquery::Table

    mock.verify

    table.project_id.must_equal "target_project_id"
    table.dataset_id.must_equal "target_dataset_id"
    table.table_id.must_equal   "target_table_id"
  end

  it "knows its attributes" do
    job.delimiter.must_equal ","
    job.skip_leading_rows.must_equal 0
    job.must_be :utf8?
    job.wont_be :iso8859_1?
    job.quote.must_equal "\""
    job.max_bad_records.must_equal 0
    job.must_be :quoted_newlines?
    job.must_be :autodetect?
    job.must_be :json?
    job.wont_be :csv?
    job.wont_be :backup?
    job.must_be :allow_jagged_rows?
    job.must_be :ignore_unknown_values?
  end

  it "knows its statistics data" do
    job.input_files.must_equal 3
    job.input_file_bytes.must_equal 456
    job.output_rows.must_equal 5
    job.output_bytes.must_equal 789
  end

  it "knows its schema" do
    job.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    job.schema.must_be :frozen?
    job.schema.fields.wont_be :empty?
    job.schema.fields.map(&:name).must_equal ["name", "age", "score", "active", "avatar", "started_at", "duration", "target_end", "birthday"]
  end

  it "knows its load config" do
    job.config.must_be_kind_of Hash
    job.config["load"]["destinationTable"]["tableId"].must_equal "target_table_id"
    job.config["load"]["createDisposition"].must_equal "CREATE_IF_NEEDED"
    job.config["load"]["encoding"].must_equal "UTF-8"
  end

  def load_job_hash
    hash = random_job_hash
    hash["configuration"]["load"] = {
      "sourceUris" => ["gs://bucket/file.ext"],
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY",
      "schema" => random_schema_hash,
      "fieldDelimiter" => ",",
      "skipLeadingRows" => 0,
      "encoding" => "UTF-8",
      "quote" => "\"",
      "maxBadRecords" => 0,
      "allowQuotedNewlines" => true,
      "autodetect" => true,
      "sourceFormat" => "NEWLINE_DELIMITED_JSON",
      "allowJaggedRows" => true,
      "ignoreUnknownValues" => true
    }
    hash["statistics"]["load"] = {
      "inputFiles" => "3", # String per google/google-api-ruby-client#439
      "inputFileBytes" => "456", # String per google/google-api-ruby-client#439
      "outputRows" => "5", # String per google/google-api-ruby-client#439
      "outputBytes" => "789" # String per google/google-api-ruby-client#439
    }
    hash
  end

  def destination_table_gapi
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    Google::Apis::BigqueryV2::Table.from_json hash.to_json
  end
end
