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

describe Google::Cloud::Bigquery::Dataset, :load, :schema, :mock_bigquery do
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

  let(:policy_tag) { "projects/#{project}/locations/us/taxonomies/1/policyTags/1" }
  let(:policy_tag_2) { "projects/#{project}/locations/us/taxonomies/1/policyTags/2" }
  let(:policy_tags) { [ policy_tag, policy_tag_2 ] }
  let(:policy_tags_gapi) { Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags.new names: policy_tags }
  let(:max_length_string) { 50 }
  let(:max_length_bytes) { 1024 }
  let(:precision_numeric) { 10 }
  let(:precision_bignumeric) { 38 }
  let(:scale_numeric) { 9 }
  let(:scale_bignumeric) { 37 }

  let(:table_schema_gapi) do
    Google::Apis::BigqueryV2::TableSchema.new(fields: [
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: [], max_length: max_length_string),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", policy_tags: policy_tags_gapi, description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "cost",          type: "NUMERIC", description: nil, fields: [], precision: precision_numeric, scale: scale_numeric),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_bignumeric", type: "BIGNUMERIC", description: nil, fields: [], precision: precision_bignumeric, scale: scale_bignumeric),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: [], max_length: max_length_bytes),
      ])
  end

  def storage_file path = nil
    gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(load_bucket.name, path).to_json
    Google::Cloud::Storage::File.from_gapi gapi, storage.service
  end

  it "can specify a schema in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    mock.expect :insert_job, load_job_resp_gapi(table_reference, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    result = dataset.load table_id, load_file, create: :needed do |schema|
      schema.string "name", mode: :required, max_length: max_length_string
      schema.integer "age", policy_tags: policy_tags
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      schema.boolean "active"
      schema.bytes "avatar", max_length: max_length_bytes
    end
    _(result).must_equal true

    mock.verify
  end

  it "can specify a schema as an option during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    mock.expect :insert_job, load_job_resp_gapi(table_reference, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    schema = bigquery.schema
    schema.string "name", mode: :required, max_length: max_length_string
    schema.integer "age", policy_tags: policy_tags
    schema.float "score", description: "A score from 0.0 to 10.0"
    schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
    schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
    schema.boolean "active"
    schema.bytes "avatar", max_length: max_length_bytes

    result = dataset.load table_id, load_file, create: :needed, schema: schema
    _(result).must_equal true

    mock.verify
  end

  it "can specify a schema both as an option and in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = table_schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    mock.expect :insert_job, load_job_resp_gapi(table_reference, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    schema = bigquery.schema
    schema.string "name", mode: :required, max_length: max_length_string
    schema.integer "age", policy_tags: policy_tags

    result = dataset.load table_id, load_file, create: :needed, schema: schema do |schema|
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      schema.boolean "active"
      schema.bytes "avatar", max_length: max_length_bytes
    end
    _(result).must_equal true

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
