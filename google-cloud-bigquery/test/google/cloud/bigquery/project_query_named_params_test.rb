# Copyright 2016 Google LLC
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

describe Google::Cloud::Bigquery::Project, :query, :named_params, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active, create_date, update_timestamp FROM `some_project.some_dataset.users`" }
  let(:job_id) { "job_9876543210" }

  let(:dataset_id) { "my_dataset" }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  let(:table_id) { "my_table" }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }

  it "queries the data with a string parameter" do
    job_gapi = query_job_gapi "#{query} WHERE name = @name", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "name",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE name = @name", params: { name: "Testy McTesterson" }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an integer parameter" do
    job_gapi = query_job_gapi "#{query} WHERE age > @age", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "age",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "35"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE age > @age", params: { age: 35 }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an integer parameter with types option" do
    job_gapi = query_job_gapi "#{query} WHERE age > @age", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "age",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "35"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE age > @age", params: { age: "35" }, types: { age: :INT64 }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a float parameter" do
    job_gapi = query_job_gapi "#{query} WHERE score > @score", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "score",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "90.0"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE score > @score", params: { score: 90.0 }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a numeric parameter" do
    job_gapi = query_job_gapi "#{query} WHERE pi = @pi", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "pi",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "NUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "3.141592654"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE pi = @pi", params: { pi: BigDecimal("3.141592654") }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a bignumeric parameter and types option" do
    job_gapi = query_job_gapi "#{query} WHERE my_bignumeric = @my_bignumeric", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "my_bignumeric",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BIGNUMERIC"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "123456798.98765432100001"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE my_bignumeric = @my_bignumeric",
                          params: { my_bignumeric: BigDecimal("123456798.98765432100001") },
                          types: { my_bignumeric: :BIGNUMERIC}
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a true parameter" do
    job_gapi = query_job_gapi "#{query} WHERE active = @active", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "active",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "true"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE active = @active", params: { active: true }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a false parameter" do
    job_gapi = query_job_gapi "#{query} WHERE active = @active", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "active",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "false"
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE active = @active", params: { active: false }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a date parameter" do
    today = Date.today

    job_gapi = query_job_gapi "#{query} WHERE create_date = @day", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "day",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE create_date = @day", params: { day: today }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a datetime parameter" do
    now = DateTime.now

    job_gapi = query_job_gapi "#{query} WHERE update_datetime < @when", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "when",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE update_datetime < @when", params: { when: now }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a timestamp parameter" do
    now = ::Time.now

    job_gapi = query_job_gapi "#{query} WHERE update_timestamp < @when", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "when",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE update_timestamp < @when", params: { when: now }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a time parameter" do
    timeofday = bigquery.time 16, 0, 0

    job_gapi = query_job_gapi "#{query} WHERE create_time = @time", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "time",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE create_time = @time", params: { time: timeofday }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a File parameter" do
    file = File.open "acceptance/data/logo.jpg", "rb"

    job_gapi = query_job_gapi "#{query} WHERE avatar = @file", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "file",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE avatar = @file", params: { file: file }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a StringIO parameter" do
    file = StringIO.new File.read("acceptance/data/logo.jpg", mode: "rb")

    job_gapi = query_job_gapi "#{query} WHERE avatar = @file", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "file",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE avatar = @file", params: { file: file }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with many parameters" do
    today = Date.today
    now = ::Time.now

    job_gapi = query_job_gapi "#{query} WHERE name = @name" +
                                       " AND age > @age" +
                                       " AND score > @score" +
                                       " AND active = @active" +
                                       " AND create_date = @date" +
                                       " AND update_timestamp < @time", parameter_mode: "NAMED", location: nil

    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "name",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRING"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "Testy McTesterson"
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "age",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "INT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "35"
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "score",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "FLOAT64"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "90.0"
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "active",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "BOOL"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: "true"
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "date",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "DATE"
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          value: today.to_s
        )
      ),
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "time",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE name = @name" +
                                  " AND age > @age" +
                                  " AND score > @score" +
                                  " AND active = @active" +
                                  " AND create_date = @date" +
                                  " AND update_timestamp < @time",
                          params: { name: "Testy McTesterson",
                                    age: 35,
                                    score: 90.0,
                                    active: true,
                                    date: today,
                                    time: now }


    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an array of string values parameter" do
    job_gapi = query_job_gapi "#{query} WHERE name IN @names", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "names",
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
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE name IN @names", params: { names: %w{name1 name2 name3} }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an array of bignumeric values parameter" do
    param_1 = BigDecimal("123456789.1234567891")
    param_2 = BigDecimal("123456789.1234567892")
    param_3 = BigDecimal("123456789.1234567893")
    job_gapi = query_job_gapi "#{query} WHERE my_bignumeric IN @my_params", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "my_params",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "BIGNUMERIC"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          array_values: [
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "123456789.1234567891"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "123456789.1234567892"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "123456789.1234567893")
          ]
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE my_bignumeric IN @my_params",
                          params: { my_params: [param_1, param_2, param_3] },
                          types: { my_params: [:BIGNUMERIC] }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with an array parameter with types option" do
    job_gapi = query_job_gapi "#{query} WHERE age IN @ages", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "ages",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "ARRAY",
          array_type: Google::Apis::BigqueryV2::QueryParameterType.new(
            type: "INT64"
          )
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          array_values: [
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "1"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "2"),
            Google::Apis::BigqueryV2::QueryParameterValue.new(value: "3")
          ]
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE age IN @ages", params: { ages: ["1", "2", "3"] }, types: { ages: [:INT64] }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a struct parameter" do
    job_gapi = query_job_gapi "#{query} WHERE meta = @meta", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters = [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "meta",
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
            "name"   => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "Testy McTesterson"),
            "age"    => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "42"),
            "active" => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "false"),
            "score"  => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "98.7")
          }
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE meta = @meta", params: { meta: { name: "Testy McTesterson", age: 42, active: false, score: 98.7 } }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  it "queries the data with a struct parameter with types option" do
    job_gapi = query_job_gapi "#{query} WHERE meta = @meta", parameter_mode: "NAMED", location: nil
    job_gapi.configuration.query.query_parameters =  [
      Google::Apis::BigqueryV2::QueryParameter.new(
        name: "meta",
        parameter_type: Google::Apis::BigqueryV2::QueryParameterType.new(
          type: "STRUCT",
          struct_types: [
            Google::Apis::BigqueryV2::QueryParameterType::StructType.new(
              name: "age",
              type: Google::Apis::BigqueryV2::QueryParameterType.new(type: "INT64"))
          ]
        ),
        parameter_value: Google::Apis::BigqueryV2::QueryParameterValue.new(
          struct_values: {
            "age"    => Google::Apis::BigqueryV2::QueryParameterValue.new(value: "42")
          }
        )
      )
    ]

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    data = bigquery.query "#{query} WHERE meta = @meta", params: { meta: { age: "42" } }, types: { meta: { age: :INT64 } }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  def assert_valid_data data
    _(data.count).must_equal 3
    _(data[0]).must_be_kind_of Hash
    _(data[0][:name]).must_equal "Heidi"
    _(data[0][:age]).must_equal 36
    _(data[0][:score]).must_equal 7.65
    _(data[0][:active]).must_equal true
    _(data[1]).must_be_kind_of Hash
    _(data[1][:name]).must_equal "Aaron"
    _(data[1][:age]).must_equal 42
    _(data[1][:score]).must_equal 8.15
    _(data[1][:active]).must_equal false
    _(data[2]).must_be_kind_of Hash
    _(data[2][:name]).must_equal "Sally"
    _(data[2][:age]).must_be :nil?
    _(data[2][:score]).must_be :nil?
    _(data[2][:active]).must_be :nil?
  end
end
