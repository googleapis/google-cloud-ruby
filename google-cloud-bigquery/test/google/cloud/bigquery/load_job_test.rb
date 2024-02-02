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

describe Google::Cloud::Bigquery::LoadJob, :mock_bigquery do
  let(:job_defaults_gapi) { Google::Apis::BigqueryV2::Job.from_json load_job_defaults_hash.to_json }
  let(:job_defaults) { Google::Cloud::Bigquery::Job.from_gapi job_defaults_gapi, bigquery.service }
  let(:job_gapi) { Google::Apis::BigqueryV2::Job.from_json load_job_hash.to_json }
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi job_gapi, bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is load job" do
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
  end

  it "knows its source uris" do
    _(job.sources).must_be_kind_of Array
    _(job.sources.count).must_equal 1
    _(job.sources.first).must_equal "gs://bucket/file.ext"
  end

  it "knows its destination table" do
    mock = Minitest::Mock.new
    mock.expect :get_table, destination_table_gapi, 
      ["target_project_id", "target_dataset_id", "target_table_id"], **patch_table_args

    job.service.mocked_service = mock

    table = job.destination
    _(table).must_be_kind_of Google::Cloud::Bigquery::Table

    mock.verify

    _(table.project_id).must_equal "target_project_id"
    _(table.dataset_id).must_equal "target_dataset_id"
    _(table.table_id).must_equal   "target_table_id"
  end

  it "knows its destination table with partial projection of table metadata" do
    %w[unspecified basic storage full].each do |view|
      mock = Minitest::Mock.new
      job.service.mocked_service = mock
      destination_table_result = destination_table_gapi

      if view == "basic"
        destination_table_result = destination_table_partial_gapi
      end

      mock.expect :get_table, destination_table_result, ["target_project_id", "target_dataset_id", "target_table_id"],
                  **patch_table_args(view: view)

      table = job.destination view: view
      _(table).must_be_kind_of Google::Cloud::Bigquery::Table
      _(table.project_id).must_equal "target_project_id"
      _(table.dataset_id).must_equal "target_dataset_id"
      _(table.table_id).must_equal "target_table_id"
      verify_table_metadata table, view

      mock.verify
    end
  end

  it "knows its default attributes" do
    _(job_defaults.transaction_id).must_be :nil?
    _(job_defaults.delimiter).must_equal ","
    _(job_defaults.skip_leading_rows).must_equal 0
    _(job_defaults).must_be :utf8?
    _(job_defaults).wont_be :iso8859_1?
    _(job_defaults.quote).must_equal "\""
    _(job_defaults.max_bad_records).must_equal 0
    _(job_defaults.null_marker).must_equal ""
    _(job_defaults).wont_be :quoted_newlines?
    _(job_defaults).wont_be :autodetect?
    _(job_defaults).must_be :json?
    _(job_defaults).wont_be :csv?
    _(job_defaults).wont_be :backup?
    _(job_defaults).wont_be :allow_jagged_rows?
    _(job_defaults).wont_be :ignore_unknown_values?
  end

  it "knows its full attributes" do
    _(job.delimiter).must_equal ","
    _(job.skip_leading_rows).must_equal 0
    _(job).must_be :utf8?
    _(job).wont_be :iso8859_1?
    _(job.quote).must_equal "\""
    _(job.max_bad_records).must_equal 0
    _(job.null_marker).must_equal "\N"
    _(job).must_be :quoted_newlines?
    _(job).must_be :autodetect?
    _(job).must_be :json?
    _(job).wont_be :csv?
    _(job).wont_be :backup?
    _(job).must_be :allow_jagged_rows?
    _(job).must_be :ignore_unknown_values?
  end

  it "knows its statistics data" do
    _(job.input_files).must_equal 3
    _(job.input_file_bytes).must_equal 456
    _(job.output_rows).must_equal 5
    _(job.output_bytes).must_equal 789
  end

  it "knows its schema" do
    _(job.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(job.schema).must_be :frozen?
    _(job.schema.fields).wont_be :empty?
    _(job.schema.fields.map(&:name)).must_equal ["name", "age", "score", "pi", "my_bignumeric", "active", 
                                                 "avatar", "started_at", "duration", "target_end", 
                                                 "birthday", "home", "address"]
  end

  it "knows its load config" do
    _(job.config).must_be_kind_of Hash
    _(job.config["load"]["destinationTable"]["tableId"]).must_equal "target_table_id"
    _(job.config["load"]["createDisposition"]).must_equal "CREATE_IF_NEEDED"
    _(job.config["load"]["encoding"]).must_equal "UTF-8"
  end

  def load_job_defaults_hash
    hash = random_job_hash
    hash["configuration"]["load"] = {
      "sourceUris" => ["gs://bucket/file.ext"],
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "schema" => random_schema_hash,
      "sourceFormat" => "NEWLINE_DELIMITED_JSON"
    }
    hash["statistics"]["load"] = {
      "inputFiles" => "3", # String per google/google-api-ruby-client#439
      "inputFileBytes" => "456", # String per google/google-api-ruby-client#439
      "outputRows" => "5", # String per google/google-api-ruby-client#439
      "outputBytes" => "789" # String per google/google-api-ruby-client#439
    }
    hash
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
      "nullMarker" => "\N",
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

  def destination_table_partial_gapi
    hash = random_table_partial_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    Google::Apis::BigqueryV2::Table.from_json hash.to_json
  end
end
