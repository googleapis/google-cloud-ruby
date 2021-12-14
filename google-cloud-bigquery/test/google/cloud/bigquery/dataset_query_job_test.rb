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

describe Google::Cloud::Bigquery::Dataset, :query_job, :mock_bigquery do
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
  let(:range_partitioning) do
    Google::Apis::BigqueryV2::RangePartitioning.new(
      field: "my_table_id",
      range: Google::Apis::BigqueryV2::RangePartitioning::Range.new(
        start: 0,
        interval: 10,
        end: 100
      )
    ) 
  end
  let(:time_partitioning) do
    Google::Apis::BigqueryV2::TimePartitioning.new type: "DAY", field: "dob", expiration_ms: 86_400_000, require_partition_filter: true
  end
  let(:clustering_fields) { ["last_name", "first_name"] }
  let(:clustering) do
    Google::Apis::BigqueryV2::Clustering.new fields: clustering_fields
  end

  it "queries the data with default dataset option set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  describe "dataset reference" do
    let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

    it "queries the data with default dataset option set" do
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock

      job_gapi = query_job_gapi(query, location: nil)
      job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project,
        dataset_id: dataset_id
      )
      mock.expect :insert_job, job_gapi, [project, job_gapi]

      job = dataset.query_job query
      mock.verify

      _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    end
  end

  it "queries the data with table options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
      project_id: project,
      dataset_id: dataset_id,
      table_id:   table_id
    )
    job_gapi.configuration.query.create_disposition = "CREATE_NEVER"
    job_gapi.configuration.query.write_disposition = "WRITE_TRUNCATE"
    job_gapi.configuration.query.allow_large_results = true
    job_gapi.configuration.query.flatten_results = false
    job_gapi.configuration.query.maximum_billing_tier = 2
    job_gapi.configuration.query.maximum_bytes_billed = 12345678901234
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, table: table,
                            create: :never, write: :truncate,
                            large_results: true, flatten: false,
                            maximum_billing_tier: 2,
                            maximum_bytes_billed: 12345678901234
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
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
  end

  it "queries the data with range_partitioning" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project,
        dataset_id: dataset_id
    )
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
        project_id: project,
        dataset_id: dataset_id,
        table_id:   table_id
    )
    job_gapi.configuration.query.range_partitioning = range_partitioning

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, table: table do |j|
      j.range_partitioning_field = "my_table_id"
      j.range_partitioning_start = 0
      j.range_partitioning_interval = 10
      j.range_partitioning_end = 100
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.range_partitioning?).must_equal true
    _(job.range_partitioning_field).must_equal "my_table_id"
    _(job.range_partitioning_start).must_equal 0
    _(job.range_partitioning_interval).must_equal 10
    _(job.range_partitioning_end).must_equal 100
  end

  it "queries the data with time_partitioning and clustering" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project,
        dataset_id: dataset_id
    )
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
        project_id: project,
        dataset_id: dataset_id,
        table_id:   table_id
    )
    job_gapi.configuration.query.time_partitioning = time_partitioning
    job_gapi.configuration.query.clustering = clustering

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, table: table do |job|
      job.time_partitioning_type = "DAY"
      job.time_partitioning_field = "dob"
      job.time_partitioning_expiration = 86_400
      job.time_partitioning_require_filter = true
      job.clustering_fields = clustering_fields
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.time_partitioning?).must_equal true
    _(job.time_partitioning_type).must_equal "DAY"
    _(job.time_partitioning_field).must_equal "dob"
    _(job.time_partitioning_expiration).must_equal 86_400
    _(job.time_partitioning_require_filter?).must_equal true
    _(job.clustering?).must_equal true
    _(job.clustering_fields).must_equal clustering_fields
  end

  it "queries the data with job_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_id = "my_test_job_id"
    job_gapi = query_job_gapi query, job_id: job_id
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, job_id: job_id
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with dryrun flag" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, dry_run: true
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, dryrun: true
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

    job_gapi = query_job_gapi query, job_id: job_id
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, prefix: prefix
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_id = "my_test_job_id"
    job_gapi = query_job_gapi query, job_id: job_id
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, job_id: job_id, prefix: "IGNORED"
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.job_id).must_equal job_id
  end

  it "queries the data with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.labels = labels
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, labels: labels
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.labels).must_equal labels
  end

  it "queries the data with an array for the udfs option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.user_defined_function_resources = udfs_gapi_array
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, udfs: udfs
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.udfs).must_equal udfs
  end

  it "queries the data with a string for the udfs option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.user_defined_function_resources = [udfs_gapi_uri]
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query, udfs: "gs://my-bucket/my-lib.js"
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.udfs).must_equal ["gs://my-bucket/my-lib.js"]
  end

  it "queries the data with create_session option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, create_session: true
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = dataset.query_job query, create_session: true
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with create_session in block" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, create_session: true
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.create_session = true
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with session_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, session_id: session_id
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = dataset.query_job query, session_id: session_id
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end

  it "queries the data with session_id in block" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, session_id: session_id
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_resp_gapi = query_job_resp_gapi query, session_id: session_id
    mock.expect :insert_job, job_resp_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.session_id = session_id
      j.session_id = nil
      j.session_id = session_id
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::QueryJob
    _(job.session_id).must_equal session_id
  end
end
