# Copyright 2016 Google Inc. All rights reserved.
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

describe Google::Cloud::Bigquery::Project, :query, :positional_params, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active, create_date, update_timestamp FROM `some_project.some_dataset.users`" }
  let(:job_id) { "job9876543210" }

  let(:dataset_id) { "my_dataset" }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  let(:table_id) { "my_table" }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }

  it "queries the data with a string parameter" do
    job_gapi = query_job_gapi "#{query} WHERE name = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "Testy McTesterson"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE name = ?", params: ["Testy McTesterson"]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an integer parameter" do
    job_gapi = query_job_gapi "#{query} WHERE age > ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: 35
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE age > ?", params: [35]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a float parameter" do
    job_gapi = query_job_gapi "#{query} WHERE score > ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: 90.0
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE score > ?", params: [90.0]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a true parameter" do
    job_gapi = query_job_gapi "#{query} WHERE active = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: true
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE active = ?", params: [true]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a false parameter" do
    job_gapi = query_job_gapi "#{query} WHERE active = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: false
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE active = ?", params: [false]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a date parameter" do
    today = Date.today

    job_gapi = query_job_gapi "#{query} WHERE create_date = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: today.to_s
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE create_date = ?", params: [today]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a datetime parameter" do
    now = DateTime.now

    job_gapi = query_job_gapi "#{query} WHERE update_datetime < ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATETIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: now.strftime("%Y-%m-%d %H:%M:%S.%6N")
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE update_datetime < ?", params: [now]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a timestamp parameter" do
    now = ::Time.now

    job_gapi = query_job_gapi "#{query} WHERE update_timestamp < ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIMESTAMP"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: now.strftime("%Y-%m-%d %H:%M:%S.%6N%:z")
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE update_timestamp < ?", params: [now]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a time parameter" do
    timeofday = bigquery.time 16, 0, 0

    job_gapi = query_job_gapi "#{query} WHERE create_time = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIME"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: timeofday.value
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE create_time = ?", params: [timeofday]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a File parameter" do
    file = File.open "acceptance/data/logo.jpg", "rb"

    job_gapi = query_job_gapi "#{query} WHERE avatar = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BYTES"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: Base64.strict_encode64(File.read("acceptance/data/logo.jpg", mode: "rb"))
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE avatar = ?", params: [file]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a StringIO parameter" do
    file = StringIO.new File.read("acceptance/data/logo.jpg", mode: "rb")

    job_gapi = query_job_gapi "#{query} WHERE avatar = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BYTES"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: Base64.strict_encode64(File.read("acceptance/data/logo.jpg", mode: "rb"))
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE avatar = ?", params: [file]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with many parameters" do
    today = Date.today
    now = ::Time.now

    job_gapi = query_job_gapi "#{query} WHERE name = ?" +
                                       " AND age > ?" +
                                       " AND score > ?" +
                                       " AND active = ?" +
                                       " AND create_date = ?" +
                                       " AND update_timestamp < ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "Testy McTesterson"
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: 35
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: 90.0
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: true
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: today.to_s
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "TIMESTAMP"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: now.strftime("%Y-%m-%d %H:%M:%S.%6N%:z")
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE name = ?" +
                                  " AND age > ?" +
                                  " AND score > ?" +
                                  " AND active = ?" +
                                  " AND create_date = ?" +
                                  " AND update_timestamp < ?",
      params: ["Testy McTesterson", 35, 90.0, true, today, now]


    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an array parameter" do
    job_gapi = query_job_gapi "#{query} WHERE name IN ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "STRING"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          array_values: [
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "name1"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "name2"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "name3")
          ]
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE name IN ?", params: [%w{name1 name2 name3}]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a struct parameter" do
    job_gapi = query_job_gapi "#{query} WHERE meta = ?", parameter_mode: "POSITIONAL"
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRUCT",
          struct_types: [
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "name",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(type: "STRING")),
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "age",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(type: "INT64")),
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "active",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(type: "BOOL")),
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "score",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(type: "FLOAT64"))
          ]
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          struct_values: {
            "name" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "Testy McTesterson"),
            "age" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: 42),
            "active" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: false),
            "score" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: 98.7)
          }
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil }]

    data = bigquery.query "#{query} WHERE meta = ?", params: [{name: "Testy McTesterson", age: 42, active: false, score: 98.7}]
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  def assert_valid_data data
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
end
