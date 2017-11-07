# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :reference, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `publicdata.samples.github_nested` LIMIT 100" }
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
    dataset.must_be_kind_of Google::Cloud::Bigquery::Dataset
    dataset.project_id.must_equal bigquery.project
    dataset.dataset_id.must_equal dataset.dataset_id
    dataset.etag.must_be_nil
    dataset.api_url.must_be_nil
    dataset.created_at.must_be_nil
    dataset.modified_at.must_be_nil
    dataset.dataset_ref.must_be_kind_of Hash
    dataset.dataset_ref[:project_id].must_equal bigquery.project
    dataset.dataset_ref[:dataset_id].must_equal dataset.dataset_id

    dataset.reload!

    dataset.project_id.must_equal bigquery.project
    dataset.dataset_id.must_equal dataset.dataset_id
    dataset.etag.wont_be_nil
    dataset.api_url.wont_be_nil
    dataset.created_at.must_be_kind_of Time
    dataset.modified_at.must_be_kind_of Time
    dataset.dataset_ref.must_be_kind_of Hash
    dataset.dataset_ref[:project_id].must_equal bigquery.project
    dataset.dataset_ref[:dataset_id].must_equal dataset.dataset_id
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
    fresh.wont_be_nil
    fresh.must_be_kind_of Google::Cloud::Bigquery::Dataset
    fresh.dataset_id.must_equal dataset.dataset_id
    fresh.name.must_equal new_name
    fresh.description.must_equal new_desc
    fresh.default_expiration.must_equal new_default_expiration
    fresh.labels.must_equal new_labels

    dataset.default_expiration = nil
  end

  it "should get a list of tables and views" do
    tables = dataset.tables
    # The code in before ensures we have at least one dataset
    tables.count.must_be :>=, 2
    tables.each do |t|
      t.table_id.wont_be_nil
      t.created_at.must_be_kind_of Time # Loads full representation
    end
  end

  it "should get all tables and views in pages with token" do
    tables = dataset.tables(max: 1).all
    tables.count.must_be :>=, 2
    tables.each do |t|
      t.table_id.wont_be_nil
      t.created_at.must_be_kind_of Time # Loads full representation
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
    insert_response = table.insert rows
    insert_response.must_be :success?
    insert_response.insert_count.must_equal 3
    insert_response.insert_errors.must_be :empty?
    insert_response.error_rows.must_be :empty?

    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    query_job = dataset.query_job query, job_id: job_id
    query_job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    query_job.job_id.must_equal job_id
    query_job.wait_until_done!
    query_job.done?.must_equal true
    query_job.data.total.wont_be_nil

    data = dataset.query query
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.total.wont_be_nil
  end
end
