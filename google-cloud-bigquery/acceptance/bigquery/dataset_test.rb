# Copyright 2015 Google Inc. All rights reserved.
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
        schema.integer  "id",     description: "id description",    mode: :required
        schema.string    "breed", description: "breed description", mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
      end
    end
    t
  end
  let(:query) { "SELECT id, breed, name, dob FROM #{table.query_id}" }
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

  it "imports data from a local file and creates a new table with specified schema in a block" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = dataset.load "local_file_table", local_file, job_id: job_id do |schema|
      schema.integer  "id",     description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.job_id.must_equal job_id
    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a local file and creates a new table with specified schema as an option" do
    schema = bigquery.schema do |s|
      s.integer  "id",     description: "id description",    mode: :required
      s.string    "breed", description: "breed description", mode: :required
      s.string    "name",  description: "name description",  mode: :required
      s.timestamp "dob",   description: "dob description",   mode: :required
    end

    job = dataset.load "local_file_table_2", local_file, schema: schema

    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a local file and creates a new table without a schema" do
    job = dataset.load table_with_schema.table_id, local_file, create: :never
    job.wait_until_done!
    job.output_rows.must_equal 3
  end
end
