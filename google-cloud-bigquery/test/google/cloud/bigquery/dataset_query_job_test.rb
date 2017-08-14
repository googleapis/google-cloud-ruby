# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
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

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
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

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.job_id.must_equal job_id
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

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.job_id.must_equal job_id
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

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.job_id.must_equal job_id
  end
end
