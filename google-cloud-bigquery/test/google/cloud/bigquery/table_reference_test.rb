# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Table, :reference, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) {Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }

  let(:etag) { "etag123456789" }
  let(:field_timestamp_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "started_at", type: "TIMESTAMP", mode: "NULLABLE", description: nil, fields: [] }
  let(:field_timestamp) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_timestamp_gapi }

  let(:target_dataset) { "target_dataset" }
  let(:target_table_id) { "target_table_id" }
  let(:target_table_name) { "Target Table" }
  let(:target_description) { "This is the target table" }
  let(:target_table_gapi) { random_table_gapi target_dataset, target_table_id }
  let(:target_table) { Google::Cloud::Bigquery::Table.from_gapi target_table_gapi, bigquery.service }

  let(:credentials) { OpenStruct.new }
  let(:storage) { Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new(project, credentials)) }
  let(:storage_file_gapi) { Google::Apis::StorageV1::Object.from_json random_file_hash.to_json }
  let(:storage_file) { Google::Cloud::Storage::File.from_gapi storage_file_gapi, storage.service }

  let(:load_bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash.to_json }
  let(:load_bucket) { Google::Cloud::Storage::Bucket.from_gapi load_bucket_gapi, storage.service }
  let(:load_file) { storage_file }
  let(:load_url) { load_file.to_gs_url }

  let(:rows) { [{"name"=>"Heidi", "age"=>"36", "score"=>"7.65", "active"=>"true"},
                {"name"=>"Aaron", "age"=>"42", "score"=>"8.15", "active"=>"false"},
                {"name"=>"Sally", "age"=>nil, "score"=>nil, "active"=>nil}] }
  let(:insert_id) { "abc123" }
  let(:insert_rows) { rows.map do |row|
                        {
                          insertId: insert_id,
                          json: row
                        }
                      end }

  it "knows its attributes" do
    table.table_id.must_equal table_id
    table.dataset_id.must_equal dataset_id
    table.project_id.must_equal project
    table.table_ref.must_be_kind_of Google::Apis::BigqueryV2::TableReference
    table.table_ref.table_id.must_equal table_id
    table.table_ref.dataset_id.must_equal dataset_id
    table.table_ref.project_id.must_equal project

    table.time_partitioning?.must_be_nil
    table.time_partitioning_type.must_be_nil
    table.time_partitioning_expiration.must_be_nil
    table.id.must_be_nil
    table.name.must_be_nil
    table.etag.must_be_nil
    table.api_url.must_be_nil
    table.description.must_be_nil
    table.bytes_count.must_be_nil
    table.rows_count.must_be_nil
    table.created_at.must_be_nil
    table.expires_at.must_be_nil
    table.modified_at.must_be_nil
    table.table?.must_be_nil
    table.view?.must_be_nil
    table.external?.must_be_nil
    table.location.must_be_nil
    table.labels.must_be_nil
    table.schema.must_be_nil
    table.fields.must_be_nil
    table.headers.must_be_nil
    table.external.must_be_nil
    table.buffer_bytes.must_be_nil
    table.buffer_rows.must_be_nil
    table.buffer_oldest_at.must_be_nil
  end

  it "knows its fully-qualified query ID" do
    standard_id = "`#{project}.#{dataset_id}.#{table_id}`"
    legacy_id = "[#{project}:#{dataset_id}.#{table_id}]"

    table.query_id.must_equal standard_id
    table.query_id(standard_sql: true).must_equal standard_id
    table.query_id(standard_sql: false).must_equal legacy_id
    table.query_id(legacy_sql: true).must_equal legacy_id
    table.query_id(legacy_sql: false).must_equal standard_id
  end

  it "adds to its existing schema" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [table.project_id, table.dataset_id, table.table_id]
    end_date_timestamp_gapi = field_timestamp_gapi.dup
    end_date_timestamp_gapi.name = "end_date"
    new_schema_gapi = table_gapi.schema.dup
    new_schema_gapi.fields = table_gapi.schema.fields.dup
    new_schema_gapi.fields << end_date_timestamp_gapi
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema_gapi
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new schema: new_schema_gapi, etag: etag
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, returned_table_gapi, [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    table.schema do |schema|
      schema.timestamp "end_date"
    end

    mock.verify

    table.headers.must_include :end_date
  end

  it "replaces existing schema with replace option" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [table.project_id, table.dataset_id, table.table_id]
    new_schema_gapi = Google::Apis::BigqueryV2::TableSchema.new(
      fields: [field_timestamp_gapi])
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema_gapi
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new schema: new_schema_gapi, etag: etag
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, returned_table_gapi, [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    table.schema replace: true do |schema|
      schema.timestamp "started_at"
    end

    mock.verify

    table.schema.fields.must_include field_timestamp
  end

  it "can update the permanent external data source" do
    request_table_gapi = Google::Apis::BigqueryV2::Table.new(
      etag: etag,
      external_data_configuration: Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
        source_format: "NEWLINE_DELIMITED_JSON",
        source_uris: ["gs://my-bucket/path/to/file.json"],
        schema: Google::Apis::BigqueryV2::TableSchema.new(
          fields: [
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "id", type: "INTEGER", description: "id description", fields: []),
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name", type: "STRING", description: "name description", fields: []),
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "breed", type: "STRING", description: "breed description", fields: [])
          ]
        )
      )
    )
    response_table_gapi = table_gapi.dup
    response_table_gapi.external_data_configuration = request_table_gapi.external_data_configuration

    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [table.project_id, table.dataset_id, table.table_id]
    mock.expect :patch_table, table_gapi,
      [project, dataset_id, table_id, request_table_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, response_table_gapi, [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.external = bigquery.external "gs://my-bucket/path/to/file.json" do |json|
      json.schema do |s|
        s.integer   "id",    description: "id description",    mode: :required
        s.string    "name",  description: "name description",  mode: :required
        s.string    "breed", description: "breed description", mode: :required
      end
    end

    mock.verify

    table.external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
    table.external.urls.must_equal ["gs://my-bucket/path/to/file.json"]
    table.external.format.must_equal "NEWLINE_DELIMITED_JSON"
    table.external.autodetect.must_be :nil?
    table.external.schema.wont_be :empty?
    table.external.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.external.schema.must_be :frozen?
    table.external.must_be :frozen?
  end

  it "returns data as a list of hashes" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_table, table_gapi, [table.project_id, table.dataset_id, table.table_id]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.count.must_equal 3
    data[0].must_be_kind_of Hash
  end

  it "can copy itself with copy_job" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(table, target_table)
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = table.copy_job target_table
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy itself with copy" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(table, target_table)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    result = table.copy target_table
    mock.verify

    result.must_equal true
  end

  it "can extract itself with extract_job" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi(table, storage_file)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = table.extract_job storage_file
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract itself with extract" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi(table, storage_file)
    job_resp_gapi = job_gapi.dup
    job_resp_gapi.status = status "done"

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    result = table.extract storage_file
    mock.verify

    result.must_equal true
  end

  it "can load data from a storage file with load_job" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    mock.expect :insert_job, load_job_resp_gapi(table, load_url),
      [project, job_gapi]
    table.service.mocked_service = mock

    job = table.load_job load_file
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can upload a csv file with load" do
    mock = Minitest::Mock.new
    table.service.mocked_service = mock

    temp_csv do |file|
      job_resp_gapi = load_job_resp_gapi(table, "some/file/path.csv")
      job_resp_gapi.status = status "done"
      mock.expect :insert_job, job_resp_gapi,
        [project, load_job_gapi(table_gapi.table_reference, "CSV"), upload_source: file, content_type: "text/comma-separated-values"]

      result = table.load file, format: :csv
      result.must_equal true
    end

    mock.verify
  end

  it "can insert multiple rows" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [table.project_id, table.dataset_id, table.table_id, insert_req, options: { skip_serialization: true }]
    table.service.mocked_service = mock

    result = nil
    SecureRandom.stub :uuid, insert_id do
      result = table.insert rows
    end

    mock.verify

    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "inserts three rows one at a time with insert_async" do
    mock = Minitest::Mock.new
    insert_req = {
      rows: insert_rows, ignoreUnknownValues: nil, skipInvalidRows: nil
    }.to_json
    mock.expect :insert_all_table_data, success_table_insert_gapi,
      [table.project_id, table.dataset_id, table.table_id, insert_req, options: { skip_serialization: true }]
    table.service.mocked_service = mock

    inserter = table.insert_async

    SecureRandom.stub :uuid, insert_id do
      rows.each do |row|
        inserter.insert row
      end

      inserter.batch.rows.must_equal rows

      inserter.must_be :started?
      inserter.wont_be :stopped?

      # force the queued rows to be inserted
      inserter.flush
      inserter.stop.wait!

      inserter.wont_be :started?
      inserter.must_be :stopped?

      inserter.batch.must_be :nil?
    end

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_table, nil,
      [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.delete

    mock.verify
  end

  def random_file_hash bucket="bucket123", name="file.ext"
    {"kind"=>"storage#object",
     "id"=>"#{bucket}/#{name}/1234567890",
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
     "name"=>"#{name}",
     "bucket"=>"#{bucket}",
     "generation"=>"1234567890",
     "metageneration"=>"1",
     "contentType"=>"text/plain",
     "updated"=>::Time.now,
     "storageClass"=>"STANDARD",
     "size"=>rand(10_000),
     "md5Hash"=>"HXB937GQDFxDFqUGi//weQ==",
     "mediaLink"=>"https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
     "owner"=>{"entity"=>"user-1234567890", "entityId"=>"abc123"},
     "crc32c"=>"Lm1F3g==",
     "etag"=>"CKih16GjycICEAE="}
  end

  def load_job_resp_gapi table, load_url, job_id: "job_9876543210", labels: nil
    hash = random_job_hash job_id
    hash["configuration"]["load"] = {
      "sourceUris" => [load_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      },
    }
    resp = Google::Apis::BigqueryV2::Job.from_json hash.to_json
    resp.configuration.labels = labels if labels
    resp
  end

  def success_table_insert_gapi
    Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(
      insert_errors: []
    )
  end
end
