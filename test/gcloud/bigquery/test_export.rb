# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Table, :extract, :mock_bigquery do
  let(:credentials) { OpenStruct.new }
  let(:storage) { Gcloud::Storage::Project.new project, credentials }
  let(:extract_bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash,
                                                           storage.connection }
  let(:extract_file) { Gcloud::Storage::File.from_gapi random_file_hash(extract_bucket.name),
                                                       storage.connection }
  let(:extract_url) { extract_file.to_gs_url }

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

  it "can extract itself to a storage file" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"].wont_include "destinationFormat"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_file
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself to a storage url" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"].wont_include "destinationFormat"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_url
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself as a dryrun" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"].wont_include "destinationFormat"
      json["configuration"].must_include "dryRun"
      json["configuration"]["dryRun"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_url, dryrun: true
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and determine the csv format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal ["#{extract_url}.csv"]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "CSV"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract "#{extract_url}.csv"
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and specify the csv format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "CSV"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_url, format: :csv
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and determine the json format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal ["#{extract_url}.json"]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "NEWLINE_DELIMITED_JSON"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract "#{extract_url}.json"
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and specify the json format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "NEWLINE_DELIMITED_JSON"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_url, format: :json
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and determine the avro format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal ["#{extract_url}.avro"]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "AVRO"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract "#{extract_url}.avro"
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  it "can extract itself and specify the avro format" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["extract"]["destinationUris"].must_equal [extract_url]
      json["configuration"]["extract"]["sourceTable"]["projectId"].must_equal table.project_id
      json["configuration"]["extract"]["sourceTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["extract"]["sourceTable"]["tableId"].must_equal table.table_id
      json["configuration"]["extract"]["destinationFormat"].must_equal "AVRO"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       extract_job_json(table, extract_file)]
    end

    job = table.extract extract_url, format: :avro
    job.must_be_kind_of Gcloud::Bigquery::Job
  end

  def extract_job_json table, extract_file
    hash = random_job_hash
    hash["configuration"]["extract"] = {
      "destinationUris" => [extract_file.url],
      "sourceTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
    }
    hash.to_json
  end

  # Borrowed from MockStorage, extract to a common module?

  def random_bucket_hash name=random_bucket_name
    {"kind"=>"storage#bucket",
     "id"=>name,
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{name}",
     "projectNumber"=>"1234567890",
     "name"=>name,
     "timeCreated"=>Time.now,
     "metageneration"=>"1",
     "owner"=>{"entity"=>"project-owners-1234567890"},
     "location"=>"US",
     "storageClass"=>"STANDARD",
     "etag"=>"CAE=" }
  end

  def random_file_hash bucket=random_bucket_name, name=random_file_path
    {"kind"=>"storage#object",
     "id"=>"#{bucket}/#{name}/1234567890",
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
     "name"=>"#{name}",
     "bucket"=>"#{bucket}",
     "generation"=>"1234567890",
     "metageneration"=>"1",
     "contentType"=>"text/plain",
     "updated"=>Time.now,
     "storageClass"=>"STANDARD",
     "size"=>rand(10_000),
     "md5Hash"=>"HXB937GQDFxDFqUGi//weQ==",
     "mediaLink"=>"https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
     "owner"=>{"entity"=>"user-1234567890", "entityId"=>"abc123"},
     "crc32c"=>"Lm1F3g==",
     "etag"=>"CKih16GjycICEAE="}
  end

  def random_bucket_name
    (0...50).map { ("a".."z").to_a[rand(26)] }.join
  end

  def random_file_path
    [(0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join + ".txt"].join "/"
  end
end
