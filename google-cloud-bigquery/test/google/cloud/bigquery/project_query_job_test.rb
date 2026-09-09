# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Project, :query_job, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM `some_project.some_dataset.users`" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "my_table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }
  let(:labels) { { "foo" => "bar" } }
  let(:udfs) { [ "return x+1;", "gs://my-bucket/my-lib.js" ] }
  let(:session_id) { "mysessionid" }

  it "queries the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    job_resp_gapi = query_job_resp_gapi query
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = bigquery.query_job query
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob

    # Sometimes statistics.query is nil in the returned job, test for that behavior here.
    _(job.cache_hit?).must_equal true
    _(job.bytes_processed).must_equal 123456
    _(job.query_plan).wont_be :nil?
    _(job.statement_type).must_equal "SELECT"
    _(job.ddl?).must_equal false
    _(job.dml?).must_equal false
    _(job.ddl_operation_performed).must_be :nil?
    _(job.ddl_target_routine).must_be :nil?
    _(job.ddl_target_table).must_be :nil?
    _(job.num_dml_affected_rows).must_be :nil?
    _(job.deleted_row_count).must_be :nil?
    _(job.inserted_row_count).must_be :nil?
    _(job.updated_row_count).must_be :nil?
  end

  it "queries the data with options set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query, location: nil)
    job_gapi.configuration.query.priority = "BATCH"
    job_gapi.configuration.query.use_query_cache = false
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, priority: :batch, cache: false
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with table options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query, location: nil)
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
      project_id: table.project_id,
      dataset_id: table.dataset_id,
      table_id:   table.table_id
    )
    job_gapi.configuration.query.create_disposition = "CREATE_NEVER"
    job_gapi.configuration.query.write_disposition = "WRITE_TRUNCATE"
    job_gapi.configuration.query.allow_large_results = true
    job_gapi.configuration.query.flatten_results = false
    job_gapi.configuration.query.maximum_billing_tier = 2
    job_gapi.configuration.query.maximum_bytes_billed = 12345678901234
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, table: table,
                                create: :never, write: :truncate,
                                large_results: true, flatten: false,
                                maximum_billing_tier: 2,
                                maximum_bytes_billed: 12345678901234
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with dataset option as a Dataset" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query, location: nil)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: dataset.project_id,
      dataset_id: dataset.dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, dataset: dataset
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with dataset and project options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query, location: nil)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: "some_random_project",
      dataset_id: "some_random_dataset"
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, dataset: "some_random_dataset", project: "some_random_project"
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with job_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_id = "my_test_job_id"
    job_gapi = query_job_gapi query, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, job_id: job_id
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with dryrun flag" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, dry_run: true, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, dryrun: true
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.dryrun?).must_equal true
    _(job.dryrun).must_equal true # alias
    _(job.dry_run).must_equal true # alias
    _(job.dry_run?).must_equal true # alias
  end

  it "queries the data with prefix option" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, prefix: prefix
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_id = "my_test_job_id"
    job_gapi = query_job_gapi query, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, job_id: job_id, prefix: "IGNORED"
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.labels = labels
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, labels: labels
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.labels).must_equal labels
  end

  it "queries the data with an array for the udfs option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.user_defined_function_resources = udfs_gapi_array
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, udfs: udfs
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.udfs).must_equal udfs
  end

  it "queries the data with a string for the udfs option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.user_defined_function_resources = [udfs_gapi_uri]
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, udfs: "gs://my-bucket/my-lib.js"
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.udfs).must_equal ["gs://my-bucket/my-lib.js"]
  end

  it "queries the data with create_session option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil, create_session: true
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = bigquery.query_job query, create_session: true
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with create_session option in a block" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil, create_session: true
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = bigquery.query_job query do |j|
      j.create_session = true
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with session_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil, session_id: session_id
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = bigquery.query_job query, session_id: session_id
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with session_id option in a block" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil, session_id: session_id
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = bigquery.query_job query do |j|
      j.session_id = session_id
      j.session_id = nil
      j.session_id = session_id
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end
end
