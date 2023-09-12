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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "dataset_table" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id
    end
    t
  end
  let(:table_with_schema_id) { "dataset_table_with_schema" }
  let(:table_with_schema) do
    t = dataset.table table_with_schema_id
    if t.nil?
      t = dataset.create_table table_with_schema_id do |schema|
        schema.integer   "id",    description: "id description",    mode: :required
        schema.string    "breed", description: "breed description", mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
        schema.numeric "my_numeric", mode: :nullable
        schema.bignumeric "my_bignumeric", mode: :nullable
      end
    end
    t
  end
  let(:table_avro_id) { "dataset_table_avro" }
  let(:table_avro) { dataset.table table_avro_id }

  let(:table_orc_id) { "dataset_table_orc" }
  let(:table_orc) { dataset.table table_orc_id }
  let(:local_orc_file) { "acceptance/data/us-states.orc" }

  let(:table_parquet_id) { "dataset_table_parquet" }
  let(:table_parquet) { dataset.table table_parquet_id }
  let(:local_parquet_file) { "acceptance/data/us-states.parquet" }

  let(:rows) do
    [
      { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
      { name: "ryan",    breed: "golden retriever?", id: 5, dob: Time.now.utc },
      { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
    ]
  end
  let(:invalid_rows) do
    [
        { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
        { name: nil,       breed: "golden retriever?", id: 5, dob: Time.now.utc },
        { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
    ]
  end
  let(:insert_ids) { Array.new(3) {SecureRandom.uuid} }
  let(:view_id) { "dataset_view" }
  let(:view) do
    t = dataset.table view_id
    if t.nil?
      t = dataset.create_view view_id, publicdata_query
    end
    t
  end
  let(:local_file) { "acceptance/data/kitten-test-data.json" }

  let(:schema_update_options) { ["ALLOW_FIELD_ADDITION", "ALLOW_FIELD_RELAXATION"] }
  let(:clustering_fields) { ["breed", "name"] }
  let(:string_numeric) { "0.123456789" }
  let(:string_bignumeric) { "0.12345678901234567890123456789012345678" }
  let(:schema_fields_default) do
    [
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "id", type: "INTEGER", description: "id description"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "breed", type: "STRING", description: "breed description"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name", type: "STRING", description: "name description", default_value_expression: "'name'"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "dob", type: "TIMESTAMP", description: "dob description", default_value_expression: "CURRENT_TIMESTAMP"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age", type: "INTEGER", default_value_expression: "10"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score", type: "FLOAT", description: "A score from 0.0 to 10.0", default_value_expression: "1.0"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "cost", type: "NUMERIC", default_value_expression: "1.0e4"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_bignumeric", type: "BIGNUMERIC", default_value_expression: "1.0e10"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active", type: "BOOLEAN", default_value_expression: "false"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar", type: "BYTES", default_value_expression: "b'101'"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration", type: "TIME", default_value_expression: "CURRENT_TIME"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end", type: "DATETIME", default_value_expression: "CURRENT_DATETIME"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday", type: "DATE", default_value_expression: "CURRENT_DATE"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "home", type: "GEOGRAPHY", default_value_expression: "ST_GEOGPOINT(-122.084801, 37.422131)"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REPEATED", name: "cities_lived", type: "RECORD", default_value_expression: "[STRUCT('place', 10)]", fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "place", type: "STRING"),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "number_of_years", type: "INTEGER")
      ])
    ]
  end

  before do
    table
    view
  end

  it "has the attributes of a dataset" do
    fresh = bigquery.dataset dataset_id
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset

    _(fresh.project_id).must_equal bigquery.project
    _(fresh.dataset_id).must_equal dataset.dataset_id
    _(fresh.etag).wont_be :nil?
    _(fresh.api_url).wont_be :nil?
    _(fresh.created_at).must_be_kind_of Time
    _(fresh.modified_at).must_be_kind_of Time
    _(fresh.dataset_ref).must_be_kind_of Hash
    _(fresh.dataset_ref[:project_id]).must_equal bigquery.project
    _(fresh.dataset_ref[:dataset_id]).must_equal dataset.dataset_id
    # fresh.location.must_equal "US"       TODO why nil? Set in dataset
  end

  describe "#delete" do
    let(:dataset_delete_id) { "#{prefix}_dataset_for_delete" }
    let(:dataset_delete) do
      d = bigquery.dataset dataset_delete_id
      if d.nil?
        d = bigquery.create_dataset dataset_delete_id
      end
      d
    end

    it "deletes itself and knows it no longer exists" do
      _(dataset_delete.exists?).must_equal true
      dataset_delete.tables.all(&:delete)
      _(dataset_delete.delete).must_equal true
      _(dataset_delete.exists?).must_equal false
      _(dataset_delete.exists?(force: true)).must_equal false
    end
  end

  it "should set & get metadata" do
    new_name = "New name"
    new_desc = "New description!"
    new_default_expiration = 12345678
    new_labels = { "bar" => "baz" }

    dataset.name = new_name
    dataset.description = new_desc
    dataset.default_expiration = new_default_expiration
    dataset.labels = new_labels

    fresh = bigquery.dataset dataset.dataset_id
    _(fresh).wont_be :nil?
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(fresh.dataset_id).must_equal dataset.dataset_id
    _(fresh.name).must_equal new_name
    _(fresh.description).must_equal new_desc
    _(fresh.default_expiration).must_equal new_default_expiration
    _(fresh.labels).must_equal new_labels

    dataset.default_expiration = nil
  end

  it "should fail to set metadata with stale etag" do
    fresh = bigquery.dataset dataset.dataset_id
    _(fresh.etag).wont_be :nil?

    stale = bigquery.dataset dataset_id
    _(stale.etag).wont_be :nil?
    _(stale.etag).must_equal fresh.etag

    # Modify on the server, which will change the etag
    fresh.description = "Description 1"
    _(stale.etag).wont_equal fresh.etag
    err = expect { stale.description = "Description 2" }.must_raise Google::Cloud::FailedPreconditionError
    _(err.message).must_equal "failedPrecondition: Precondition check failed."
  end

  it "create dataset returns valid etag equal to get dataset" do
    fresh_dataset_id = "#{prefix}_#{rand 100}_unique"
    fresh = bigquery.create_dataset fresh_dataset_id
    _(fresh.etag).wont_be :nil?

    stale = bigquery.dataset fresh_dataset_id
    _(stale.etag).wont_be :nil?
    _(stale.etag).must_equal fresh.etag
  end

  it "should get a list of tables and views" do
    tables = dataset.tables
    # The code in before ensures we have at least one dataset
    _(tables.count).must_be :>=, 2
    tables.each do |t|
      _(t.table_id).wont_be :nil?
      _(t.created_at).must_be_kind_of Time # Loads full representation
    end
  end

  it "should get all tables and views in pages with token" do
    tables = dataset.tables(max: 1).all
    _(tables.count).must_be :>=, 2
    tables.each do |t|
      _(t.table_id).wont_be :nil?
      _(t.created_at).must_be_kind_of Time # Loads full representation
    end
  end

  it "imports parquet data from GCS uri using hive partitioning with auto layout with load_job" do
    gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
    source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load_job "gcs_hive_table_#{SecureRandom.hex(21)}", gcs_uri, job_id: job_id do |job|
      job.format = :parquet
      job.hive_partitioning_mode = :auto
      job.hive_partitioning_source_uri_prefix = source_uri_prefix
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.output_rows).must_equal 100

    _(job.parquet?).must_equal true
    _(job.hive_partitioning?).must_equal true
    _(job.hive_partitioning_mode).must_equal "AUTO"
    _(job.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix
  end

  it "imports parquet data from GCS uri using hive partitioning with custom layout with load_job" do
    gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/customlayout/*"
    source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/customlayout/"
    source_uri_prefix_with_schema = "#{source_uri_prefix}{pkey:STRING}/"
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load_job "gcs_hive_table_#{SecureRandom.hex(21)}", gcs_uri, job_id: job_id do |job|
      job.format = :parquet
      job.hive_partitioning_mode = :custom
      job.hive_partitioning_source_uri_prefix = source_uri_prefix_with_schema
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.output_rows).must_equal 150

    _(job.parquet?).must_equal true
    _(job.hive_partitioning?).must_equal true
    _(job.hive_partitioning_mode).must_equal "CUSTOM"
    _(job.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix
  end

  it "imports data from a local file and creates a new table with schema and range partitioning in a block with load_job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load_job "local_file_table_#{SecureRandom.hex(21)}", local_file, job_id: job_id do |job|
      job.schema.integer   "id",    description: "id description",    mode: :required
      job.schema.string    "breed", description: "breed description", mode: :required
      job.schema.string    "name",  description: "name description",  mode: :required
      job.schema.timestamp "dob",   description: "dob description",   mode: :required
      job.schema_update_options = schema_update_options
      job.range_partitioning_field = "id"
      job.range_partitioning_start = 0
      job.range_partitioning_interval = 10
      job.range_partitioning_end = 100
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    job.wait_until_done!
    _(job.output_rows).must_equal 3
    _(job.schema_update_options).must_equal schema_update_options
    _(job.range_partitioning?).must_equal true
    _(job.range_partitioning_field).must_equal "id"
    _(job.range_partitioning_start).must_equal 0
    _(job.range_partitioning_interval).must_equal 10
    _(job.range_partitioning_end).must_equal 100
  end

  it "imports data from a local file and creates a new table with schema and time partitioning in a block with load_job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load_job "local_file_table_#{SecureRandom.hex(21)}", local_file, job_id: job_id do |job|
      job.schema.integer   "id",    description: "id description",    mode: :required
      job.schema.string    "breed", description: "breed description", mode: :required
      job.schema.string    "name",  description: "name description",  mode: :required
      job.schema.timestamp "dob",   description: "dob description",   mode: :required
      job.schema_update_options = schema_update_options
      job.time_partitioning_type = "DAY"
      job.time_partitioning_field = "dob"
      job.time_partitioning_expiration = 86_400
      job.time_partitioning_require_filter = true
      job.clustering_fields = clustering_fields
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    job.wait_until_done!
    _(job.output_rows).must_equal 3
    _(job.schema_update_options).must_equal schema_update_options
    _(job.time_partitioning?).must_equal true
    _(job.time_partitioning_type).must_equal "DAY"
    _(job.time_partitioning_field).must_equal "dob"
    _(job.time_partitioning_expiration).must_equal 86_400
    _(job.time_partitioning_require_filter?).must_equal true
    _(job.clustering?).must_equal true
    _(job.clustering_fields).must_equal clustering_fields
  end

  it "imports data from a local file and creates a new table with schema as an option with load_job" do
    schema = bigquery.schema do |s|
      s.integer   "id",    description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required
      s.timestamp "dob",   description: "dob description",   mode: :required
    end

    job = dataset.load_job "local_file_table_2", local_file, schema: schema

    _(job.hive_partitioning?).must_equal false
    _(job.hive_partitioning_mode).must_be_nil
    _(job.hive_partitioning_source_uri_prefix).must_be_nil

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

    job.wait_until_done!
    _(job.output_rows).must_equal 3
  end

  it "imports data from a local file and creates a new table with schema having default values" do
    table_id = "load_job_#{SecureRandom.hex(4)}"
    schema = bigquery.schema do |s|
      s.integer   "id",    description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required, default_value_expression: "'name'"
      s.timestamp "dob",   description: "dob description",   mode: :required, default_value_expression: "CURRENT_TIMESTAMP"
      s.integer "age", default_value_expression: "10"
      s.float "score", description: "A score from 0.0 to 10.0", default_value_expression: "1.0"
      s.numeric "cost", default_value_expression: "1.0e4"
      s.bignumeric "my_bignumeric", default_value_expression: "1.0e10"
      s.boolean "active", default_value_expression: "false"
      s.bytes "avatar", default_value_expression: "b'101'"
      s.time "duration", default_value_expression: "CURRENT_TIME"
      s.datetime "target_end", default_value_expression: "CURRENT_DATETIME"
      s.date "birthday", default_value_expression: "CURRENT_DATE"
      s.geography "home", default_value_expression: "ST_GEOGPOINT(-122.084801, 37.422131)"
      s.record "cities_lived", mode: :repeated, default_value_expression: "[STRUCT('place', 10)]" do |nested_schema|
        nested_schema.string "place"
        nested_schema.integer "number_of_years"
      end
    end

    job = dataset.load_job table_id, local_file, schema: schema
    job.wait_until_done!
    _(job.output_rows).must_equal 3

    table = dataset.table table_id
    _(table.schema.fields.map(&:default_value_expression)).must_be :==, schema_fields_default.map(&:default_value_expression)
  end

  it "creates a new table with schema having default values" do
    table_id = "load_job_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |s|
      s.integer   "id",    description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required, default_value_expression: "'name'"
      s.timestamp "dob",   description: "dob description",   mode: :required, default_value_expression: "CURRENT_TIMESTAMP"
      s.integer "age", default_value_expression: "10"
      s.float "score", description: "A score from 0.0 to 10.0", default_value_expression: "1.0"
      s.numeric "cost", default_value_expression: "1.0e4"
      s.bignumeric "my_bignumeric", default_value_expression: "1.0e10"
      s.boolean "active", default_value_expression: "false"
      s.bytes "avatar", default_value_expression: "b'101'"
      s.time "duration", default_value_expression: "CURRENT_TIME"
      s.datetime "target_end", default_value_expression: "CURRENT_DATETIME"
      s.date "birthday", default_value_expression: "CURRENT_DATE"
      s.geography "home", default_value_expression: "ST_GEOGPOINT(-122.084801, 37.422131)"
      s.record "cities_lived", mode: :repeated, default_value_expression: "[STRUCT('place', 10)]" do |nested_schema|
        nested_schema.string "place"
        nested_schema.integer "number_of_years"
      end
    end

    insert_response = table.insert rows
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    table = dataset.table table_id
    _(table.schema.fields.map(&:default_value_expression)).must_be :==, schema_fields_default.map(&:default_value_expression)
  end

  it "imports data from a local file and creates a new table without a schema with load_job" do
    job = dataset.load_job table_with_schema.table_id, local_file, create: :never
    job.wait_until_done!
    _(job.output_rows).must_equal 3
  end

  it "imports data from a list of files in your bucket with load_job" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    job = dataset.load_job table_with_schema.table_id, [file1, gs_url]
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.input_files).must_equal 2
    _(job.output_rows).must_equal 6
  end

  it "imports data from a local file and creates a new table with specified schema in a block with load" do
    result = dataset.load "local_file_table_3", local_file do |schema|
      schema.integer   "id",    description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    _(result).must_equal true
  end

  it "imports data from a local file and creates a new table with specified schema as an option with load" do
    schema = bigquery.schema do |s|
      s.integer  "id",     description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required
      s.timestamp "dob",   description: "dob description",   mode: :required
    end

    result = dataset.load "local_file_table_4", local_file, schema: schema
    _(result).must_equal true
  end

  it "imports data from a local file and creates a new table without a schema with load" do
    result = dataset.load table_with_schema.table_id, local_file do |job|
      job.create = :never
    end
    _(result).must_equal true
  end

  it "imports data from a list of files in your bucket with load" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    result = dataset.load table_with_schema.table_id, [file1, gs_url]
    _(result).must_equal true
  end

  it "imports data from GCS Avro file and creates a new table with load" do
    result = dataset.load(
      table_avro_id,
      "gs://#{samples_bucket}/bigquery/us-states/us-states.avro")
    _(result).must_equal true
  end

  it "imports data from GCS Avro file and creates a new table with encryption with load" do
    encrypt_config = bigquery.encryption(kms_key: kms_key)
    result = dataset.load(
      table_avro_id,
      "gs://#{samples_bucket}/bigquery/us-states/us-states.avro") do |load|
      load.write = :truncate
      load.encryption = encrypt_config
    end
    _(result).must_equal true
    table_avro.reload!
    _(table_avro.encryption).must_equal encrypt_config
  end

  it "imports data from a local ORC file and creates a new table without a schema with load" do
    result = dataset.load table_orc_id, local_orc_file
    _(result).must_equal true
  end

  it "imports data from GCS ORC file and creates a new table with load" do
    result = dataset.load(
        table_orc_id,
        "gs://#{samples_bucket}/bigquery/us-states/us-states.orc")
    _(result).must_equal true
  end

  it "imports data from a local Parquet file and creates a new table without a schema with load" do
    result = dataset.load table_parquet_id, local_parquet_file
    _(result).must_equal true
  end

  it "imports data from GCS Parquet file and creates a new table with load" do
    result = dataset.load(
        table_parquet_id,
        "gs://#{samples_bucket}/bigquery/us-states/us-states.parquet")
    _(result).must_equal true
  end

  it "inserts rows directly and gets its data" do
    insert_response = dataset.insert table_with_schema.table_id, rows
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    assert_data table_with_schema.data(max: 1)
  end

  it "insert skip invalid rows and return insert errors" do
    insert_response = dataset.insert table_with_schema.table_id, invalid_rows, skip_invalid: true
    _(insert_response).wont_be :success?
    _(insert_response.insert_count).must_equal 2

    _(insert_response.insert_errors).wont_be :empty?
    _(insert_response.insert_errors.count).must_equal 1
    _(insert_response.insert_errors.first.class).must_equal Google::Cloud::Bigquery::InsertResponse::InsertError
    _(insert_response.insert_errors.first.index).must_equal 1

    bigquery_row = invalid_rows[insert_response.insert_errors.first.index]
    _(insert_response.insert_errors.first.row).must_equal bigquery_row

    _(insert_response.error_rows).wont_be :empty?
    _(insert_response.error_rows.count).must_equal 1
    _(insert_response.error_rows.first).must_equal bigquery_row

    _(insert_response.insert_error_for(invalid_rows[1]).index).must_equal insert_response.insert_errors.first.index
    _(insert_response.errors_for(invalid_rows[1])).wont_be :empty?
    _(insert_response.index_for(invalid_rows[1])).must_equal 1
  end

  it "inserts rows with autocreate option" do
    # schema block is not needed in this test since table exists, but provide anyway
    insert_response = dataset.insert table_with_schema.table_id, rows, autocreate: true do |t|
      t.schema.integer   "id",    description: "id description",    mode: :required
      t.schema.string    "breed", description: "breed description", mode: :required
      t.schema.string    "name",  description: "name description",  mode: :required
      t.schema.timestamp "dob",   description: "dob description",   mode: :required
    end

    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    table = dataset.table table_with_schema_id
    _(table).wont_be_nil

    assert_data table.data(max: 1)
  end

  it "inserts rows with insert_ids option" do
    insert_response = dataset.insert table_with_schema.table_id, rows, insert_ids: insert_ids
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    assert_data table_with_schema.data(max: 1)
  end

  it "inserts row with max scale numeric and bignumeric values" do
    rows = [
      {
        name: "cat 7",
        breed: "the cat kind",
        id: 7,
        dob: Time.now.utc,
        my_numeric: BigDecimal(string_numeric),
        my_bignumeric: string_bignumeric # BigDecimal would be rounded, use String instead!
      },
      {
        name: "cat 8",
        breed: "the cat kind",
        id: 8,
        dob: Time.now.utc,
        my_numeric: BigDecimal(string_numeric),
        my_bignumeric: BigDecimal(string_bignumeric) # BigDecimal will be rounded to scale 9.
      }
    ]
    insert_response = dataset.insert table_with_schema.table_id, rows
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 2
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    data = dataset.query "SELECT id, my_numeric, my_bignumeric FROM #{table_with_schema_id} WHERE id IN (7,8) ORDER BY id"
    _(data.count).must_equal 2
    _(data.total).must_equal 2
    _(data[0][:my_numeric]).must_equal BigDecimal(string_numeric)
    _(data[0][:my_bignumeric]).must_equal BigDecimal(string_bignumeric)
    _(data[1][:my_numeric]).must_equal BigDecimal(string_numeric)
    _(data[1][:my_bignumeric]).must_equal BigDecimal(string_numeric) # Rounded to scale 9.
  end

  it "creates missing table while inserts rows with autocreate option" do
    new_table_id = "new_dataset_table_id_#{rand(1000)}"

    insert_response = dataset.insert new_table_id, rows, autocreate: true do |t|
      t.schema.integer   "id",    description: "id description",    mode: :required
      t.schema.string    "breed", description: "breed description", mode: :required
      t.schema.string    "name",  description: "name description",  mode: :required
      t.schema.timestamp "dob",   description: "dob description",   mode: :required
    end

    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    table = dataset.table new_table_id
    _(table).wont_be_nil

    assert_data table.data(max: 1)
  end

  it "queries in session mode" do
    job = dataset.query_job "CREATE TEMPORARY TABLE temptable AS SELECT 17 as foo", create_session: true
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.session_id).wont_be :nil?

    job_2 = dataset.query_job "SELECT * FROM temptable", session_id: job.session_id
    job_2.wait_until_done!
    _(job_2).wont_be :failed?
    _(job_2.session_id).wont_be :nil?
    _(job_2.session_id).must_equal job.session_id
    _(job_2.data.first).wont_be :nil?
    _(job_2.data.first[:foo]).must_equal 17

    data = dataset.query "SELECT * FROM temptable", session_id: job.session_id
    _(data.first).wont_be :nil?
    _(data.first[:foo]).must_equal 17
  end

  it "imports data from a local file with session enabled" do
    temp_dataset = bigquery.dataset "_SESSION", skip_lookup: true

    job = temp_dataset.load_job "temp_table", local_file, autodetect: true, create_session: true

    job.wait_until_done!
    _(job.output_rows).must_equal 3

    session_id = job.statistics["sessionInfo"]["sessionId"]

    temp_dataset.load "temp_table", local_file, autodetect: true, session_id: session_id
    data = bigquery.query "SELECT * FROM _SESSION.temp_table;", session_id: session_id
    _(data.count).must_equal 6
  end
end
