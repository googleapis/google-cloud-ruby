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
  let(:publicdata_query) { "SELECT url FROM `publicdata.samples.github_nested` LIMIT 100" }
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
      end
    end
    t
  end
  let(:table_avro_id) { "dataset_table_avro" }
  let(:table_avro) { dataset.table table_avro_id }

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
  let(:view_id) { "dataset_view" }
  let(:view) do
    t = dataset.table view_id
    if t.nil?
      t = dataset.create_view view_id, publicdata_query
    end
    t
  end
  let(:local_file) { "acceptance/data/kitten-test-data.json" }

  before do
    table
    view
  end

  it "has the attributes of a dataset" do
    fresh = bigquery.dataset dataset_id
    fresh.must_be_kind_of Google::Cloud::Bigquery::Dataset

    fresh.project_id.must_equal bigquery.project
    fresh.dataset_id.must_equal dataset.dataset_id
    fresh.etag.wont_be :nil?
    fresh.api_url.wont_be :nil?
    fresh.created_at.must_be_kind_of Time
    fresh.modified_at.must_be_kind_of Time
    fresh.dataset_ref.must_be_kind_of Hash
    fresh.dataset_ref[:project_id].must_equal bigquery.project
    fresh.dataset_ref[:dataset_id].must_equal dataset.dataset_id
    # fresh.location.must_equal "US"       TODO why nil? Set in dataset
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
    fresh.wont_be :nil?
    fresh.must_be_kind_of Google::Cloud::Bigquery::Dataset
    fresh.dataset_id.must_equal dataset.dataset_id
    fresh.name.must_equal new_name
    fresh.description.must_equal new_desc
    fresh.default_expiration.must_equal new_default_expiration
    fresh.labels.must_equal new_labels

    dataset.default_expiration = nil
  end

  it "should fail to set metadata with stale etag" do
    fresh = bigquery.dataset dataset.dataset_id
    fresh.etag.wont_be :nil?

    stale = bigquery.dataset dataset_id
    stale.etag.wont_be :nil?
    stale.etag.must_equal fresh.etag

    # Modify on the server, which will change the etag
    fresh.description = "Description 1"
    stale.etag.wont_equal fresh.etag
    err = expect { stale.description = "Description 2" }.must_raise Google::Cloud::FailedPreconditionError
    err.message.must_equal "conditionNotMet: Precondition Failed"
  end

  it "create dataset returns valid etag equal to get dataset" do
    fresh_dataset_id = "#{prefix}_#{rand 100}_unique"
    fresh = bigquery.create_dataset fresh_dataset_id
    fresh.etag.wont_be :nil?

    stale = bigquery.dataset fresh_dataset_id
    stale.etag.wont_be :nil?
    stale.etag.must_equal fresh.etag
  end

  it "should get a list of tables and views" do
    tables = dataset.tables
    # The code in before ensures we have at least one dataset
    tables.count.must_be :>=, 2
    tables.each do |t|
      t.table_id.wont_be :nil?
      t.created_at.must_be_kind_of Time # Loads full representation
    end
  end

  it "should get all tables and views in pages with token" do
    tables = dataset.tables(max: 1).all
    tables.count.must_be :>=, 2
    tables.each do |t|
      t.table_id.wont_be :nil?
      t.created_at.must_be_kind_of Time # Loads full representation
    end
  end

  it "imports data from a local file and creates a new table with specified schema in a block with load_job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load_job "local_file_table", local_file, job_id: job_id do |schema|
      schema.integer   "id",    description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.job_id.must_equal job_id
    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a local file and creates a new table with specified schema as an option with load_job" do
    schema = bigquery.schema do |s|
      s.integer   "id",    description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required
      s.timestamp "dob",   description: "dob description",   mode: :required
    end

    job = dataset.load_job "local_file_table_2", local_file, schema: schema

    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a local file and creates a new table without a schema with load_job" do
    job = dataset.load_job table_with_schema.table_id, local_file, create: :never
    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a list of files in your bucket with load_job" do
    begin
      more_data = rows.map { |row| JSON.generate row }.join("\n")
      bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
      file1 = bucket.create_file local_file
      file2 = bucket.create_file StringIO.new(more_data),
                                 "more-kitten-test-data.json"
      gs_url = "gs://#{file2.bucket}/#{file2.name}"

      # Test both by file object and URL as string
      job = dataset.load_job table_with_schema.table_id, [file1, gs_url]
      job.wait_until_done!
      job.wont_be :failed?
      job.input_files.must_equal 2
      job.output_rows.must_equal 6
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end

  it "imports data from a local file and creates a new table with specified schema in a block with load" do
    result = dataset.load "local_file_table", local_file do |schema|
      schema.integer   "id",    description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    result.must_equal true
  end

  it "imports data from a local file and creates a new table with specified schema as an option with load" do
    schema = bigquery.schema do |s|
      s.integer  "id",     description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required
      s.timestamp "dob",   description: "dob description",   mode: :required
    end

    result = dataset.load "local_file_table_2", local_file, schema: schema
    result.must_equal true
  end

  it "imports data from a local file and creates a new table without a schema with load" do
    result = dataset.load table_with_schema.table_id, local_file do |job|
      job.create = :never
    end
    result.must_equal true
  end

  it "imports data from a list of files in your bucket with load" do
    begin
      more_data = rows.map { |row| JSON.generate row }.join("\n")
      bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
      file1 = bucket.create_file local_file
      file2 = bucket.create_file StringIO.new(more_data),
                                 "more-kitten-test-data.json"
      gs_url = "gs://#{file2.bucket}/#{file2.name}"

      # Test both by file object and URL as string
      result = dataset.load table_with_schema.table_id, [file1, gs_url]
      result.must_equal true
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end

  it "imports data from gcs avro file and creates a new table with load" do
    result = dataset.load(
      table_avro_id,
      "gs://cloud-samples-data/bigquery/us-states/us-states.avro")
    result.must_equal true
  end

  it "imports data from gcs avro file and creates a new table with encryption with load" do
    encrypt_config = bigquery.encryption(
      kms_key: "projects/cloud-samples-tests/locations/us-central1" +
                "/keyRings/test/cryptoKeys/test")
    result = dataset.load(
      table_avro_id,
      "gs://cloud-samples-data/bigquery/us-states/us-states.avro") do |load|
      load.write = :truncate
      load.encryption = encrypt_config
    end
    result.must_equal true
    table_avro.reload!
    table_avro.encryption.must_equal encrypt_config
  end

  it "inserts rows directly and gets its data" do
    insert_response = dataset.insert table_with_schema.table_id, rows
    insert_response.must_be :success?
    insert_response.insert_count.must_equal 3
    insert_response.insert_errors.must_be :empty?
    insert_response.error_rows.must_be :empty?

    data = table_with_schema.data max: 1
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.wont_be :nil?
    data.etag.wont_be :nil?
    [nil, 0].must_include data.total
    data.count.wont_be :nil?
    data.all(request_limit: 2).each do |row|
      row.must_be_kind_of Hash
      [:id, :breed, :name, :dob].each { |k| row.keys.must_include k }
    end
    more_data = data.next
    more_data.wont_be :nil?
  end

  it "insert skip invalid rows and return insert errors" do
    insert_response = dataset.insert table_with_schema.table_id, invalid_rows, skip_invalid: true
    insert_response.wont_be :success?
    insert_response.insert_count.must_equal 2

    insert_response.insert_errors.wont_be :empty?
    insert_response.insert_errors.count.must_equal 1
    insert_response.insert_errors.first.class.must_equal Google::Cloud::Bigquery::InsertResponse::InsertError
    insert_response.insert_errors.first.index.must_equal 1

    bigquery_row = invalid_rows[insert_response.insert_errors.first.index]
    insert_response.insert_errors.first.row.must_equal bigquery_row

    insert_response.error_rows.wont_be :empty?
    insert_response.error_rows.count.must_equal 1
    insert_response.error_rows.first.must_equal bigquery_row

    insert_response.insert_error_for(invalid_rows[1]).index.must_equal insert_response.insert_errors.first.index
    insert_response.errors_for(invalid_rows[1]).wont_be :empty?
    insert_response.index_for(invalid_rows[1]).must_equal 1
  end

  it "inserts rows with autocreate option" do
    # schema block is not needed in this test since table exists, but provide anyway
    insert_response = dataset.insert table_with_schema.table_id, rows, autocreate: true do |t|
      t.schema.integer   "id",    description: "id description",    mode: :required
      t.schema.string    "breed", description: "breed description", mode: :required
      t.schema.string    "name",  description: "name description",  mode: :required
      t.schema.timestamp "dob",   description: "dob description",   mode: :required
    end

    insert_response.must_be :success?
    insert_response.insert_count.must_equal 3
    insert_response.insert_errors.must_be :empty?
    insert_response.error_rows.must_be :empty?

    table = dataset.table table_with_schema_id
    table.wont_be_nil

    data = table.data max: 1
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.wont_be :nil?
    data.etag.wont_be :nil?
    [nil, 0].must_include data.total
    data.count.wont_be :nil?
    data.all(request_limit: 2).each do |row|
      row.must_be_kind_of Hash
      [:id, :breed, :name, :dob].each { |k| row.keys.must_include k }
    end
    more_data = data.next
    more_data.wont_be :nil?
  end

  it "creates missing table while inserts rows with autocreate option" do
    new_table_id = "new_dataset_table_id_#{rand(1000)}"

    insert_response = dataset.insert new_table_id, rows, autocreate: true do |t|
      t.schema.integer   "id",    description: "id description",    mode: :required
      t.schema.string    "breed", description: "breed description", mode: :required
      t.schema.string    "name",  description: "name description",  mode: :required
      t.schema.timestamp "dob",   description: "dob description",   mode: :required
    end

    insert_response.must_be :success?
    insert_response.insert_count.must_equal 3
    insert_response.insert_errors.must_be :empty?
    insert_response.error_rows.must_be :empty?

    table = dataset.table new_table_id
    table.wont_be_nil

    data = table.data max: 1
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.wont_be :nil?
    data.etag.wont_be :nil?
    [nil, 0].must_include data.total
    data.count.wont_be :nil?
    data.all(request_limit: 2).each do |row|
      row.must_be_kind_of Hash
      [:id, :breed, :name, :dob].each { |k| row.keys.must_include k }
    end
    more_data = data.next
    more_data.wont_be :nil?
  end
end
