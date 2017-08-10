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

describe Google::Cloud::Bigquery::View, :data, :mock_bigquery do
  let(:query_request) {
    qrg = query_request_gapi
    qrg.default_dataset = nil
    qrg.query = "SELECT * FROM `test-project.my_dataset.my_view`"
    qrg.use_legacy_sql = false
    qrg
  }
  let(:query) { "SELECT * FROM `test-project.my_dataset.my_view`" }
  let(:job_id) { "job_9876543210" }

  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" }
  let(:view_gapi) { random_view_gapi dataset_id, table_id, table_name, description }
  let(:view) { Google::Cloud::Bigquery::View.from_gapi view_gapi,
                                                bigquery.service }

  it "returns data as a list of hashes" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = view.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.count.must_equal 3
    data[0].must_be_kind_of Hash
    data[0][:name].must_equal "Heidi"
    data[0][:age].must_equal 36
    data[0][:score].must_equal 7.65
    data[0][:active].must_equal true

    data[1].must_be_kind_of Hash
    data[1][:name].must_equal "Aaron"
    data[1][:age].must_equal 42
    data[1][:score].must_equal 8.15
    data[1][:active].must_equal false

    data[2].must_be_kind_of Hash
    data[2][:name].must_equal "Sally"
    data[2][:age].must_equal nil
    data[2][:score].must_equal nil
    data[2][:active].must_equal nil
  end

  it "knows the data metadata" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = view.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "knows the raw, unformatted data" do
    skip
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = view.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data

    data.raw.wont_be :nil?
    data.raw.count.must_equal data.count
    data.raw[0][0].must_equal data[0]["name"].to_s
    data.raw[0][1].must_equal data[0]["age"].to_s
    data.raw[0][2].must_equal data[0]["score"].to_s
    data.raw[0][3].must_equal data[0]["active"].to_s
    data.raw[0][4].must_equal Base64.strict_encode64(data[0]["avatar"].read)
    data.raw[0][5].must_equal "1482670800.0"

    data.raw[1][0].must_equal data[1]["name"].to_s
    data.raw[1][1].must_equal data[1]["age"].to_s
    data.raw[1][2].must_equal data[1]["score"].to_s
    data.raw[1][3].must_equal data[1]["active"].to_s
    data.raw[1][4].must_equal nil
    data.raw[1][5].must_equal nil

    data.raw[2][0].must_equal data[2]["name"].to_s
    data.raw[2][1].must_equal nil
    data.raw[2][2].must_equal nil
    data.raw[2][3].must_equal nil
    data.raw[2][4].must_equal nil
    data.raw[2][5].must_equal nil
  end

  it "paginates data using next? and next" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: "token1234567890", start_index: nil }]

    data1 = view.data
    data1.class.must_equal Google::Cloud::Bigquery::Data
    data1.token.wont_be :nil?
    data1.next?.must_equal true # can't use must_be :next?
    data2 = data1.next
    data2.class.must_equal Google::Cloud::Bigquery::Data
    mock.verify
  end

  it "raises when the job fails with reason accessDenied" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, failed_query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]

    err = expect { view.data }.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_equal "string"
    if err.respond_to? :cause
      err.cause.body.must_equal({
        "debugInfo"=>"string",
        "location"=>"string",
        "message"=>"string",
        "reason"=>"accessDenied",
        "errors"=>[{
          "debugInfo"=>"string",
          "location"=>"string",
          "message"=>"string",
          "reason"=>"accessDenied"
        }]
      })
    end

    mock.verify
  end

  it "raises when the job fails with reason backendError" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.priority = nil

    mock.expect :insert_job, failed_query_job_resp_gapi(query, job_id: job_id, reason: "backendError"), [project, job_gapi]

    err = expect { view.data }.must_raise Google::Cloud::InternalError
    err.message.must_equal "string"
    if err.respond_to? :cause
      err.cause.body.must_equal({
        "debugInfo"=>"string",
        "location"=>"string",
        "message"=>"string",
        "reason"=>"backendError",
        "errors"=>[{
          "debugInfo"=>"string",
          "location"=>"string",
          "message"=>"string",
          "reason"=>"backendError"
        }]
      })
    end

    mock.verify
  end
end
