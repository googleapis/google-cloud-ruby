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

describe Google::Cloud::Bigquery::Table, :reference, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "kittens_reference" }
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
    # Use local reference object in these tests, instead of full resource
    dataset.table table_id, skip_lookup: true
  end
  let(:partitioned_table_id) { "weekly_kittens_reference" }
  let(:partitioned_field_table_id) { "kittens_field_reference" }
  let(:seven_days) { 7 * 24 * 60 * 60 }
  let(:ten_days) { 10 * 24 * 60 * 60 }
  let(:query) { "SELECT id, breed, name, dob FROM #{table.query_id}" }
  let(:rows) do
    [
      { name: "silvano", breed: "the cat kind",      id: 4, dob: Time.now.utc },
      { name: "ryan",    breed: "golden retriever?", id: 5, dob: Time.now.utc },
      { name: "stephen", breed: "idkanycatbreeds",   id: 6, dob: Time.now.utc }
    ]
  end
  let(:local_file) { "acceptance/data/kitten-test-data.json" }
  let(:target_table_id) { "kittens_reference_copy" }
  let(:target_table_2_id) { "kittens_reference_copy_2" }
  let(:labels) { { "foo" => "bar" } }

  it "has the attributes of a table" do
    _(table).must_be_kind_of Google::Cloud::Bigquery::Table

    _(table.table_id).must_equal table_id
    _(table.dataset_id).must_equal dataset_id
    _(table.project_id).must_equal bigquery.project

    _(table.time_partitioning?).must_be_nil
    _(table.time_partitioning_type).must_be_nil
    _(table.time_partitioning_field).must_be_nil
    _(table.time_partitioning_expiration).must_be_nil
    _(table.range_partitioning?).must_be_nil
    _(table.range_partitioning_field).must_be_nil
    _(table.range_partitioning_start).must_be_nil
    _(table.range_partitioning_interval).must_be_nil
    _(table.range_partitioning_end).must_be_nil
    _(table.id).must_be_nil
    _(table.name).must_be_nil
    _(table.etag).must_be_nil
    _(table.api_url).must_be_nil
    _(table.description).must_be_nil
    _(table.bytes_count).must_be_nil
    _(table.rows_count).must_be_nil
    _(table.created_at).must_be_nil
    _(table.expires_at).must_be_nil
    _(table.modified_at).must_be_nil
    _(table.table?).must_be_nil
    _(table.view?).must_be_nil
    _(table.external?).must_be_nil
    _(table.location).must_be_nil
    _(table.labels).must_be_nil
    _(table.schema).must_be_nil
    _(table.fields).must_be_nil
    _(table.headers).must_be_nil
    _(table.external).must_be_nil
    _(table.buffer_bytes).must_be_nil
    _(table.buffer_rows).must_be_nil
    _(table.buffer_oldest_at).must_be_nil
  end

  it "deletes itself and knows it no longer exists" do
    table_2_id = "kittens_reference_delete"
    table_2 = dataset.create_table table_2_id
    _(table_2.exists?).must_equal true
    _(table_2.delete).must_equal true
    _(table_2.exists?).must_equal false
    _(table_2.exists?(force: true)).must_equal false
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

  it "gets and sets time partitioning" do
    partitioned_table = dataset.table partitioned_table_id
    if partitioned_table.nil?
      dataset.create_table partitioned_table_id do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_expiration = seven_days
      end
    end

    partitioned_table = dataset.table partitioned_table_id, skip_lookup: true
    partitioned_table.time_partitioning_expiration = ten_days

    partitioned_table.reload!
    _(partitioned_table.table_id).must_equal partitioned_table_id
    _(partitioned_table.time_partitioning_type).must_equal "DAY"
    _(partitioned_table.time_partitioning_field).must_be_nil
    _(partitioned_table.time_partitioning_expiration).must_equal ten_days

    partitioned_table = dataset.table partitioned_table_id, skip_lookup: true
    partitioned_table.time_partitioning_expiration = nil

    partitioned_table.reload!
    _(partitioned_table.table_id).must_equal partitioned_table_id
    _(partitioned_table.time_partitioning_type).must_equal "DAY"
    _(partitioned_table.time_partitioning_field).must_be_nil
    _(partitioned_table.time_partitioning_expiration).must_be_nil
  end

  it "gets and sets time partitioning by field" do
    partitioned_table = dataset.table partitioned_field_table_id
    if partitioned_table.nil?
      dataset.create_table partitioned_field_table_id do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_field = "dob"
        updater.time_partitioning_expiration = seven_days
        updater.schema do |schema|
          schema.timestamp "dob",   description: "dob description",   mode: :required
        end
      end
    end

    partitioned_table = dataset.table partitioned_field_table_id, skip_lookup: true
    partitioned_table.time_partitioning_expiration = 1

    partitioned_table.reload!
    _(partitioned_table.table_id).must_equal partitioned_field_table_id
    _(partitioned_table.time_partitioning_type).must_equal "DAY"
    _(partitioned_table.time_partitioning_field).must_equal "dob"
    _(partitioned_table.time_partitioning_expiration).must_equal 1
  end

  it "updates its schema" do
    begin
      t = dataset.create_table "table_schema_test"
      t = dataset.table "table_schema_test", skip_lookup: true
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

  it "inserts rows directly and gets its data" do
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
    _(query_job.done?).must_equal true
    _(query_job.data.total).wont_be_nil

    assert_data table.data(max: 1)
  end

  it "inserts rows asynchronously and gets its data" do
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
    _(query_job.done?).must_equal true
    _(query_job.data.total).wont_be :nil?

    assert_data table.data(max: 1)
  end

  it "imports data from a local file with load_job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = table.load_job local_file, job_id: job_id, labels: labels
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.job_id).must_equal job_id
    _(job.labels).must_equal labels
    _(job).wont_be :autodetect?
    _(job.null_marker).must_equal ""
    job.wait_until_done!
    _(job.output_rows).must_equal 3
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
    result = table.load [file1, gs_url]
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

  it "copies itself to another table with copy" do
    result = table.copy target_table_2_id, create: :needed, write: :empty
    _(result).must_equal true
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

      extract_job = table.extract_job extract_file, job_id: job_id
      _(extract_job.job_id).must_equal job_id
      extract_job.wait_until_done!
      _(extract_job).wont_be :failed?
      # Refresh to get the latest file data
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

      result = table.extract extract_file
      _(result).must_equal true
      # Refresh to get the latest file data
      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end
end
