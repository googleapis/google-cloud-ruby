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

describe Google::Cloud::Bigquery::Table, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "kittens_table" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer   "id",    description: "id description",    mode: :required
        schema.string    "breed", description: "breed description", mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
      end
    end
    t
  end
  let(:schema_fields_default) do
    [
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "id", type: "INTEGER", description: "id description"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "breed", type: "STRING", description: "breed description"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name", type: "STRING", description: "name description", default_value_expression: "'name'"),
      Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "dob", type: "TIMESTAMP", description: "dob description", default_value_expression: "CURRENT_TIMESTAMP"),
    ]
  end
  let(:time_partitioned_table_id) { "daily_kittens"}
  let(:seven_days) { 7 * 24 * 60 * 60 }
  let(:clustering_fields) { ["last_name", "first_name"] }
  let(:time_partitioned_table) do
    t = dataset.table time_partitioned_table_id
    if t.nil?
      t = dataset.create_table time_partitioned_table_id do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_field = "dob"
        updater.time_partitioning_expiration = seven_days
        updater.clustering_fields = clustering_fields
        updater.schema do |schema|
          schema.timestamp "dob",   description: "dob description",   mode: :required
          schema.string "first_name",   description: "first_name description",   mode: :required
          schema.string "last_name",   description: "last_name description",   mode: :required
        end
      end
    end
    t
  end
  let(:range_partitioned_table_id) { "range_kittens"}
  let(:range_partitioned_table) do
    t = dataset.table range_partitioned_table_id
    if t.nil?
      t = dataset.create_table range_partitioned_table_id do |updater|
        updater.range_partitioning_field = "my_table_id"
        updater.range_partitioning_start = 0
        updater.range_partitioning_interval = 10
        updater.range_partitioning_end = 100
        updater.clustering_fields = clustering_fields
        updater.schema do |schema|
          schema.integer "my_table_id",   description: "id description",   mode: :required
          schema.string "first_name",   description: "first_name description",   mode: :required
          schema.string "last_name",   description: "last_name description",   mode: :required
        end
      end
    end
    t
  end
  let(:query) { "SELECT id, breed, name, dob FROM #{table.query_id}" }
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
  let(:local_file) { "acceptance/data/kitten-test-data.json" }
  let(:target_table_id) { "kittens_copy" }
  let(:target_table_2_id) { "kittens_copy_2" }
  let(:target_table_3_id) { "kittens_copy_3" }
  let(:target_table_4_id) { "kittens_copy_4" }
  let(:target_snapshot_table) { "kittens_copy_5" }
  let(:target_clone_table) { "kittens_copy_6" }
  let(:labels) { { "foo" => "bar" } }

  it "has the attributes of a table" do
    fresh = dataset.table table.table_id
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Table

    _(fresh.project_id).must_equal bigquery.project
    _(fresh.id).must_equal "#{bigquery.project}:#{dataset.dataset_id}.#{table.table_id}"
    _(fresh.query_id).must_equal "`#{bigquery.project}.#{dataset.dataset_id}.#{table.table_id}`"
    _(fresh.etag).wont_be :nil?
    _(fresh.api_url).wont_be :nil?
    _(fresh.bytes_count).wont_be :nil?
    _(fresh.rows_count).wont_be :nil?
    _(fresh.created_at).must_be_kind_of Time
    _(fresh.expires_at).must_be :nil?
    _(fresh.modified_at).must_be_kind_of Time
    _(fresh.table?).must_equal true
    _(fresh.view?).must_equal false
    _(fresh.time_partitioning?).must_equal false
    _(fresh.time_partitioning_type).must_be_nil
    _(fresh.time_partitioning_field).must_be_nil
    _(fresh.time_partitioning_expiration).must_be_nil
    _(fresh.range_partitioning?).must_equal false
    _(fresh.range_partitioning_field).must_be_nil
    _(fresh.range_partitioning_start).must_be_nil
    _(fresh.range_partitioning_interval).must_be_nil
    _(fresh.range_partitioning_end).must_be_nil
    #fresh.location.must_equal "US"       TODO why nil? Set in dataset

    # streaming buffer is transient, it seems it may or may not be present?
    _(fresh.buffer_bytes).must_be_kind_of Integer if fresh.buffer_bytes
    _(fresh.buffer_rows).must_be_kind_of Integer if fresh.buffer_rows
    _(fresh.buffer_oldest_at).must_be_kind_of Time if fresh.buffer_oldest_at

    _(fresh.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(fresh.schema).wont_be :empty?
    [:id, :breed, :name, :dob].each { |k| _(fresh.headers).must_include k }

    fields = fresh.schema.fields
    fields.each do |f|
      _(f.name).wont_be :nil?
      _(f.type).wont_be :nil?
      _(f.description).wont_be :nil?
      _(f.mode).wont_be :nil?
      f.name = f.name
      f.type = f.type
      f.description = f.description
      f.mode = f.mode
    end
  end

  it "deletes itself and knows it no longer exists" do
    test_table = dataset.create_table "kittens_delete_table"
    _(test_table.exists?).must_equal true
    _(test_table.delete).must_equal true
    _(test_table.exists?).must_equal false
    _(test_table.exists?(force: true)).must_equal false
  end

  it "gets and sets metadata" do
    new_name = "New name"
    new_desc = "New description!"
    new_labels = { "bar" => "baz" }

    table.name = new_name
    table.description = new_desc
    table.labels = new_labels

    table.reload!
    _(table.table_id).must_equal table_id
    _(table.name).must_equal new_name
    _(table.description).must_equal new_desc
    _(table.labels).must_equal new_labels
  end

  it "loads and reloads table with partial projection of table metadata" do
    %w[unspecified basic storage full].each do |view|
      table = dataset.table table_id, view: view
      _(table.table_id).must_equal table_id
      verify_table_metadata table, view

      rand_str = SecureRandom.urlsafe_base64(4)
      new_name = "New_name_#{rand_str}"
      new_desc = "New_description_#{rand_str}"

      table.name = new_name
      table.description = new_desc

      table.reload!
      _(table.table_id).must_equal table_id
      _(table.name).must_equal new_name
      _(table.description).must_equal new_desc
      verify_table_metadata table, view
    end
  end

  it "should fail to set metadata with stale etag" do
    fresh = dataset.table table.table_id
    _(fresh.etag).wont_be :nil?

    stale = dataset.table table_id
    _(stale.etag).wont_be :nil?
    _(stale.etag).must_equal fresh.etag

    # Modify on the server, which will change the etag
    fresh.description = "Description 1"
    _(stale.etag).wont_equal fresh.etag
    err = expect { stale.description = "Description 2" }.must_raise Google::Cloud::FailedPreconditionError
    _(err.message).must_equal "failedPrecondition: Precondition check failed."
  end

  it "create table returns valid etag equal to get table" do
    fresh_table_id = "#{rand 100}_kittens"
    fresh = dataset.create_table fresh_table_id do |schema|
      schema.integer   "id",    description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    _(fresh.etag).wont_be :nil?

    stale = dataset.table fresh_table_id
    _(stale.etag).wont_be :nil?
    _(stale.etag).must_equal fresh.etag
  end

  it "create table with cmek sets encryption" do
    begin
      encrypt_config = bigquery.encryption(kms_key: kms_key)
      cmek_table = dataset.create_table "cmek_kittens" do |updater|
        updater.encryption = encrypt_config
      end

      cmek_table.reload!
      _(cmek_table.table_id).must_equal "cmek_kittens"
      _(cmek_table.encryption).must_equal encrypt_config

      new_encrypt_config = bigquery.encryption(kms_key: kms_key_2)
      cmek_table.encryption = new_encrypt_config

      cmek_table.reload!
      _(cmek_table.encryption).must_equal new_encrypt_config

    ensure
      t2 = dataset.table "cmek_kittens"
      t2.delete if t2
    end
  end

  it "creates a table, loading the schema from a File" do
    begin
      schema_kittens_table = dataset.create_table "schema_kittens" do |t|
        t.schema.load File.open("acceptance/data/schema.json")
      end

      _(schema_kittens_table.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
      _(schema_kittens_table.schema).wont_be :empty?
      %i[id breed name dob features].each do |k|
        _(schema_kittens_table.headers).must_include k
      end

      fields = schema_kittens_table.schema.fields
      fields.each do |f|
        _(f.name).wont_be :nil?
        _(f.type).wont_be :nil?
        _(f.description).wont_be :nil?
        _(f.mode).wont_be :nil?

        next unless f.name == "features"
        _(f.fields).wont_be :empty?
        f.fields.each do |c|
          _(c.name).wont_be :nil?
          _(c.type).wont_be :nil?
          _(c.description).wont_be :nil?
          _(c.mode).wont_be :nil?
        end
      end
    ensure
      t2 = dataset.table "schema_kittens"
      t2.delete if t2
    end
  end

  it "creates a table, loading the schema from a JSON string" do
    begin
      schema_kittens_table = dataset.create_table "schema_kittens" do |t|
        json = File.read("acceptance/data/schema.json")
        t.schema.load json
      end

      _(schema_kittens_table.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
      _(schema_kittens_table.schema).wont_be :empty?
      %i[id breed name dob features].each do |k|
        _(schema_kittens_table.headers).must_include k
      end

      fields = schema_kittens_table.schema.fields
      fields.each do |f|
        _(f.name).wont_be :nil?
        _(f.type).wont_be :nil?
        _(f.description).wont_be :nil?
        _(f.mode).wont_be :nil?

        next unless f.name == "features"
        _(f.fields).wont_be :empty?
        f.fields.each do |c|
          _(c.name).wont_be :nil?
          _(c.type).wont_be :nil?
          _(c.description).wont_be :nil?
          _(c.mode).wont_be :nil?
        end
      end
    ensure
      t2 = dataset.table "schema_kittens"
      t2.delete if t2
    end
  end

  it "creates a table, loading the schema from an Array of Hashes" do
    begin
      schema_kittens_table = dataset.create_table "schema_kittens" do |t|
        json = JSON.parse(File.read("acceptance/data/schema.json"))
        t.schema.load json
      end

      _(schema_kittens_table.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
      _(schema_kittens_table.schema).wont_be :empty?
      %i[id breed name dob features].each do |k|
        _(schema_kittens_table.headers).must_include k
      end

      fields = schema_kittens_table.schema.fields
      fields.each do |f|
        _(f.name).wont_be :nil?
        _(f.type).wont_be :nil?
        _(f.description).wont_be :nil?
        _(f.mode).wont_be :nil?

        next unless f.name == "features"
        _(f.fields).wont_be :empty?
        f.fields.each do |c|
          _(c.name).wont_be :nil?
          _(c.type).wont_be :nil?
          _(c.description).wont_be :nil?
          _(c.mode).wont_be :nil?
        end
      end
    ensure
      t2 = dataset.table "schema_kittens"
      t2.delete if t2
    end
  end

  it "writes the schema of a table to a File" do
    begin
      file = Tempfile.new("schema-test")
      table.schema.dump file
      file.close

      json = JSON.parse(File.read(file.path))
      _(json.length).must_equal 4

      json.each do |f|
        _(f["name"]).wont_be :nil?
        _(f["type"]).wont_be :nil?
        _(f["description"]).wont_be :nil?
        _(f["mode"]).wont_be :nil?
      end
    ensure
      if file
        file.close
        file.delete
      end
    end
  end

  it "writes the schema of a table to a filename" do
    begin
      file = Tempfile.new("schema-test")
      file.close
      table.schema.dump file.path

      json = JSON.parse(File.read(file.path))
      _(json.length).must_equal 4

      json.each do |f|
        _(f["name"]).wont_be :nil?
        _(f["type"]).wont_be :nil?
        _(f["description"]).wont_be :nil?
        _(f["mode"]).wont_be :nil?
      end
    ensure
      if file
        file.close
        file.delete
      end
    end
  end

  it "updates time partitioning expiration" do
    partitioned_table = dataset.table "kittens_field_reference"
    if partitioned_table.nil?
      partitioned_table = dataset.create_table "kittens_field_reference" do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_field = "dob"
        updater.time_partitioning_expiration = seven_days
        updater.schema do |schema|
          schema.timestamp "dob",   description: "dob description",   mode: :required
        end
      end
    end

    partitioned_table.time_partitioning_expiration = 1

    partitioned_table.reload!
    _(partitioned_table.table_id).must_equal "kittens_field_reference"
    _(partitioned_table.time_partitioning_type).must_equal "DAY"
    _(partitioned_table.time_partitioning_field).must_equal "dob"
    _(partitioned_table.time_partitioning_expiration).must_equal 1
  end

  it "updates its schema" do
    begin
      t = dataset.create_table "table_schema_test"
      t.schema do |s|
        s.boolean "available", description: "available description", mode: :nullable
      end
      _(t.headers).must_equal [:available]
      t.schema replace: true do |s|
        s.boolean "available", description: "available description", mode: :nullable
        s.record "countries_lived", description: "countries_lived description", mode: :repeated do |nested|
          nested.float "rating", description: "An value from 1 to 10", mode: :nullable
        end
      end
      _(t.headers).must_equal [:available, :countries_lived]
    ensure
      t2 = dataset.table "table_schema_test"
      t2.delete if t2
    end
  end

  it "updates its schema, loading from a File" do
    begin
      t = dataset.create_table "table_schema_test"
      t.schema do |s|
        s.integer "id", description: "id description", mode: :required
        s.string "breed", description: "breed description", mode: :required
        s.string "name", description: "name description", mode: :required
        s.record "features", description: "features description", mode: :repeated do |s2|
          s2.string "feature", description: "feature description", mode: :required
        end
      end
      _(t.headers).must_equal %i[id breed name features]

      t.schema do |s|
        s.load File.open("acceptance/data/schema.json")
      end

      _(t.schema).wont_be :empty?
      _(t.headers).must_equal %i[id breed name features dob]
    ensure
      t2 = dataset.table "table_schema_test"
      t2.delete if t2
    end
  end

  it "migrates the schema without dropping data when loading an updated schema from a file" do
    begin
      t = dataset.create_table "table_schema_test"
      t.schema do |s|
        s.integer "id", description: "id description", mode: :required
        s.string "breed", description: "breed description", mode: :required
        s.string "name", description: "name description", mode: :required
        s.record "features", description: "features description", mode: :repeated do |s2|
          s2.string "feature", description: "feature description", mode: :required
        end
      end

      row = {
          "id" => 1,
          "breed" => "thecatkind",
          "name" => "mike",
          "features" => [
              {
                  "feature" => "Long Hair",
              }
          ]
      }
      t.insert row

      t.schema do |s|
        s.load File.open("acceptance/data/schema.json")
      end

      data = t.data
      _(data.count).must_equal 1
      _(data.first[:id]).must_equal 1
      _(data.first[:breed]).must_equal "thecatkind"
      _(data.first[:name]).must_equal "mike"
      _(data.first[:dob]).must_be_nil
      _(data.first[:features].count).must_equal 1
      _(data.first[:features].first[:feature]).must_equal "Long Hair"
    ensure
      t2 = dataset.table "table_schema_test"
      t2.delete if t2
    end
  end

  it "allows tables to be created and updated with time_partitioning and clustering" do
    begin
      tp_table = time_partitioned_table
      _(tp_table.time_partitioning?).must_equal true
      _(tp_table.time_partitioning_type).must_equal "DAY"
      _(tp_table.time_partitioning_field).must_equal "dob"
      _(tp_table.time_partitioning_expiration).must_equal seven_days
      _(tp_table.clustering_fields).must_equal clustering_fields

      new_clustering_fields = ["last_name"]
      tp_table.clustering_fields = new_clustering_fields
      _(tp_table.clustering_fields).must_equal new_clustering_fields

      tp_table.clustering_fields = nil
      _(table.clustering_fields).must_be :nil?
    ensure
      time_partitioned_table.delete
    end
  end

  it "allows tables to be created with range_partitioning" do
    rp_table = range_partitioned_table
    _(rp_table.range_partitioning?).must_equal true
    _(rp_table.range_partitioning_field).must_equal "my_table_id"
    _(rp_table.range_partitioning_start).must_equal 0
    _(rp_table.range_partitioning_interval).must_equal 10
    _(rp_table.range_partitioning_end).must_equal 100
  end

  it "inserts rows directly and gets its data" do
    # data = table.data
    insert_response = table.insert rows
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id
    _(query_job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(query_job.job_id).must_equal job_id
    query_job.wait_until_done!

    # Job methods
    _(query_job.done?).must_equal true
    _(query_job.running?).must_equal false
    _(query_job.pending?).must_equal false
    _(query_job.created_at).must_be_kind_of Time
    _(query_job.started_at).must_be_kind_of Time
    _(query_job.ended_at).must_be_kind_of Time
    _(query_job.configuration).wont_be :nil?
    _(query_job.statistics).wont_be :nil?
    _(query_job.status).wont_be :nil?
    _(query_job.errors).must_be :empty?
    query_job.rerun!
    query_job.wait_until_done!

    _(query_job.batch?).must_equal false
    _(query_job.interactive?).must_equal true
    _(query_job.large_results?).must_equal false
    _(query_job.cache?).must_equal true
    _(query_job.flatten?).must_equal true
    _(query_job.bytes_processed).wont_be :nil?
    _(query_job.destination).wont_be :nil?
    _(query_job.data.class).must_equal Google::Cloud::Bigquery::Data
    _(query_job.data.total).wont_be :nil?

    # Query Job - Statistics Query Plan
    _(query_job.query_plan).wont_be_nil
    _(query_job.query_plan).must_be_kind_of Array
    _(query_job.query_plan).wont_be :empty?
    stage = query_job.query_plan.first
    _(stage).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Stage
    _(stage.compute_ratio_avg).must_be_kind_of Numeric
    _(stage.compute_ratio_max).must_be_kind_of Numeric
    _(stage.id).must_be_kind_of Integer
    _(stage.name).must_be_kind_of String
    _(stage.read_ratio_avg).must_be_kind_of Numeric
    _(stage.read_ratio_max).must_be_kind_of Numeric
    _(stage.records_read).must_be_kind_of Integer
    _(stage.records_written).must_be_kind_of Integer
    _(stage.status).must_be_kind_of String
    _(stage.wait_ratio_avg).must_be_kind_of Numeric
    _(stage.wait_ratio_max).must_be_kind_of Numeric
    _(stage.write_ratio_avg).must_be_kind_of Numeric
    _(stage.write_ratio_max).must_be_kind_of Numeric
    _(stage.steps).wont_be_nil
    _(stage.steps).must_be_kind_of Array
    _(stage.steps).wont_be :empty?
    step = stage.steps.first
    _(step).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Step
    _(step.kind).must_be_kind_of String
    _(step.substeps).wont_be_nil
    _(step.substeps).must_be_kind_of Array
    _(step.substeps).wont_be :empty?

    assert_data table.data(max: 1)

    data = dataset.query query
    assert_data data
    _(data.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(data.fields.count).must_equal 4
    [:id, :breed, :name, :dob].each { |k| _(data.headers).must_include k }
    data.all.each do |row|
      _(row).must_be_kind_of Hash
    end
    _(data.next).must_be :nil?
  end

  it "insert skip invalid rows and return insert errors" do
    # data = table.data
    insert_response = table.insert invalid_rows, skip_invalid: true
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

  it "inserts rows with insert_ids option" do
    insert_response = table.insert rows, insert_ids: insert_ids
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    assert_data table.data(max: 1)
  end

  it "inserts rows asynchronously and gets its data" do
    # data = table.data
    insert_result = nil

    inserter = table.insert_async do |result|
      insert_result = result
    end
    inserter.insert rows

    inserter.flush
    inserter.stop.wait!

    _(insert_result).must_be_kind_of Google::Cloud::Bigquery::Table::AsyncInserter::Result
    _(insert_result).must_be :success?
    _(insert_result.insert_count).must_equal 3
    _(insert_result.insert_errors).must_be :empty?
    _(insert_result.error_rows).must_be :empty?

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id
    _(query_job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(query_job.job_id).must_equal job_id
    query_job.wait_until_done!

    # Job methods
    _(query_job.done?).must_equal true
    _(query_job.running?).must_equal false
    _(query_job.pending?).must_equal false
    _(query_job.created_at).must_be_kind_of Time
    _(query_job.started_at).must_be_kind_of Time
    _(query_job.ended_at).must_be_kind_of Time
    _(query_job.configuration).wont_be :nil?
    _(query_job.statistics).wont_be :nil?
    _(query_job.status).wont_be :nil?
    _(query_job.errors).must_be :empty?
    query_job.rerun!
    query_job.wait_until_done!

    _(query_job.batch?).must_equal false
    _(query_job.interactive?).must_equal true
    _(query_job.large_results?).must_equal false
    _(query_job.cache?).must_equal true
    _(query_job.flatten?).must_equal true
    _(query_job.bytes_processed).wont_be :nil?
    _(query_job.destination).wont_be :nil?
    _(query_job.data.class).must_equal Google::Cloud::Bigquery::Data
    _(query_job.data.total).wont_be :nil?

    # Query Job - Statistics Query Plan
    _(query_job.query_plan).wont_be_nil
    _(query_job.query_plan).must_be_kind_of Array
    _(query_job.query_plan).wont_be :empty?
    stage = query_job.query_plan.first
    _(stage).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Stage
    _(stage.compute_ratio_avg).must_be_kind_of Numeric
    _(stage.compute_ratio_max).must_be_kind_of Numeric
    _(stage.id).must_be_kind_of Integer
    _(stage.name).must_be_kind_of String
    _(stage.read_ratio_avg).must_be_kind_of Numeric
    _(stage.read_ratio_max).must_be_kind_of Numeric
    _(stage.records_read).must_be_kind_of Integer
    _(stage.records_written).must_be_kind_of Integer
    _(stage.status).must_be_kind_of String
    _(stage.wait_ratio_avg).must_be_kind_of Numeric
    _(stage.wait_ratio_max).must_be_kind_of Numeric
    _(stage.write_ratio_avg).must_be_kind_of Numeric
    _(stage.write_ratio_max).must_be_kind_of Numeric
    _(stage.steps).wont_be_nil
    _(stage.steps).must_be_kind_of Array
    _(stage.steps).wont_be :empty?
    step = stage.steps.first
    _(step).must_be_kind_of Google::Cloud::Bigquery::QueryJob::Step
    _(step.kind).must_be_kind_of String
    _(step.substeps).wont_be_nil
    _(step.substeps).must_be_kind_of Array
    _(step.substeps).wont_be :empty?

    assert_data table.data(max: 1)

    data = dataset.query query
    assert_data data
    _(data.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(data.fields.count).must_equal 4
    [:id, :breed, :name, :dob].each { |k| _(data.headers).must_include k }
    data.all.each do |row|
      _(row).must_be_kind_of Hash
    end
    _(data.next).must_be :nil?
  end

  it "inserts and query the data with partial projection of destination table metadata" do
    inserter = table.insert_async
    inserter.insert rows
    inserter.flush
    inserter.stop.wait!

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id
    query_job.wait_until_done!

    %w[unspecified basic storage full].each do |view|
      destination_table = query_job.destination view: view
      verify_table_metadata destination_table, view
    end

  end

  it "inserts rows asynchronously with insert_ids option" do
    insert_result = nil

    inserter = table.insert_async do |result|
      insert_result = result
    end
    inserter.insert rows, insert_ids: insert_ids

    inserter.flush
    inserter.stop.wait!

    _(insert_result).must_be_kind_of Google::Cloud::Bigquery::Table::AsyncInserter::Result
    _(insert_result).must_be :success?
    _(insert_result.insert_count).must_equal 3
    _(insert_result.insert_errors).must_be :empty?
    _(insert_result.error_rows).must_be :empty?

    assert_data table.data(max: 1)
  end

  it "imports data from a local file with load_job block updater" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = table.load_job local_file, job_id: job_id do |j|
      j.labels = labels
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    _(job.labels).must_equal labels
    _(job).wont_be :autodetect?
    _(job.null_marker).must_equal ""

    _(job.hive_partitioning?).must_equal false
    _(job.hive_partitioning_mode).must_be_nil
    _(job.hive_partitioning_source_uri_prefix).must_be_nil

    _(job.parquet_options?).must_equal false
    _(job.parquet_enable_list_inference?).must_be_nil
    _(job.parquet_enum_as_string?).must_be_nil

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

  it "imports data from a local file with session enabled" do
    dataset = bigquery.dataset "_SESSION", skip_lookup: true
    temp_table = dataset.table "temp_table", skip_lookup: true 
  

    job = temp_table.load_job local_file, autodetect: true, create_session: true

    job.wait_until_done!
    _(job.output_rows).must_equal 3

    session_id = job.statistics["sessionInfo"]["sessionId"]

    temp_table.load local_file, autodetect: true, session_id: session_id
    data = bigquery.query "SELECT * FROM _SESSION.temp_table;", session_id: session_id
    _(data.count).must_equal 6
  end

  it "imports data from a file in your bucket with load_job" do
    file = bucket.create_file local_file, random_file_destination_name

    job = table.load_job file
    job.wait_until_done!
    _(job).wont_be :failed?
  end

  it "imports data from a list of files in your bucket with load_job" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    job = table.load_job [file1, gs_url]
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.input_files).must_equal 2
    _(job.output_rows).must_equal 6
  end

  it "imports data from a local file with load" do
    result = table.load local_file
    _(result).must_equal true
  end

  it "imports data from a file in your bucket with load" do
    file = bucket.create_file local_file, random_file_destination_name

    result = table.load file
    _(result).must_equal true
  end

  it "imports data from a list of files in your bucket with load" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    result = safe_gcs_execute { table.load [file1, gs_url] }
    _(result).must_equal true
  end

  it "copies itself to another table with copy_job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    copy_job = table.copy_job target_table_id, create: :needed, write: :empty, job_id: job_id, labels: labels

    _(copy_job).must_be_kind_of Google::Cloud::Bigquery::CopyJob
    _(copy_job.job_id).must_equal job_id
    _(copy_job.labels).must_equal labels
    copy_job.wait_until_done!

    _(copy_job).wont_be :failed?
    _(copy_job.source.table_id).must_equal table.table_id
    _(copy_job.destination.table_id).must_equal target_table_id
    _(copy_job.create_if_needed?).must_equal true
    _(copy_job.create_never?).must_equal false
    _(copy_job.write_truncate?).must_equal false
    _(copy_job.write_append?).must_equal false
    _(copy_job.write_empty?).must_equal true
  end

  it "copies itself and fetches partial projection of affected table's metadata" do
    destination_table_id = target_table_id + SecureRandom.urlsafe_base64(4)
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    copy_job = table.copy_job destination_table_id, create: :needed, write: :empty, job_id: job_id, labels: labels

    _(copy_job).must_be_kind_of Google::Cloud::Bigquery::CopyJob
    _(copy_job.job_id).must_equal job_id
    _(copy_job.labels).must_equal labels
    copy_job.wait_until_done!

    _(copy_job).wont_be :failed?
    _(copy_job.create_if_needed?).must_equal true
    _(copy_job.create_never?).must_equal false
    _(copy_job.write_truncate?).must_equal false
    _(copy_job.write_append?).must_equal false
    _(copy_job.write_empty?).must_equal true

    %w[unspecified basic storage full].each do |view|
      source_table = copy_job.source view: view
      _(source_table.table_id).must_equal table.table_id
      verify_table_metadata source_table, view
      destination_table = copy_job.destination view: view
      _(destination_table.table_id).must_equal destination_table_id
      verify_table_metadata destination_table, view
    end
  end

  it "copies itself to another table with copy_job block updater" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    copy_job = table.copy_job target_table_2_id, job_id: job_id do |j|
      j.create = :needed
      j.write = :empty
      j.labels = labels
    end

    _(copy_job).must_be_kind_of Google::Cloud::Bigquery::CopyJob
    _(copy_job.job_id).must_equal job_id
    _(copy_job.labels).must_equal labels
    copy_job.wait_until_done!

    _(copy_job).wont_be :failed?
    _(copy_job.source.table_id).must_equal table.table_id
    _(copy_job.destination.table_id).must_equal target_table_2_id
    _(copy_job.create_if_needed?).must_equal true
    _(copy_job.create_never?).must_equal false
    _(copy_job.write_truncate?).must_equal false
    _(copy_job.write_append?).must_equal false
    _(copy_job.write_empty?).must_equal true
  end

  it "copies itself to another table with copy" do
    result = table.copy target_table_3_id, create: :needed, write: :empty
    _(result).must_equal true
  end

  it "copies itself to another table with copy with encryption" do
    encrypt_config = bigquery.encryption(kms_key: kms_key)
    result = table.copy target_table_4_id, create: :needed,
                                           write: :truncate do |copy|
      copy.encryption = encrypt_config
    end
    _(result).must_equal true

    cmek_table = dataset.table target_table_4_id
    _(cmek_table.encryption).must_equal encrypt_config
  end

  it "creates and cancels jobs" do
    load_job = table.load_job local_file

    _(load_job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(load_job).wont_be :done?

    load_job.cancel
    load_job.wait_until_done!

    _(load_job).must_be :done?

    _(load_job).wont_be :failed?
  end

  it "extracts data to a url in your bucket with extract_job" do
    # Make sure there is data to extract...
    load_job = table.load_job local_file

    _(load_job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    load_job.wait_until_done!

    _(load_job).wont_be :failed?
    _(load_job.destination.table_id).must_equal table.table_id
    _(load_job.delimiter).must_equal ","
    _(load_job.skip_leading_rows).must_equal 0
    _(load_job.utf8?).must_equal true
    _(load_job.iso8859_1?).must_equal false
    _(load_job.quote).must_equal "\""
    _(load_job.max_bad_records).must_equal 0
    _(load_job.quoted_newlines?).must_equal false
    _(load_job.json?).must_equal true
    _(load_job.csv?).must_equal false
    _(load_job.backup?).must_equal false
    _(load_job.allow_jagged_rows?).must_equal false
    _(load_job.ignore_unknown_values?).must_equal false
    _(load_job.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(load_job.schema).wont_be :empty?
    _(load_job.schema_update_options).must_be_kind_of Array
    _(load_job.schema_update_options).must_be :empty?
    _(load_job.range_partitioning?).must_equal false
    _(load_job.range_partitioning_field).must_be_nil
    _(load_job.range_partitioning_start).must_be_nil
    _(load_job.range_partitioning_interval).must_be_nil
    _(load_job.range_partitioning_end).must_be_nil
    _(load_job.time_partitioning?).must_equal false
    _(load_job.time_partitioning_type).must_be :nil?
    _(load_job.time_partitioning_field).must_be :nil?
    _(load_job.time_partitioning_expiration).must_be :nil?
    _(load_job.time_partitioning_require_filter?).must_equal false
    _(load_job.clustering?).must_equal false
    _(load_job.clustering_fields).must_be :nil?
    _(load_job.input_files).must_equal 1
    _(load_job.input_file_bytes).must_be :>, 0
    _(load_job.output_rows).must_be :>, 0
    _(load_job.output_bytes).must_be :>, 0

    Tempfile.open "empty_extract_file.json" do |tmp|
      dest_file_name = random_file_destination_name
      extract_url = "gs://#{bucket.name}/#{dest_file_name}"
      extract_job = safe_gcs_execute do
                      table.extract_job extract_url do |j|
                        j.labels = labels
                      end
                    end

      _(extract_job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
      _(extract_job.labels).must_equal labels
      extract_job.wait_until_done!

      _(extract_job).wont_be :failed?
      _(extract_job.source.table_id).must_equal table.table_id
      _(extract_job.compression?).must_equal false
      _(extract_job.json?).must_equal true
      _(extract_job.csv?).must_equal false
      _(extract_job.delimiter).must_equal ","
      _(extract_job.print_header?).must_equal true
      _(extract_job.destinations_file_counts).wont_be :empty?
      _(extract_job.destinations_counts).wont_be :empty?

      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end

  it "load jobs test with partial projection of table metadata" do
    load_job = table.load_job local_file
    load_job.wait_until_done!

    %w[unspecified basic storage full].each do |view|
      destination_table = load_job.destination view: view
      _(destination_table.table_id).must_equal table.table_id
      verify_table_metadata destination_table, view
    end
  end

  it "extract jobs test with partial projection of table metadata" do
    Tempfile.open "empty_extract_file.json" do |tmp|
      dest_file_name = random_file_destination_name
      extract_url = "gs://#{bucket.name}/#{dest_file_name}"
      extract_job = table.extract_job extract_url do |j|
        j.labels = labels
      end

      _(extract_job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
      _(extract_job.labels).must_equal labels
      extract_job.wait_until_done!

      %w[unspecified basic storage full].each do |view|
        source_table = extract_job.source view: view
        _(source_table.table_id).must_equal table.table_id
        verify_table_metadata source_table, view
      end
    end
  end

  it "extracts data to a file in your bucket with extract_job" do
    # Make sure there is data to extract...
    load_job = table.load_job local_file
    load_job.wait_until_done!
    Tempfile.open "empty_extract_file.json" do |tmp|
      _(tmp.size).must_equal 0
      dest_file_name = random_file_destination_name
      extract_file = bucket.create_file tmp, dest_file_name
      job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated

      extract_job = safe_gcs_execute do 
                      table.extract_job extract_file, job_id: job_id
                    end
      _(extract_job.job_id).must_equal job_id
      extract_job.wait_until_done!
      _(extract_job).wont_be :failed?
      # Refresh to get the latest file data
      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end

  it "extracts data to a url in your bucket with extract" do
    # Make sure there is data to extract...
    result = table.load local_file
    _(result).must_equal true

    Tempfile.open "empty_extract_file.json" do |tmp|
      dest_file_name = random_file_destination_name
      extract_url = "gs://#{bucket.name}/#{dest_file_name}"
      result = safe_gcs_execute { table.extract extract_url } 
      _(result).must_equal true

      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end

  it "extracts data to a file in your bucket with extract" do
    # Make sure there is data to extract...
    result = table.load local_file
    _(result).must_equal true
    Tempfile.open "empty_extract_file.json" do |tmp|
      _(tmp.size).must_equal 0
      dest_file_name = random_file_destination_name
      extract_file = bucket.create_file tmp, dest_file_name

      result = safe_gcs_execute { table.extract extract_file } 
      _(result).must_equal true
      # Refresh to get the latest file data
      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end

  it "creates snapshot of a table" do
    begin
      result = table.snapshot target_snapshot_table
      _(result).must_equal true
      table_snapshot = dataset.table target_snapshot_table
      _(table_snapshot.snapshot?).must_equal true
    ensure
      table_snapshot.delete  
    end
  end

  it "creates clone of a table" do
    begin
      result = table.clone target_clone_table
      _(result).must_equal true
      table_clone = dataset.table target_clone_table
      _(table_clone.clone?).must_equal true
    ensure
      table_clone.delete  
    end
  end

  it "updates the table schema with default values" do
    table.schema do |schema|
      schema.field "name" do |field|
        field.default_value_expression = "'name'"
      end
      schema.field "dob" do |field|
        field.default_value_expression = "CURRENT_TIMESTAMP"
      end
    end

    table = dataset.table table_id
    _(table.schema.fields.map(&:default_value_expression)).must_be :==, schema_fields_default.map(&:default_value_expression)
  end

  it "restores snapshot into a table" do
    begin
      result = table.clone target_clone_table
      _(result).must_equal true
      restored_table = dataset.table target_clone_table
      _(restored_table.table?).must_equal true
    ensure
      restored_table.delete  
    end
  end
end
