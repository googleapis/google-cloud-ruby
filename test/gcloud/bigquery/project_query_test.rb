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

describe Gcloud::Bigquery::Project, :query, :mock_bigquery do
  let(:query_request) {
    qrg = query_request_gapi
    qrg.default_dataset = nil
    qrg
  }
  let(:query) { query_request.query }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "my_table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }

  it "queries the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query
    mock.verify
    # data.must_be_kind_of Gcloud::Bigquery::QueryData
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    data[0].must_be_kind_of Hash
    data[0]["name"].must_equal "Heidi"
    data[0]["age"].must_equal 36
    data[0]["score"].must_equal 7.65
    data[0]["active"].must_equal true
    data[1].must_be_kind_of Hash
    data[1]["name"].must_equal "Aaron"
    data[1]["age"].must_equal 42
    data[1]["score"].must_equal 8.15
    data[1]["active"].must_equal false
    data[2].must_be_kind_of Hash
    data[2]["name"].must_equal "Sally"
    data[2]["age"].must_equal nil
    data[2]["score"].must_equal nil
    data[2]["active"].must_equal nil
  end

  it "paginates the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :query_job, query_data_gapi, [project, query_request]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, "job9876543210", {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data = bigquery.query query
    # data.must_be_kind_of Gcloud::Bigquery::QueryData
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    data.token.must_equal "token1234567890"
    data.next?.must_equal true

    data2 = data.next
    data2.class.must_equal Gcloud::Bigquery::QueryData
    data2.count.must_equal 3
    mock.verify
  end

  it "queries the data with max option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    query_request.max_results = 42
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, max: 42
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end

  it "queries the data with dataset option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    query_request.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      dataset_id: "some_random_dataset", project_id: project
    )
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, dataset: "some_random_dataset"
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end

  it "queries the data with dataset and project options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    query_request.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      dataset_id: "some_random_dataset", project_id: "some_random_project"
    )
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, dataset: "some_random_dataset",
                                 project: "some_random_project"
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end

  it "queries the data with timeout option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    query_request.timeout_ms = 15000
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, timeout: 15000
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end

  it "queries the data with dryrun option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    query_request.dry_run = true
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, dryrun: true
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end

  it "queries the data with cache option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :query_job, query_data_gapi, [project, query_request]

    data = bigquery.query query, cache: true
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    mock.verify
  end
end
