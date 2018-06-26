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

describe Google::Cloud::Bigquery::Dataset, :load_job, :schema, :mock_bigquery do
  let(:credentials) { OpenStruct.new }
  let(:storage) { Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new(project, credentials)) }
  let(:load_bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash.to_json }
  let(:load_bucket) { Google::Cloud::Storage::Bucket.from_gapi load_bucket_gapi, storage.service }
  let(:load_file) { storage_file }
  let(:load_url) { load_file.to_gs_url }

  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "table_id" }
  let(:table_reference) { Google::Apis::BigqueryV2::TableReference.new(
    project_id: "test-project",
    dataset_id: "my_dataset",
    table_id: "table_id"
  ) }

  let(:table_name) { "My Table" }
  let(:table_description) { "This is my table" }
  let(:table_schema) {
    {
      fields: [
        { mode: "REQUIRED", name: "name", type: "STRING", description: nil, fields: [] },
        { mode: "NULLABLE", name: "age", type: "INTEGER", description: nil, fields: [] },
        { mode: "NULLABLE", name: "score", type: "FLOAT", description: "A score from 0.0 to 10.0", fields: [] },
        { mode: "NULLABLE", name: "active", type: "BOOLEAN", description: nil, fields: [] },
        { mode: "NULLABLE", name: "avatar", type: "BYTES", description: nil, fields: [] },
        { mode: "REQUIRED", name: "dob", type: "TIMESTAMP", description: nil, fields: [] }
      ]
    }
  }
  let(:table_schema_gapi) do
    gapi = Google::Apis::BigqueryV2::TableSchema.from_json table_schema.to_json
    gapi.fields.each do |f|
      f.update! fields: []
    end
    gapi
  end

  let(:schema_update_options) { ["ALLOW_FIELD_ADDITION", "ALLOW_FIELD_RELAXATION"] }
  let(:time_partitioning) { Google::Apis::BigqueryV2::TimePartitioning.new type: "DAY", field: "dob", expiration_ms: 86_400_000, require_partition_filter: true }

  def storage_file path = nil
    gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(load_bucket.name, path).to_json
    Google::Cloud::Storage::File.from_gapi gapi, storage.service
  end

  it "can specify a schema in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    job_gapi.configuration.load.schema_update_options = schema_update_options
    job_gapi.configuration.load.time_partitioning = time_partitioning

    job_resp_gapi = load_job_resp_gapi(load_url)
    job_resp_gapi.configuration.load.schema_update_options = schema_update_options
    job_resp_gapi.configuration.load.time_partitioning = time_partitioning

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file, create: :needed do |job|
      job.schema.string "name", mode: :required
      job.schema.integer "age"
      job.schema.float "score", description: "A score from 0.0 to 10.0"
      job.schema.boolean "active"
      job.schema.bytes "avatar"
      job.schema.timestamp "dob", mode: :required
      job.schema_update_options = schema_update_options
      job.time_partitioning_type = "DAY"
      job.time_partitioning_field = "dob"
      job.time_partitioning_expiration = 86_400
      job.time_partitioning_require_filter = true
    end

    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.schema_update_options.must_equal schema_update_options
    job.time_partitioning?.must_equal true
    job.time_partitioning_type.must_equal "DAY"
    job.time_partitioning_field.must_equal "dob"
    job.time_partitioning_expiration.must_equal 86_400
    job.time_partitioning_require_filter?.must_equal true

    mock.verify
  end

  it "can specify a schema as an option during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    mock.expect :insert_job, load_job_resp_gapi(load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    schema = bigquery.schema
    schema.string "name", mode: :required
    schema.integer "age"
    schema.float "score", description: "A score from 0.0 to 10.0"
    schema.boolean "active"
    schema.bytes "avatar"
    schema.timestamp "dob", mode: :required

    job = dataset.load_job table_id, load_file, create: :needed, schema: schema
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.schema_update_options.must_be_kind_of Array
    job.schema_update_options.must_be :empty?
    job.time_partitioning?.must_equal false
    job.time_partitioning_type.must_be :nil?
    job.time_partitioning_field.must_be :nil?
    job.time_partitioning_expiration.must_be :nil?
    job.time_partitioning_require_filter?.must_equal false

    mock.verify
  end

  it "can specify a schema both as an option and in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    job_gapi.configuration.load.schema_update_options = schema_update_options

    job_resp_gapi = load_job_resp_gapi(load_url)
    job_resp_gapi.configuration.load.schema_update_options = schema_update_options
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]
    dataset.service.mocked_service = mock

    schema = bigquery.schema
    schema.string "name", mode: :required
    schema.integer "age"

    job = dataset.load_job table_id, load_file, create: :needed, schema: schema do |schema|
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.boolean "active"
      schema.bytes "avatar"
      schema.timestamp "dob", mode: :required
      schema.schema_update_options = schema_update_options
    end
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.schema_update_options.must_equal schema_update_options

    mock.verify
  end


  def load_job_gapi load_url
    hash = random_job_hash
    hash["configuration"]["load"] = {
      "sourceUris" => [load_url],
      "destinationTable" => {
        "projectId" => project,
        "datasetId" => dataset_id,
        "tableId" => table_id
      },
    }
    Google::Apis::BigqueryV2::Job.from_json hash.to_json
  end

  # Borrowed from MockStorage, load to a common module?

  def random_bucket_hash name=random_bucket_name
    {"kind"=>"storage#bucket",
     "id"=>name,
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{name}",
     "projectNumber"=>"1234567890",
     "name"=>name,
     "timeCreated"=>::Time.now,
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
     "updated"=>::Time.now,
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
