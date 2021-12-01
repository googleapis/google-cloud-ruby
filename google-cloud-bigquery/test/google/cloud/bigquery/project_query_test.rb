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

describe Google::Cloud::Bigquery::Project, :query, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM `some_project.some_dataset.users`" }
  let(:ddl_create_query) { "CREATE TABLE `my_dataset.my_table` (x INT64)" }
  let(:ddl_alter_query) { "ALTER TABLE `my_dataset.my_table` ADD COLUMN y STRING" }
  let(:dml_delete_query) { "DELETE `my_dataset.my_table` WHERE x = 103" }
  let(:dml_insert_query) { "INSERT `my_dataset.my_table` (x) VALUES(101),(102)" }
  let(:dml_update_query) { "UPDATE `my_dataset.my_table` SET x = x + 1 WHERE x IS NOT NULL" }

  let(:job_id) { "job_9876543210" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }
  let(:table_id) { "my_table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:session_id) { "mysessionid" }

  it "queries the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
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

  it "executes a DDL CREATE TABLE statement" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi ddl_create_query, location: nil
    resp_gapi = query_job_resp_gapi ddl_create_query, job_id: job_id, target_routine: true, target_table: true, statement_type: "CREATE_TABLE", ddl_operation_performed: "CREATE"
    mock.expect :insert_job, resp_gapi, [project, job_gapi]

    data = bigquery.query ddl_create_query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 0
    _(data.total).must_be :nil?

    _(data.statement_type).must_equal "CREATE_TABLE"
    _(data.ddl?).must_equal true
    _(data.dml?).must_equal false
    _(data.ddl_operation_performed).must_equal "CREATE"
    _(data.ddl_target_table).wont_be :nil?
    _(data.num_dml_affected_rows).must_be :nil?
    _(data.deleted_row_count).must_be :nil?
    _(data.inserted_row_count).must_be :nil?
    _(data.updated_row_count).must_be :nil?
    # in real life this example does not create a routine, but test the attribute here anyway
    _(data.ddl_target_routine).wont_be :nil?
  end

  it "executes a DDL ALTER TABLE statement" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi ddl_alter_query, location: nil
    resp_gapi = query_job_resp_gapi ddl_alter_query, job_id: job_id, target_routine: true, target_table: true, statement_type: "ALTER_TABLE", ddl_operation_performed: nil
    mock.expect :insert_job, resp_gapi, [project, job_gapi]

    data = bigquery.query ddl_alter_query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 0
    _(data.total).must_be :nil?

    _(data.statement_type).must_equal "ALTER_TABLE"
    _(data.ddl?).must_equal true
    _(data.dml?).must_equal false
    _(data.ddl_operation_performed).must_be :nil? # Incorrect? See https://github.com/googleapis/google-cloud-ruby/issues/16097
    _(data.ddl_target_table).wont_be :nil?
    _(data.num_dml_affected_rows).must_be :nil?
    _(data.deleted_row_count).must_be :nil?
    _(data.inserted_row_count).must_be :nil?
    _(data.updated_row_count).must_be :nil?
    # in real life this example does not create a routine, but test the attribute here anyway
    _(data.ddl_target_routine).wont_be :nil?
  end

  it "executes a DML DELETE statement" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi dml_delete_query, location: nil
    resp_gapi = query_job_resp_gapi dml_delete_query, job_id: job_id, statement_type: "DELETE", num_dml_affected_rows: 50, deleted_row_count: 50
    mock.expect :insert_job, resp_gapi, [project, job_gapi]

    data = bigquery.query dml_delete_query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 0
    _(data.total).must_be :nil?

    _(data.statement_type).must_equal "DELETE"
    _(data.ddl?).must_equal false
    _(data.dml?).must_equal true
    _(data.ddl_operation_performed).must_be :nil?
    _(data.num_dml_affected_rows).must_equal 50
    _(data.deleted_row_count).must_equal 50
    _(data.inserted_row_count).must_be :nil?
    _(data.updated_row_count).must_be :nil?
  end

  it "executes a DML INSERT statement" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi dml_insert_query, location: nil
    resp_gapi = query_job_resp_gapi dml_insert_query, job_id: job_id, statement_type: "INSERT", num_dml_affected_rows: 50, inserted_row_count: 50
    mock.expect :insert_job, resp_gapi, [project, job_gapi]

    data = bigquery.query dml_insert_query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 0
    _(data.total).must_be :nil?

    _(data.statement_type).must_equal "INSERT"
    _(data.ddl?).must_equal false
    _(data.dml?).must_equal true
    _(data.ddl_operation_performed).must_be :nil?
    _(data.num_dml_affected_rows).must_equal 50
    _(data.deleted_row_count).must_be :nil?
    _(data.inserted_row_count).must_equal 50
    _(data.updated_row_count).must_be :nil?
  end

  it "executes a DML UPDATE statement" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi dml_update_query, location: nil
    resp_gapi = query_job_resp_gapi dml_update_query, job_id: job_id, statement_type: "UPDATE", num_dml_affected_rows: 50, updated_row_count: 50
    mock.expect :insert_job, resp_gapi, [project, job_gapi]

    data = bigquery.query dml_update_query
    mock.verify
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 0
    _(data.total).must_be :nil?

    _(data.statement_type).must_equal "UPDATE"
    _(data.ddl?).must_equal false
    _(data.dml?).must_equal true
    _(data.ddl_operation_performed).must_be :nil?
    _(data.num_dml_affected_rows).must_equal 50
    _(data.deleted_row_count).must_be :nil?
    _(data.inserted_row_count).must_be :nil?
    _(data.updated_row_count).must_equal 50
  end

  it "paginates the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query
    # data.must_be_kind_of Google::Cloud::Bigquery::Data
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    _(data.token).must_equal "token1234567890"
    _(data.next?).must_equal true

    data2 = data.next
    _(data2.class).must_equal Google::Cloud::Bigquery::Data
    _(data2.count).must_equal 3
    mock.verify
  end

  it "queries the data with max option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: 42, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query, max: 42
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    mock.verify
  end

  it "queries the data with dataset option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      dataset_id: "some_random_dataset", project_id: project
    )

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query, dataset: "some_random_dataset"
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    mock.verify
  end

  it "queries the data with dataset and project options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      dataset_id: "some_random_dataset", project_id: "some_random_project"
    )

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query, dataset: "some_random_dataset",
                                 project: "some_random_project"
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    mock.verify
  end

  it "queries the data with cache option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.use_query_cache = false

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]


    data = bigquery.query query, cache: false
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    mock.verify
  end

  it "queries the data with session_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil, session_id: session_id
    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id, {location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil}]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id", {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = bigquery.query query, session_id: session_id
    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    mock.verify
  end

  it "raises when the job fails with reason accessDenied" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    mock.expect :insert_job, failed_query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]

    err = expect { bigquery.query query }.must_raise Google::Cloud::PermissionDeniedError
    _(err.message).must_equal "string"
    _(err.cause.body).must_equal({
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

    mock.verify
  end

  it "raises when the job fails with reason backendError" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query, location: nil
    mock.expect :insert_job, failed_query_job_resp_gapi(query, job_id: job_id, reason: "backendError"), [project, job_gapi]

    err = expect { bigquery.query query }.must_raise Google::Cloud::InternalError
    _(err.message).must_equal "string"
    _(err.cause.body).must_equal({
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

    mock.verify
  end
end
