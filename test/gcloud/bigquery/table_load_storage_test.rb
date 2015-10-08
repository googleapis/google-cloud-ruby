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

describe Gcloud::Bigquery::Table, :load, :storage, :mock_bigquery do
  let(:credentials) { OpenStruct.new }
  let(:storage) { Gcloud::Storage::Project.new project, credentials }
  let(:load_bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash,
                                                           storage.connection }
  let(:load_file) { storage_file }
  let(:load_url) { load_file.to_gs_url }

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

  def storage_file path = nil
    Gcloud::Storage::File.from_gapi random_file_hash(load_bucket.name, path),
                                    storage.connection
  end


  it "can specify a storage file" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"].wont_include "projectionFields"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_file
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can specify a storage file with format" do
    special_file = storage_file "data.json"
    special_url = special_file.to_gs_url

    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [special_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "CSV"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"

      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load special_file, format: :csv
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can specify a storage file and derive CSV format" do
    special_file = storage_file "data.csv"
    special_url = special_file.to_gs_url

    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [special_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "CSV"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"

      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load special_file
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can specify a storage file and derive CSV format with CSV options" do
    special_file = storage_file "data.csv"
    special_url = special_file.to_gs_url

    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [special_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"]["sourceFormat"].must_equal "CSV"
      json["configuration"]["load"]["allowJaggedRows"].must_equal true
      json["configuration"]["load"]["allowQuotedNewlines"].must_equal true
      json["configuration"]["load"]["encoding"].must_equal "ISO-8859-1"
      json["configuration"]["load"]["fieldDelimiter"].must_equal "\t"
      json["configuration"]["load"]["ignoreUnknownValues"].must_equal true
      json["configuration"]["load"]["maxBadRecords"].must_equal 42
      json["configuration"]["load"]["quote"].must_equal "'"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"]["skipLeadingRows"].must_equal 1

      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load special_file, jagged_rows: true, quoted_newlines: true,
      encoding: "ISO-8859-1", delimiter: "\t", ignore_unknown: true, max_bad_records: 42,
      quote: "'", skip_leading: 1
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can specify a storage file and derive Avro format" do
    special_file = storage_file "data.avro"

    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceFormat"].must_equal "AVRO"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    table.load special_file
  end

  it "can specify a storage file and derive Datastore backup format" do
    special_file = storage_file "data.backup_info"

    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceFormat"].must_equal "DATASTORE_BACKUP"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    table.load special_file
  end

  it "can load a Datastore backup file and specify projection fields" do
    special_file = storage_file "data.backup_info"

    projection_fields = ["first_name"]
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["projectionFields"].must_equal projection_fields
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    table.load special_file, projection_fields: projection_fields
  end

  it "can specify a storage url" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can load itself as a dryrun" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].must_include "dryRun"
      json["configuration"]["dryRun"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url, dryrun: true
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can load itself with create disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].must_include "createDisposition"
      json["configuration"]["load"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url, create: "CREATE_NEVER"
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can load itself with create disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].must_include "createDisposition"
      json["configuration"]["load"]["createDisposition"].must_equal "CREATE_NEVER"
      json["configuration"]["load"].wont_include "writeDisposition"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url, create: :never
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can load itself with write disposition" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].must_include "writeDisposition"
      json["configuration"]["load"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url, write: "WRITE_TRUNCATE"
    job.must_be_kind_of Gcloud::Bigquery::LoadJob
  end

  it "can load itself with write disposition symbol" do
    mock_connection.post "/bigquery/v2/projects/#{project}/jobs" do |env|
      json = JSON.parse(env.body)
      json["configuration"]["load"]["sourceUris"].must_equal [load_url]
      json["configuration"]["load"]["destinationTable"]["projectId"].must_equal table.project_id
      json["configuration"]["load"]["destinationTable"]["datasetId"].must_equal table.dataset_id
      json["configuration"]["load"]["destinationTable"]["tableId"].must_equal table.table_id
      json["configuration"]["load"].wont_include "createDisposition"
      json["configuration"]["load"].must_include "writeDisposition"
      json["configuration"]["load"]["writeDisposition"].must_equal "WRITE_TRUNCATE"
      json["configuration"]["load"].wont_include "sourceFormat"
      json["configuration"]["load"].wont_include "allowJaggedRows"
      json["configuration"]["load"].wont_include "allowQuotedNewlines"
      json["configuration"]["load"].wont_include "encoding"
      json["configuration"]["load"].wont_include "fieldDelimiter"
      json["configuration"]["load"].wont_include "ignoreUnknownValues"
      json["configuration"]["load"].wont_include "maxBadRecords"
      json["configuration"]["load"].wont_include "quote"
      json["configuration"]["load"].wont_include "schema"
      json["configuration"]["load"].wont_include "skipLeadingRows"
      json["configuration"].wont_include "dryRun"
      [200, {"Content-Type"=>"application/json"},
       load_job_json(table, load_url)]
    end

    job = table.load load_url, write: :truncate
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

  # Borrowed from MockStorage, load to a common module?

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
