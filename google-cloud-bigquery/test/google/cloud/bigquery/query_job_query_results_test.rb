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

describe Google::Cloud::Bigquery::QueryJob, :query_results, :mock_bigquery do
  let(:query_request) {
    qrg = query_request_gapi
    qrg.default_dataset = nil
    qrg.query = "SELECT * FROM test-project:my_dataset.my_view"
    qrg
  }
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi query_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "can retrieve query results" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]

    data = job.query_results
    data.class.must_equal Google::Cloud::Bigquery::QueryData
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
    mock.verify
  end

  it "paginates data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data1 = job.query_results
    data1.class.must_equal Google::Cloud::Bigquery::QueryData
    data1.token.wont_be :nil?
    data1.token.must_equal "token1234567890"
    data2 = job.query_results token: data1.token
    data2.class.must_equal Google::Cloud::Bigquery::QueryData
    mock.verify
  end

  it "paginates data using next? and next" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :get_job_query_results,
                query_data_gapi(token: nil),
                [project, job.job_id, {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data1 = job.query_results
    data1.class.must_equal Google::Cloud::Bigquery::QueryData
    data1.token.wont_be :nil?
    data1.next?.must_equal true
    data2 = data1.next
    data2.token.must_be :nil?
    data2.next?.must_equal false
    data2.class.must_equal Google::Cloud::Bigquery::QueryData
    mock.verify
  end

  it "paginates data using all" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :get_job_query_results,
                query_data_gapi(token: nil),
                [project, job.job_id, {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data = job.query_results.all.to_a
    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "paginates data using all using Enumerator" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data = job.query_results.all.take(5)
    data.count.must_equal 5
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "iterates data using all with request_limit set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: "token1234567890", start_index: nil, timeout_ms: nil}]

    data = job.query_results.all(request_limit: 1).to_a
    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "paginates data with max set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: 3, page_token: nil, start_index: nil, timeout_ms: nil}]

    data = job.query_results max: 3
    data.class.must_equal Google::Cloud::Bigquery::QueryData
    mock.verify
  end

  it "paginates data with start set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: 25, timeout_ms: nil}]

    data = job.query_results start: 25
    data.class.must_equal Google::Cloud::Bigquery::QueryData
    mock.verify
  end

  it "paginates data with timeout set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job.job_id, {max_results: nil, page_token: nil, start_index: nil, timeout_ms: 1000}]

    data = job.query_results timeout: 1000
    data.class.must_equal Google::Cloud::Bigquery::QueryData
    mock.verify
  end

  def query_job_gapi
    Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
  end

  def query_job_hash
    hash = random_job_hash("job9876543210")
    hash["configuration"]["query"] = {
      "query" => "SELECT name, age, score, active FROM `users`",
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "tableDefinitions" => {},
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY",
      "defaultDataset" => {
        "datasetId" => "my_dataset",
        "projectId" => project
      },
      "priority" => "BATCH",
      "allowLargeResults" => true,
      "useQueryCache" => true,
      "flattenResults" => true,
      "useLegacySql" => false,
    }
    hash
  end
end
