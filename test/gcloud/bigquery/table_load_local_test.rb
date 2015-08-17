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

describe Gcloud::Bigquery::Table, :load, :local, :mock_bigquery do
  let(:dataset) { "dataset" }
  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_hash) { random_table_hash dataset,
                                       table_id,
                                       table_name,
                                       description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "can upload a csv file" do
    mock_connection.post "/upload/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(get_json_from_multipart_body(env))
      json["configuration"]["load"]["sourceUris"].must_equal []
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "CSV"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json", Location: "/resumable/upload/bigquery/v2/projects/#{project}/jobs"},
       load_job_json(table, "some/file/path.csv")]
    end

    temp_csv do |file|
      job = table.load file, format: :csv
      job.must_be_kind_of Gcloud::Bigquery::LoadJob
    end
  end

  it "can upload a json file" do
    mock_connection.post "/upload/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(get_json_from_multipart_body(env))
      json["configuration"]["load"]["sourceUris"].must_equal []
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "NEWLINE_DELIMITED_JSON"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json", Location: "/resumable/upload/bigquery/v2/projects/#{project}/jobs"},
       load_job_json(table, "some/file/path.json")]
    end

    temp_json do |file|
      job = table.load file, format: "JSON"
      job.must_be_kind_of Gcloud::Bigquery::LoadJob
    end
  end

  it "can upload a json file and derive the format" do
    mock_connection.post "/upload/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(get_json_from_multipart_body(env))
      json["configuration"]["load"]["sourceUris"].must_equal []
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "NEWLINE_DELIMITED_JSON"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json", Location: "/resumable/upload/bigquery/v2/projects/#{project}/jobs"},
       load_job_json(table, "some/file/path.json")]
    end

    local_json = "acceptance/data/kitten-test-data.json"
    job = table.load local_json
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  def load_job_json table, load_url
    hash = random_job_hash
    hash["configuration"]["load"] = {
      "sourceUriss" => [load_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
    }
    hash.to_json
  end

  def temp_csv
    Tempfile.open "import.csv" do |tmpfile|
      tmpfile.puts "id,name"
      1000.times do |x| # write enough to be larger than the chunk_size
        tmpfile.puts "#{x},#{SecureRandom.urlsafe_base64(rand(8..16))}"
      end
      yield tmpfile
    end
  end

  def temp_json
    Tempfile.open "import.json" do |tmpfile|
      h = {}
      1000.times { |x| h["key-#{x}"] = {name: SecureRandom.urlsafe_base64(rand(8..16)) } }
      tmpfile.write h.to_json
      yield tmpfile
    end
  end

  def get_json_from_multipart_body env
    body = env.body.read.split("\n")
    env.body.rewind
    json = body.detect { |line| line.start_with? "{\"" }
    json
  end
end
