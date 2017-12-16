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

describe Google::Cloud::Bigquery::Project, :query_job, :positional_params, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active, create_date, update_timestamp FROM `some_project.some_dataset.users`" }

  let(:dataset_id) { "my_dataset" }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  let(:table_id) { "my_table" }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  let(:query_job_gapi) do
    Google::Apis::BigqueryV2::Job.from_json(query_job_json("SELECT * FROM tbl")).tap do |r|
      r.configuration.query.use_legacy_sql = false
      r.configuration.query.parameter_mode = "POSITIONAL"
    end
  end
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }

  it "queries the data with a string parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE name = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE name = ?", params: ["Testy McTesterson"]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with an integer parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE age > ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE age > ?", params: [35]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a float parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE score > ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE score > ?", params: [90.0]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a true parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE active = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE active = ?", params: [true]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a false parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE active = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE active = ?", params: [false]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a date parameter" do
    today = Date.today

    query_job_gapi.configuration.query.query = "#{query} WHERE create_date = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE create_date = ?", params: [today]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a datetime parameter" do
    now = DateTime.now

    query_job_gapi.configuration.query.query = "#{query} WHERE update_datetime < ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE update_datetime < ?", params: [now]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a timestamp parameter" do
    now = ::Time.now

    query_job_gapi.configuration.query.query = "#{query} WHERE update_timestamp < ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE update_timestamp < ?", params: [now]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a time parameter" do
    timeofday = bigquery.time 16, 0, 0

    query_job_gapi.configuration.query.query = "#{query} WHERE create_time = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE create_time = ?", params: [timeofday]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a File parameter" do
    file = File.open "acceptance/data/logo.jpg", "rb"

    query_job_gapi.configuration.query.query = "#{query} WHERE avatar = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE avatar = ?", params: [file]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a StringIO parameter" do
    file = StringIO.new File.read("acceptance/data/logo.jpg", mode: "rb")

    query_job_gapi.configuration.query.query = "#{query} WHERE avatar = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE avatar = ?", params: [file]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with many parameters" do
    today = Date.today
    now = ::Time.now

    query_job_gapi.configuration.query.query = "#{query} WHERE name = ?" +
                                                       " AND age > ?" +
                                                       " AND score > ?" +
                                                       " AND active = ?" +
                                                       " AND create_date = ?" +
                                                       " AND update_timestamp < ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE name = ?" +
                                           " AND age > ?" +
                                           " AND score > ?" +
                                           " AND active = ?" +
                                           " AND create_date = ?" +
                                           " AND update_timestamp < ?",
      params: ["Testy McTesterson", 35, 90.0, true, today, now]


    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with an array parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE name = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE name = ?", params: [%w{name1 name2 name3}]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with a struct parameter" do
    query_job_gapi.configuration.query.query = "#{query} WHERE meta = ?"
    query_job_gapi.configuration.query.query_parameters = [
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
    mock.expect :insert_job, query_job_gapi, [project, query_job_gapi]

    job = bigquery.query_job "#{query} WHERE meta = ?", params: [{name: "Testy McTesterson", age: 42, active: false, score: 98.7}]
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end
end
