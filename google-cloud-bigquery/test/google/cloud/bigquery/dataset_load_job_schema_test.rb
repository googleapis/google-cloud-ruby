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
  let(:schema_gapi_fields) do
    [
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: [], max_length: max_length_string),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", policy_tags: policy_tags_gapi, description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "cost",          type: "NUMERIC", description: nil, fields: [], precision: precision_numeric, scale: scale_numeric),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_bignumeric", type: "BIGNUMERIC", description: nil, fields: [], precision: precision_bignumeric, scale: scale_bignumeric),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: [], max_length: max_length_bytes),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "creation_date", type: "TIMESTAMP", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "home",          type: "GEOGRAPHY", description: nil, fields: []),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REPEATED", name: "cities_lived",  type: "RECORD", description: nil, fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "place",                type: "STRING",  description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "location",             type: "GEOGRAPHY",  description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "number_of_years",      type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_nested_numeric",    type: "NUMERIC", description: nil, fields: [], precision: precision_numeric, scale: scale_numeric),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_nested_bignumeric", type: "BIGNUMERIC", description: nil, fields: [], precision: precision_bignumeric, scale: scale_bignumeric)
      ])
    ]
  end

  let(:schema_gapi) { Google::Apis::BigqueryV2::TableSchema.new fields: schema_gapi_fields }
  let(:schema_update_options) { ["ALLOW_FIELD_ADDITION", "ALLOW_FIELD_RELAXATION"] }
  let(:range_partitioning) do
    Google::Apis::BigqueryV2::RangePartitioning.new(
      field: "age",
      range: Google::Apis::BigqueryV2::RangePartitioning::Range.new(
        start: 0,
        interval: 10,
        end: 100
      )
    ) 
  end
  let(:time_partitioning) do
    Google::Apis::BigqueryV2::TimePartitioning.new type: "DAY", field: "dob", expiration_ms: 86_400_000, require_partition_filter: true
  end
  let(:clustering_fields) { ["last_name", "first_name"] }
  let(:clustering) do
    Google::Apis::BigqueryV2::Clustering.new fields: clustering_fields
  end
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

  def storage_file path = nil
    gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(load_bucket.name, path).to_json
    Google::Cloud::Storage::File.from_gapi gapi, storage.service
  end

  it "can specify range partitioning and a schema in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    job_gapi.configuration.load.schema_update_options = schema_update_options
    job_gapi.configuration.load.range_partitioning = range_partitioning

    job_resp_gapi = load_job_resp_gapi(table_reference, load_url)
    job_resp_gapi.configuration.load.schema_update_options = schema_update_options
    job_resp_gapi.configuration.load.range_partitioning = range_partitioning

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file, create: :needed do |job|
      job.schema.string "name", mode: :required, max_length: max_length_string
      job.schema.integer "age", policy_tags: policy_tags
      job.schema.float "score", description: "A score from 0.0 to 10.0"
      job.schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      job.schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      job.schema.boolean "active"
      job.schema.bytes "avatar", max_length: max_length_bytes
      job.schema.timestamp "creation_date"
      job.schema.time "duration"
      job.schema.datetime "target_end"
      job.schema.date "birthday"
      job.schema.geography "home"
      job.schema.record "cities_lived", mode: :repeated do |nested_schema|
        nested_schema.string "place"
        nested_schema.geography "location"
        nested_schema.integer "number_of_years"
        nested_schema.numeric "my_nested_numeric", precision: precision_numeric, scale: scale_numeric
        nested_schema.bignumeric "my_nested_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      end
      job.schema_update_options = schema_update_options
      job.range_partitioning_field = "age"
      job.range_partitioning_start = 0
      job.range_partitioning_interval = 10
      job.range_partitioning_end = 100
      expect { job.cancel }.must_raise RuntimeError
      expect { job.rerun! }.must_raise RuntimeError
      expect { job.reload! }.must_raise RuntimeError
      expect { job.refresh! }.must_raise RuntimeError
      expect { job.wait_until_done! }.must_raise RuntimeError
    end

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.schema_update_options).must_equal schema_update_options
    _(job.range_partitioning?).must_equal true
    _(job.range_partitioning_field).must_equal "age"
    _(job.range_partitioning_start).must_equal 0
    _(job.range_partitioning_interval).must_equal 10
    _(job.range_partitioning_end).must_equal 100

    mock.verify
  end

  it "can specify time partitioning and a schema in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    job_gapi.configuration.load.schema_update_options = schema_update_options
    job_gapi.configuration.load.time_partitioning = time_partitioning
    job_gapi.configuration.load.clustering = clustering

    job_resp_gapi = load_job_resp_gapi(table_reference, load_url)
    job_resp_gapi.configuration.load.schema_update_options = schema_update_options
    job_resp_gapi.configuration.load.time_partitioning = time_partitioning
    job_resp_gapi.configuration.load.clustering = clustering

    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file, create: :needed do |job|
      job.schema.string "name", mode: :required, max_length: max_length_string
      job.schema.integer "age", policy_tags: policy_tags
      job.schema.float "score", description: "A score from 0.0 to 10.0"
      job.schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      job.schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      job.schema.boolean "active"
      job.schema.bytes "avatar", max_length: max_length_bytes
      job.schema.timestamp "creation_date"
      job.schema.time "duration"
      job.schema.datetime "target_end"
      job.schema.date "birthday"
      job.schema.geography "home"
      job.schema.record "cities_lived", mode: :repeated do |nested_schema|
        nested_schema.string "place"
        nested_schema.geography "location"
        nested_schema.integer "number_of_years"
        nested_schema.numeric "my_nested_numeric", precision: precision_numeric, scale: scale_numeric
        nested_schema.bignumeric "my_nested_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      end
      job.schema_update_options = schema_update_options
      job.time_partitioning_type = "DAY"
      job.time_partitioning_field = "dob"
      job.time_partitioning_expiration = 86_400
      job.time_partitioning_require_filter = true
      job.clustering_fields = clustering_fields
      expect { job.cancel }.must_raise RuntimeError
      expect { job.rerun! }.must_raise RuntimeError
      expect { job.reload! }.must_raise RuntimeError
      expect { job.refresh! }.must_raise RuntimeError
      expect { job.wait_until_done! }.must_raise RuntimeError
    end

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.schema_update_options).must_equal schema_update_options
    _(job.time_partitioning?).must_equal true
    _(job.time_partitioning_type).must_equal "DAY"
    _(job.time_partitioning_field).must_equal "dob"
    _(job.time_partitioning_expiration).must_equal 86_400
    _(job.time_partitioning_require_filter?).must_equal true
    _(job.clustering?).must_equal true
    _(job.clustering_fields).must_equal clustering_fields

    mock.verify
  end

  it "can specify a schema as an option during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = schema_gapi
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
    schema.timestamp "creation_date"
    schema.time "duration"
    schema.datetime "target_end"
    schema.date "birthday"
    schema.geography "home"
    schema.record "cities_lived", mode: :repeated do |nested_schema|
      nested_schema.string "place"
      nested_schema.geography "location"
      nested_schema.integer "number_of_years"
      nested_schema.numeric "my_nested_numeric", precision: precision_numeric, scale: scale_numeric
      nested_schema.bignumeric "my_nested_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
    end

    job = dataset.load_job table_id, load_file, create: :needed, schema: schema
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.schema_update_options).must_be_kind_of Array
    _(job.schema_update_options).must_be :empty?
    _(job.range_partitioning?).must_equal false
    _(job.range_partitioning_field).must_be_nil
    _(job.range_partitioning_start).must_be_nil
    _(job.range_partitioning_interval).must_be_nil
    _(job.range_partitioning_end).must_be_nil
    _(job.time_partitioning?).must_equal false
    _(job.time_partitioning_type).must_be :nil?
    _(job.time_partitioning_field).must_be :nil?
    _(job.time_partitioning_expiration).must_be :nil?
    _(job.time_partitioning_require_filter?).must_equal false
    _(job.clustering?).must_equal false
    _(job.clustering_fields).must_be :nil?

    mock.verify
  end

  it "can specify a schema both as an option and in a block during load" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_reference, load_url
    job_gapi.configuration.load.schema = schema_gapi
    job_gapi.configuration.load.create_disposition = "CREATE_IF_NEEDED"
    job_gapi.configuration.load.schema_update_options = schema_update_options

    job_resp_gapi = load_job_resp_gapi(table_reference, load_url)
    job_resp_gapi.configuration.load.schema_update_options = schema_update_options
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]
    dataset.service.mocked_service = mock

    schema = bigquery.schema
    schema.string "name", mode: :required
    schema.integer "age"

    job = dataset.load_job table_id, load_file, create: :needed, schema: schema do |schema|
      schema.string "name", mode: :required, max_length: max_length_string
      schema.integer "age", policy_tags: policy_tags
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      schema.boolean "active"
      schema.bytes "avatar", max_length: max_length_bytes
      schema.timestamp "creation_date"
      schema.time "duration"
      schema.datetime "target_end"
      schema.date "birthday"
      schema.geography "home"
      schema.record "cities_lived", mode: :repeated do |nested_schema|
        nested_schema.string "place"
        nested_schema.geography "location"
        nested_schema.integer "number_of_years"
        nested_schema.numeric "my_nested_numeric", precision: precision_numeric, scale: scale_numeric
        nested_schema.bignumeric "my_nested_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      end
      schema.schema_update_options = schema_update_options
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.schema_update_options).must_equal schema_update_options

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
