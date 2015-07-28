# Copyright 2014 Google Inc. All rights reserved.
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

describe Gcloud::Bigquery::LoadJob, :mock_bigquery do
  let(:job) { Gcloud::Bigquery::Job.from_gapi load_job_hash,
                                              bigquery.connection }
  let(:job_id) { job.job_id }

  it "knows it is load job" do
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "knows its source uris" do
    job.sources.must_be_kind_of Array
    job.sources.count.must_equal 1
    job.sources.first.must_equal "gs://bucket/file.ext"
  end

  it "knows its destination table" do
    mock_connection.get "/bigquery/v2/projects/target_project_id/datasets/target_dataset_id/tables/target_table_id" do |env|
      [200, {"Content-Type"=>"application/json"},
       destination_table_json]
    end

    job.destination.must_be_kind_of Gcloud::Bigquery::Table
    job.destination.project_id.must_equal "target_project_id"
    job.destination.dataset_id.must_equal "target_dataset_id"
    job.destination.table_id.must_equal   "target_table_id"
  end

  it "knows its attributes" do
    job.delimiter.must_equal ","
    job.skip_leading_rows.must_equal 0
    job.must_be :utf8?
    job.wont_be :iso8859_1?
    job.quote.must_equal "\""
    job.max_bad_records.must_equal 0
    job.must_be :quoted_newlines?
    job.must_be :json?
    job.wont_be :csv?
    job.wont_be :backup?
    job.must_be :allow_jagged_rows?
    job.must_be :ignore_unknown_values?
  end

  it "knows its schema" do
    job.schema.must_be_kind_of Hash
    job.schema["fields"][0]["name"].must_equal "name"
    job.schema["fields"][1]["type"].must_equal "INTEGER"
    job.schema["fields"][2]["mode"].must_equal "NULLABLE"
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
      "schema" => {
        "fields" => [
          { "name" => "name",
            "type" => "STRING",
            "mode" => "NULLABLE" },
          { "name" => "age",
            "type" => "INTEGER",
            "mode" => "NULLABLE" },
          { "name" => "score",
            "type" => "FLOAT",
            "mode" => "NULLABLE" },
          { "name" => "active",
            "type" => "BOOLEAN",
            "mode" => "NULLABLE" }]},
      "fieldDelimiter" => ",",
      "skipLeadingRows" => 0,
      "encoding" => "UTF-8",
      "quote" => "\"",
      "maxBadRecords" => 0,
      "allowQuotedNewlines" => true,
      "sourceFormat" => "NEWLINE_DELIMITED_JSON",
      "allowJaggedRows" => true,
      "ignoreUnknownValues" => true
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
end
