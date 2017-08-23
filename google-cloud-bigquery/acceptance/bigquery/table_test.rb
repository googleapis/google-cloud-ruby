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

describe Google::Cloud::Bigquery::Table, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "kittens" }
  let(:table) do
    t = dataset.table table_id
    if t.nil?
      t = dataset.create_table table_id do |schema|
        schema.integer  "id",     description: "id description",    mode: :required
        schema.string    "breed", description: "breed description", mode: :required
        schema.string    "name",  description: "name description",  mode: :required
        schema.timestamp "dob",   description: "dob description",   mode: :required
      end
    end
    t
  end
  let(:time_partitioned_table_id) { "daily_kittens"}
  let(:seven_days) { 7 * 24 * 60 * 60 }
  let(:time_partitioned_table) do
    t = dataset.table time_partitioned_table_id
    if t.nil?
      t = dataset.create_table time_partitioned_table_id do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_expiration = seven_days
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
  let(:local_file) { "acceptance/data/kitten-test-data.json" }
  let(:target_table_id) { "kittens_copy" }

  it "has the attributes of a table" do
    fresh = dataset.table table.table_id
    fresh.must_be_kind_of Google::Cloud::Bigquery::Table

    fresh.project_id.must_equal bigquery.project
    fresh.id.must_equal "#{bigquery.project}:#{dataset.dataset_id}.#{table.table_id}"
    fresh.query_id.must_equal "`#{bigquery.project}.#{dataset.dataset_id}.#{table.table_id}`"
    fresh.etag.wont_be :nil?
    fresh.api_url.wont_be :nil?
    fresh.bytes_count.wont_be :nil?
    fresh.rows_count.wont_be :nil?
    fresh.created_at.must_be_kind_of Time
    fresh.expires_at.must_be :nil?
    fresh.modified_at.must_be_kind_of Time
    fresh.table?.must_equal true
    fresh.view?.must_equal false
    fresh.time_partitioning_type.must_be_nil
    fresh.time_partitioning_expiration.must_be_nil
    #fresh.location.must_equal "US"       TODO why nil? Set in dataset

    # streaming buffer is transient, it seems it may or may not be present?
    fresh.buffer_bytes.must_be_kind_of Integer if fresh.buffer_bytes
    fresh.buffer_rows.must_be_kind_of Integer if fresh.buffer_rows
    fresh.buffer_oldest_at.must_be_kind_of Time if fresh.buffer_oldest_at

    fresh.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    fresh.schema.wont_be :empty?
    [:id, :breed, :name, :dob].each { |k| fresh.headers.must_include k }

    fields = fresh.schema.fields
    fields.each do |f|
      f.name.wont_be :nil?
      f.type.wont_be :nil?
      f.description.wont_be :nil?
      f.mode.wont_be :nil?
      f.name = f.name
      f.type = f.type
      f.description = f.description
      f.mode = f.mode
    end
  end

  it "gets and sets metadata" do
    new_name = "New name"
    new_desc = "New description!"
    table.name = new_name
    table.description = new_desc

    table.reload!
    table.table_id.must_equal table_id
    table.name.must_equal new_name
    table.description.must_equal new_desc
  end

  it "should fail to set metadata with stale etag" do
    fresh = dataset.table table.table_id
    fresh.etag.wont_be :nil?

    stale = dataset.table table_id
    stale.etag.wont_be :nil?
    stale.etag.must_equal fresh.etag

    # Modify on the server, which will change the etag
    fresh.description = "Description 1"
    stale.etag.wont_equal fresh.etag
    err = expect { stale.description = "Description 2" }.must_raise Google::Cloud::FailedPreconditionError
    err.message.must_equal "conditionNotMet: Precondition Failed"
  end

  it "create dataset returns valid etag equal to get dataset" do
    fresh_table_id = "#{rand 100}_kittens"
    fresh = dataset.create_table fresh_table_id do |schema|
      schema.integer  "id",     description: "id description",    mode: :required
      schema.string    "breed", description: "breed description", mode: :required
      schema.string    "name",  description: "name description",  mode: :required
      schema.timestamp "dob",   description: "dob description",   mode: :required
    end
    fresh.etag.wont_be :nil?

    stale = dataset.table fresh_table_id
    stale.etag.wont_be :nil?
    stale.etag.must_equal fresh.etag
  end

  # TODO: Remove this test and restore original impl after acceptance test
  # indicates that service etag bug is fixed
  it "etag from get table is different from etag returned by Service#insert_table" do
    service = bigquery.service
    new_table_id = "#{rand 100}_kittens"

    new_tb = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: bigquery.project, dataset_id: dataset_id,
        table_id: new_table_id))
    updater = Google::Cloud::Bigquery::Table::Updater.new(new_tb)

    new_gapi = service.insert_table dataset.dataset_id, updater.to_gapi
    new_gapi.etag.wont_be :nil?

    fresh = dataset.table new_table_id
    fresh.etag.wont_be :nil?
    fresh.etag.wont_equal new_gapi.etag
  end

  it "gets and sets time partitioning" do
    partitioned_table = dataset.table "weekly_kittens"
    if partitioned_table.nil?
      partitioned_table = dataset.create_table "weekly_kittens" do |updater|
        updater.time_partitioning_type = "DAY"
        updater.time_partitioning_expiration = seven_days
      end
    end

    partitioned_table.time_partitioning_expiration = 1

    partitioned_table.reload!
    partitioned_table.table_id.must_equal "weekly_kittens"
    partitioned_table.time_partitioning_type.must_equal "DAY"
    partitioned_table.time_partitioning_expiration.must_equal 1
  end

  it "updates its schema" do
    begin
      t = dataset.create_table "table_schema_test"
      t.schema do |s|
        s.boolean "available", description: "available description", mode: :nullable
      end
      t.headers.must_equal [:available]
      t.schema replace: true do |s|
        s.boolean "available", description: "available description", mode: :nullable
        s.record "countries_lived", description: "countries_lived description", mode: :repeated do |nested|
          nested.float "rating", description: "An value from 1 to 10", mode: :nullable
        end
      end
      t.headers.must_equal [:available, :countries_lived]
    ensure
      t2 = dataset.table "table_schema_test"
      t2.delete if t2
    end
  end

  it "allows tables to be created with time_partioning enabled" do
    table = time_partitioned_table
    table.time_partitioning_type.must_equal "DAY"
    table.time_partitioning_expiration.must_equal seven_days
  end

  it "inserts rows directly and gets its data" do
    data = table.data
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

    # Job methods
    query_job.done?.must_equal true
    query_job.running?.must_equal false
    query_job.pending?.must_equal false
    query_job.created_at.must_be_kind_of Time
    query_job.started_at.must_be_kind_of Time
    query_job.ended_at.must_be_kind_of Time
    query_job.configuration.wont_be :nil?
    query_job.statistics.wont_be :nil?
    query_job.status.wont_be :nil?
    query_job.errors.must_be :empty?
    query_job.rerun!
    query_job.wait_until_done!

    query_job.batch?.must_equal false
    query_job.interactive?.must_equal true
    query_job.large_results?.must_equal false
    query_job.cache?.must_equal true
    query_job.flatten?.must_equal true
    query_job.cache_hit?.must_equal false
    query_job.bytes_processed.wont_be :nil?
    query_job.destination.wont_be :nil?
    query_job.data.class.must_equal Google::Cloud::Bigquery::Data
    query_job.data.total.wont_be :nil?

    # Query Job - Statistics Query Plan
    query_job.query_plan.wont_be_nil
    query_job.query_plan.must_be_kind_of Array
    query_job.query_plan.wont_be :empty?
    stage = query_job.query_plan.first
    stage.must_be_kind_of Google::Cloud::Bigquery::QueryJob::Stage
    stage.compute_ratio_avg.must_be_kind_of Float
    stage.compute_ratio_max.must_be_kind_of Float
    stage.id.must_be_kind_of Integer
    stage.name.must_be_kind_of String
    stage.read_ratio_avg.must_be_kind_of Float
    stage.read_ratio_max.must_be_kind_of Float
    stage.records_read.must_be_kind_of Integer
    stage.records_written.must_be_kind_of Integer
    stage.status.must_be_kind_of String
    stage.wait_ratio_avg.must_be_kind_of Float
    stage.wait_ratio_max.must_be_kind_of Float
    stage.write_ratio_avg.must_be_kind_of Float
    stage.write_ratio_max.must_be_kind_of Float
    stage.steps.wont_be_nil
    stage.steps.must_be_kind_of Array
    stage.steps.wont_be :empty?
    step = stage.steps.first
    step.must_be_kind_of Google::Cloud::Bigquery::QueryJob::Step
    step.kind.must_be_kind_of String
    step.substeps.wont_be_nil
    step.substeps.must_be_kind_of Array
    step.substeps.wont_be :empty?


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

    data = dataset.query query
    data.class.must_equal Google::Cloud::Bigquery::Data
    data.total.wont_be(:nil?)
    data.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    data.fields.count.must_equal 4
    [:id, :breed, :name, :dob].each { |k| data.headers.must_include k }
    data.all.each do |row|
      row.must_be_kind_of Hash
    end
    data.next.must_be :nil?
  end

  it "insert skip invalid rows and return insert errors" do
    # data = table.data
    insert_response = table.insert invalid_rows, skip_invalid: true
    insert_response.wont_be :success?
    insert_response.insert_count.must_equal 2

    insert_response.insert_errors.wont_be :empty?
    insert_response.insert_errors.count.must_equal 1
    insert_response.insert_errors.first.class.must_equal Google::Cloud::Bigquery::InsertResponse::InsertError
    insert_response.insert_errors.first.index.must_equal 1

    # In the context of this test, the original row cannot be compared with InsertResponse row because
    # rows are converted to "BigQuery JSON rows" early in table.insert: key symbols are turned into strings and
    # dates/times are formated as timestamp strings with milliseconds.
    # To be able to test InsertResponse#{insert_error_for, errrors_for, index_for} we need a "BigQuery JSON row"
    # instead of using insert_response.insert_error.first we make one by converting our orginal "invalid_row"
    bigquery_row = Google::Cloud::Bigquery::Convert.to_json_row(invalid_rows[insert_response.insert_errors.first.index])
    insert_response.insert_errors.first.row.must_equal bigquery_row

    insert_response.error_rows.wont_be :empty?
    insert_response.error_rows.count.must_equal 1
    insert_response.error_rows.first.must_equal bigquery_row

    insert_response.insert_error_for(invalid_rows[1]).index.must_equal insert_response.insert_errors.first.index
    insert_response.errors_for(invalid_rows[1]).wont_be :empty?
    insert_response.index_for(invalid_rows[1]).must_equal 1
  end

  it "imports data from a local file" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = table.load local_file, job_id: job_id, job_id: job_id
    job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    job.job_id.must_equal job_id
    job.wait_until_done!
    job.output_rows.must_equal 3
  end

  it "imports data from a file in your bucket" do
    begin
      bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
      file = bucket.create_file local_file

      job = table.load file
      job.wait_until_done!
      job.wont_be :failed?
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end

  it "copies itself to another table" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    copy_job = table.copy target_table_id, create: :needed, write: :empty, job_id: job_id

    copy_job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    copy_job.job_id.must_equal job_id
    copy_job.wait_until_done!

    copy_job.wont_be :failed?
    copy_job.source.table_id.must_equal table.table_id
    copy_job.destination.table_id.must_equal target_table_id
    copy_job.create_if_needed?.must_equal true
    copy_job.create_never?.must_equal false
    copy_job.write_truncate?.must_equal false
    copy_job.write_append?.must_equal false
    copy_job.write_empty?.must_equal true
  end

  it "creates and cancels jobs" do
    load_job = table.load local_file

    load_job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
    load_job.wont_be :done?

    load_job.cancel
    load_job.wait_until_done!

    load_job.must_be :done?

    load_job.wont_be :failed?
  end

  it "extracts data to a url in your bucket" do
    skip "The BigQuery to Storage acceptance tests are failing with internalError"
    begin
      # Make sure there is data to extract...
      load_job = table.load local_file

      load_job.must_be_kind_of Google::Cloud::Bigquery::LoadJob
      load_job.wait_until_done!

      load_job.wont_be :failed?
      load_job.destination.table_id.must_equal table.table_id
      load_job.delimiter.must_equal ","
      load_job.skip_leading_rows.must_equal 0
      load_job.utf8?.must_equal true
      load_job.iso8859_1?.must_equal false
      load_job.quote.must_equal "\""
      load_job.max_bad_records.must_equal 0
      load_job.quoted_newlines?.must_equal true
      load_job.json?.must_equal true
      load_job.csv?.must_equal false
      load_job.backup?.must_equal false
      load_job.allow_jagged_rows?.must_equal false
      load_job.ignore_unknown_values?.must_equal false
      load_job.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
      load_job.schema.wont_be :empty?
      load_job.input_files.must_equal 1
      load_job.input_file_bytes.must_be :>, 0
      load_job.output_rows.must_be :>, 0
      load_job.output_bytes.must_be :>, 0

      Tempfile.open "empty_extract_file.json" do |tmp|
        bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
        extract_url = "gs://#{bucket.name}/kitten-test-data-backup.json"
        extract_job = table.extract extract_url

        extract_job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
        extract_job.wait_until_done!

        extract_job.wont_be :failed?
        extract_job.source.table_id.must_equal table.table_id
        extract_job.compression?.must_equal false
        extract_job.json?.must_equal true
        extract_job.csv?.must_equal false
        extract_job.delimiter.must_equal ","
        extract_job.print_header?.must_equal true
        extract_job.destinations_file_counts.wont_be :empty?
        extract_job.destinations_counts.wont_be :empty?

        extract_file = bucket.file "kitten-test-data-backup.json"
        downloaded_file = extract_file.download tmp.path
        downloaded_file.size.must_be :>, 0
      end
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end

  it "extracts data to a file in your bucket" do
    skip "The BigQuery to Storage acceptance tests are failing with internalError"
    begin
      # Make sure there is data to extract...
      load_job = table.load local_file
      load_job.wait_until_done!
      Tempfile.open "empty_extract_file.json" do |tmp|
        tmp.size.must_equal 0
        bucket = Google::Cloud.storage.create_bucket "#{prefix}_bucket"
        extract_file = bucket.create_file tmp, "kitten-test-data-backup.json"
        job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated

        extract_job = table.extract extract_file, job_id: job_id
        extract_job.job_id.must_equal job_id
        extract_job.wait_until_done!
        extract_job.wont_be :failed?
        # Refresh to get the latest file data
        extract_file = bucket.file "kitten-test-data-backup.json"
        downloaded_file = extract_file.download tmp.path
        downloaded_file.size.must_be :>, 0
      end
    ensure
      post_bucket = Google::Cloud.storage.bucket "#{prefix}_bucket"
      if post_bucket
        post_bucket.files.map &:delete
        post_bucket.delete
      end
    end
  end
end
