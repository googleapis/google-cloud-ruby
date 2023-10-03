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

describe Google::Cloud::Bigquery, :bigquery do
  let(:publicdata_query) { "SELECT url FROM `bigquery-public-data.samples.github_nested` LIMIT 100" }
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:labels) { { "prefix" => prefix } }
  let(:udfs) { [ "return x+1;", "gs://my-bucket/my-lib.js" ] }
  let(:filter) { "labels.prefix:#{prefix}" }
  let(:dataset_labels_id) { "#{prefix}_dataset_labels" }
  let(:dataset_labels) do
    d = bigquery.dataset dataset_labels_id
    if d.nil?
      d = bigquery.create_dataset dataset_labels_id do |ds|
        ds.labels = labels
      end
    end
    d
  end
  let(:dataset_with_access_id) { "#{prefix}_dataset_with_access" }
  let(:local_file) { "acceptance/data/kitten-test-data.json" }
  let(:model_id) { "model_#{SecureRandom.hex(4)}" }
  let :model_sql do
    model_sql = <<~MODEL_SQL
    CREATE MODEL #{dataset.dataset_id}.#{model_id}
    OPTIONS (
        model_type='linear_reg',
        max_iteration=1,
        learn_rate=0.4,
        learn_rate_strategy='constant'
    ) AS (
        SELECT 'a' AS f1, 2.0 AS label
        UNION ALL
        SELECT 'b' AS f1, 3.8 AS label
    )
    MODEL_SQL
  end

  before do
    dataset
    dataset_labels
  end

  it "should get its project service account email" do
    email = bigquery.service_account_email
    _(email).wont_be :nil?
    _(email).must_be_kind_of String
    # https://stackoverflow.com/questions/22993545/ruby-email-validation-with-regex
    _(email).must_match /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  it "should get a list of datasets" do
    datasets = bigquery.datasets max: 1
    # The code in before ensures we have at least one dataset
    _(datasets.count).wont_be :zero?
    datasets.all(request_limit: 1).each do |ds|
      _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset
      _(ds.created_at).must_be_kind_of Time # Loads full representation
    end
    more_datasets = datasets.next
    _(more_datasets).wont_be :nil?
  end

  it "should get a list of datasets by labels filter" do
    datasets = bigquery.datasets filter: filter
    _(datasets.count).must_equal 1
    ds = datasets.first
    _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset
    _(ds.labels).must_equal labels
  end

  it "create a dataset with access rules" do
    bigquery.create_dataset dataset_with_access_id do |ds|
      ds.access do |acl|
        acl.add_writer_special :all
      end
    end
    fresh = bigquery.dataset dataset_with_access_id
    _(fresh).wont_be :nil?
    _(fresh.access).wont_be :empty?
    _(fresh.access.to_a).must_be_kind_of Array
    assert fresh.access.writer_special? :all
  end

  it "should run a query" do
    rows = bigquery.query publicdata_query
    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 100
  end

  it "should run a query without legacy SQL syntax" do
    rows = bigquery.query publicdata_query, legacy_sql: false
    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 100
  end

  it "should run a query with standard SQL syntax" do
    rows = bigquery.query publicdata_query, standard_sql: true
    _(rows.class).must_equal Google::Cloud::Bigquery::Data
    _(rows.count).must_equal 100
  end

  it "should run a query job with job id and delete the job" do
    job_id = "test_job_#{SecureRandom.urlsafe_base64(21)}" # client-generated
    job = bigquery.query_job publicdata_query, job_id: job_id
    _(job).must_be_kind_of Google::Cloud::Bigquery::Job
    _(job.job_id).must_equal job_id
    _(job.transaction_id).must_be :nil?
    _(job.user_email).wont_be_nil

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

    job.wait_until_done!
    rows = job.data
    _(rows.total).must_equal 100

    # @gapi.statistics.query
    _(job.bytes_processed).must_equal 0
    _(job.query_plan).must_be :nil?
    # Sometimes values are nil in the returned job, so currently comment out unreliable expectations
    # job.statement_type.must_equal "SELECT"
    _(job.ddl_operation_performed).must_be :nil?
    _(job.ddl_target_table).must_be :nil?
    _(job.ddl_target_routine).must_be :nil?

    job.delete
    job = bigquery.job job.job_id, location: job.location
    _(job).must_be :nil?
  end

  it "should run a query job with dryrun flag" do
    job = bigquery.query_job publicdata_query, dryrun: true
    _(job.dryrun?).must_equal true
    _(job.dryrun).must_equal true # alias
    _(job.dry_run).must_equal true # alias
    _(job.dry_run?).must_equal true # alias

    job.wait_until_done!
    data = job.data
    _(data.count).must_equal 0
    _(data.next?).must_equal false
    _(data.total).must_be :nil?
    _(data.schema).must_be :nil?
    _(data.statement_type).must_equal "SELECT"

    # @gapi.statistics.query
    _(job.bytes_processed).must_be :>, 0 # 155625782
    _(job.query_plan).must_be :nil?
  end

  it "should run a query job with job labels" do
    job = bigquery.query_job publicdata_query, labels: labels
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.labels).must_equal labels
  end

  it "receives error when a standard SQL query job is passed a udfs param" do
    job = bigquery.query_job publicdata_query, udfs: udfs
    job.wait_until_done!
    _(job).must_be :failed?
    _(job.error["message"]).must_match /Legacy SQL UDFs cannot be used in Standard SQL queries/
  end

  it "should run a query job with job labels in a block updater" do
    job = bigquery.query_job publicdata_query do |j|
      j.labels = labels
    end
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.labels).must_equal labels
  end

  it "should get a list of jobs" do
    jobs = bigquery.jobs.all request_limit: 3
    jobs.each { |job| _(job).must_be_kind_of Google::Cloud::Bigquery::Job }
  end

  it "should get a list of projects" do
    projects = bigquery.projects.all
    _(projects.count).must_be :>, 0
    projects.each do |project|
      _(project).must_be_kind_of Google::Cloud::Bigquery::Project
      _(project.name).must_be_kind_of String
      _(project.service).must_be_kind_of Google::Cloud::Bigquery::Service
      _(project.service.project).must_be_kind_of String
      project.datasets.each do |ds|
        _(ds).must_be_kind_of Google::Cloud::Bigquery::Dataset
      end
    end
  end

  it "extracts a readonly table to a GCS url with extract" do
    Tempfile.open "empty_extract_file.csv" do |tmp|
      dest_file_name = random_file_destination_name
      extract_url = "gs://#{bucket.name}/#{dest_file_name}"
      result = bigquery.extract samples_public_table, extract_url do |j|
        j.location = "US"
      end
      _(result).must_equal true

      extract_file = bucket.file dest_file_name
      downloaded_file = extract_file.download tmp.path
      _(downloaded_file.size).must_be :>, 0
    end
  end

  it "extracts a model to a GCS url with extract_job" do
    model = nil
    begin
      query_job = dataset.query_job model_sql
      query_job.wait_until_done!
      _(query_job).wont_be :failed?

      model = dataset.model model_id
      _(model).must_be_kind_of Google::Cloud::Bigquery::Model

      Tempfile.open "temp_extract_model" do |tmp|
        extract_url = "gs://#{bucket.name}/#{model_id}"

        # sut
        extract_job = bigquery.extract_job model, extract_url

        extract_job.wait_until_done!
        _(extract_job).wont_be :failed?
        _(extract_job.ml_tf_saved_model?).must_equal true
        _(extract_job.ml_xgboost_booster?).must_equal false
        _(extract_job.model?).must_equal true
        _(extract_job.table?).must_equal false

        source = extract_job.source
        _(source).must_be_kind_of Google::Cloud::Bigquery::Model
        _(source.model_id).must_equal model_id

        extract_files = bucket.files prefix: model_id
        _(extract_files).wont_be :nil?
        _(extract_files).wont_be :empty?
        extract_file = extract_files.find { |f| f.name == "#{model_id}/saved_model.pb" }
        _(extract_file).wont_be :nil?
        downloaded_file = extract_file.download tmp.path
        _(downloaded_file.size).must_be :>, 0
      end
    ensure
      # cleanup
      model.delete if model
    end
  end

  it "copies a readonly table to another table with copy" do
    result = bigquery.copy samples_public_table, "#{dataset_id}.shakespeare_copy", create: :needed, write: :empty do |j|
      j.location = "US"
    end
    _(result).must_equal true
  end

  it "imports data from a local file with session enabled" do
    job = bigquery.load_job "temp_table", local_file, autodetect: true, create_session: true

    job.wait_until_done!
    _(job.output_rows).must_equal 3

    session_id = job.statistics["sessionInfo"]["sessionId"]

    bigquery.load "temp_table", local_file, autodetect: true, session_id: session_id
    data = bigquery.query "SELECT * FROM _SESSION.temp_table;", session_id: session_id
    _(data.count).must_equal 6
  end

  it "imports data from a local file with dataset_id" do
    job = bigquery.load_job "temp_table", local_file, dataset_id: dataset_id, autodetect: true, create_session: true

    job.wait_until_done!
    _(job.output_rows).must_equal 3

    session_id = job.statistics["sessionInfo"]["sessionId"]

    bigquery.load "temp_table", local_file, dataset_id: dataset_id, autodetect: true, session_id: session_id
    data = bigquery.query "SELECT * FROM #{dataset_id}.temp_table;", session_id: session_id
    _(data.count).must_equal 6
  end
end
