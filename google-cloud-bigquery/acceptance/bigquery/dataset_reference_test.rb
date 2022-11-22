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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :reference, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      bigquery.create_dataset dataset_id
    end
    # Use local reference object in these tests, instead of full resource
    bigquery.dataset dataset_id, skip_lookup: true
  end
  let(:table_id) { "dataset_reference_table" }
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
  let(:user_val) { "blowmage@gmail.com" }

  before do
    table
    view
  end

  it "has the attributes of a dataset after reload" do
    _(dataset).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(dataset.project_id).must_equal bigquery.project
    _(dataset.dataset_id).must_equal dataset.dataset_id
    _(dataset.etag).must_be_nil
    _(dataset.api_url).must_be_nil
    _(dataset.created_at).must_be_nil
    _(dataset.modified_at).must_be_nil
    _(dataset.dataset_ref).must_be_kind_of Hash
    _(dataset.dataset_ref[:project_id]).must_equal bigquery.project
    _(dataset.dataset_ref[:dataset_id]).must_equal dataset.dataset_id

    dataset.reload!

    _(dataset.project_id).must_equal bigquery.project
    _(dataset.dataset_id).must_equal dataset.dataset_id
    _(dataset.etag).wont_be_nil
    _(dataset.api_url).wont_be_nil
    _(dataset.created_at).must_be_kind_of Time
    _(dataset.modified_at).must_be_kind_of Time
    _(dataset.dataset_ref).must_be_kind_of Hash
    _(dataset.dataset_ref[:project_id]).must_equal bigquery.project
    _(dataset.dataset_ref[:dataset_id]).must_equal dataset.dataset_id
  end

  it "deletes itself and knows it no longer exists" do
    dataset_2_id = "#{prefix}_dataset_delete"
    dataset_2 = bigquery.create_dataset dataset_2_id
    _(dataset_2.exists?).must_equal true
    _(dataset_2.delete).must_equal true
    _(dataset_2.exists?).must_equal false
    _(dataset_2.exists?(force: true)).must_equal false
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
    _(fresh).wont_be_nil
    _(fresh).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(fresh.dataset_id).must_equal dataset.dataset_id
    _(fresh.name).must_equal new_name
    _(fresh.description).must_equal new_desc
    _(fresh.default_expiration).must_equal new_default_expiration
    _(fresh.labels).must_equal new_labels

    dataset.default_expiration = nil
  end

  it "should get a list of tables and views" do
    tables = dataset.tables
    # The code in before ensures we have at least one dataset
    _(tables.count).must_be :>=, 2
    tables.each do |t|
      _(t.table_id).wont_be_nil
      _(t.created_at).must_be_kind_of Time # Loads full representation
    end
  end

  it "should get all tables and views in pages with token" do
    tables = dataset.tables(max: 1).all
    _(tables.count).must_be :>=, 2
    tables.each do |t|
      _(t.table_id).wont_be_nil
      _(t.created_at).must_be_kind_of Time # Loads full representation
    end
  end

  it "imports data from a local file and creates a new table with specified schema in a block with load" do
    result = dataset.load "local_file_table", local_file do |schema|
      schema.integer   "id",    description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    _(result).must_equal true
  end

  it "imports data from a list of files in your bucket with load_job" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    job = dataset.load_job table_id, [file1, gs_url]
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.input_files).must_equal 2
    _(job.output_rows).must_equal 6
  end

  it "imports data from a list of files in your bucket with load" do
    more_data = rows.map { |row| JSON.generate row }.join("\n")
    file1 = bucket.create_file local_file, random_file_destination_name
    file2 = bucket.create_file StringIO.new(more_data), random_file_destination_name
    gs_url = "gs://#{file2.bucket}/#{file2.name}"

    # Test both by file object and URL as string
    result = dataset.load table_id, [file1, gs_url]
    _(result).must_equal true
  end

  it "adds an access entry with specifying user scope" do
    dataset.access do |acl|
      acl.add_reader_user user_val
    end
    dataset = bigquery.dataset dataset_id
    assert dataset.access.reader_user? user_val

    dataset.access do |acl|
      acl.remove_reader_user user_val
    end
    dataset = bigquery.dataset dataset_id
    refute dataset.access.reader_user? user_val
  end

  it "inserts rows directly and gets its data" do
    insert_response = dataset.insert table_id, rows
    _(insert_response).must_be :success?
    _(insert_response.insert_count).must_equal 3
    _(insert_response.insert_errors).must_be :empty?
    _(insert_response.error_rows).must_be :empty?

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id
    _(query_job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(query_job.job_id).must_equal job_id
    _(query_job.session_id).must_be :nil?
    query_job.wait_until_done!
    _(query_job.done?).must_equal true
    _(query_job.data.total).wont_be_nil

    data = dataset.query query
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.total).wont_be_nil
  end
end
