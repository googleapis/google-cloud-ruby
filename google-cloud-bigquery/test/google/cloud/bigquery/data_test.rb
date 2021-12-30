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

describe Google::Cloud::Bigquery::Data, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id, table_name, description }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }

  it "returns data as a list of hashes" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.count).must_equal 3
    _(data[0]).must_be_kind_of Hash
    _(data[0][:name]).must_equal "Heidi"
    _(data[0][:age]).must_equal 36
    _(data[0][:score]).must_equal 7.65
    _(data[0][:pi]).must_equal BigDecimal("3.141592654")
    _(data[0][:active]).must_equal true
    _(data[0][:avatar]).must_be_kind_of StringIO
    _(data[0][:avatar].read).must_equal "image data"
    _(data[0][:started_at]).must_equal Time.parse("2016-12-25 13:00:00 UTC")
    _(data[0][:duration]).must_equal Google::Cloud::Bigquery::Time.new("04:00:00")
    _(data[0][:target_end]).must_equal Time.parse("2017-01-01 00:00:00 UTC").to_datetime
    _(data[0][:birthday]).must_equal Date.parse("1968-10-20")
    _(data[0][:home]).must_equal "POINT(-122.335503 47.625536)"

    _(data[1]).must_be_kind_of Hash
    _(data[1][:name]).must_equal "Aaron"
    _(data[1][:age]).must_equal 42
    _(data[1][:score]).must_equal 8.15
    _(data[1][:pi]).must_be :nil?
    _(data[1][:active]).must_equal false
    _(data[1][:avatar]).must_be :nil?
    _(data[1][:started_at]).must_be :nil?
    _(data[1][:duration]).must_equal Google::Cloud::Bigquery::Time.new("04:32:10.555555")
    _(data[1][:target_end]).must_be :nil?
    _(data[1][:birthday]).must_be :nil?

    _(data[2]).must_be_kind_of Hash
    _(data[2][:name]).must_equal "Sally"
    _(data[2][:age]).must_be :nil?
    _(data[2][:score]).must_be :nil?
    _(data[2][:pi]).must_be :nil?
    _(data[2][:active]).must_be :nil?
    _(data[2][:avatar]).must_be :nil?
    _(data[2][:started_at]).must_be :nil?
    _(data[2][:duration]).must_be :nil?
    _(data[2][:target_end]).must_be :nil?
    _(data[2][:birthday]).must_be :nil?
  end

  it "knows the data metadata" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    _(data.kind).must_equal "bigquery#tableDataList"
    _(data.etag).must_equal "etag1234567890"
    _(data.token).must_equal "token1234567890"
    _(data.total).must_equal 3

    _(data.statement_type).must_be :nil?
    _(data.ddl?).must_equal false
    _(data.dml?).must_equal false
    _(data.ddl_operation_performed).must_be :nil?
    _(data.ddl_target_routine).must_be :nil?
    _(data.ddl_target_table).must_be :nil?
    _(data.num_dml_affected_rows).must_be :nil?
  end

  it "knows schema, fields, and headers" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    _(data.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(data.schema).must_be :frozen?
    _(data.fields).must_equal data.schema.fields
    _(data.headers).must_equal [:name, :age, :score, :pi, :my_bignumeric, :active, :avatar, :started_at, :duration, :target_end, :birthday, :home]
    _(data.param_types).must_equal({ name: :STRING, age: :INTEGER, score: :FLOAT, pi: :NUMERIC, my_bignumeric: :BIGNUMERIC, active: :BOOLEAN, avatar: :BYTES, started_at: :TIMESTAMP, duration: :TIME, target_end: :DATETIME, birthday: :DATE, home: :GEOGRAPHY })
  end

  it "handles missing rows and fields" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                nil_table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    nil_data = table.data
    mock.verify

    _(nil_data.class).must_equal Google::Cloud::Bigquery::Data
    _(nil_data.count).must_equal 0
  end

  it "handles repeated scalars" do
    schema_hash = {
      fields: [
          { name: "nums",   type: "INTEGER", mode: "REPEATED", fields: [] },
          { name: "scores", type: "FLOAT",   mode: "REPEATED", fields: [] },
          { name: "msgs",   type: "STRING",  mode: "REPEATED", fields: [] },
          { name: "flags",  type: "BOOLEAN", mode: "REPEATED", fields: [] }
        ]
    }
    rows_array = [
      { f: [
             { v: [{ v: "1" }, { v: "2" }, { v: "3" }] },
             { v: [{ v: "100.0" }, { v: "99.9" }, { v: "0.001"}] },
             { v: [{ v: "hello" }, { v: "world" }] },
             { v: [{ v: "true" }, { v: "false" }] }
           ]
      }
    ]

    nested_table_gapi = random_table_gapi dataset_id, table_id, table_name, description
    nested_table_gapi.schema = Google::Apis::BigqueryV2::TableSchema.from_json schema_hash.to_json
    nested_table = Google::Cloud::Bigquery::Table.from_gapi nested_table_gapi, bigquery.service

    nested_table_data_hash = table_data_hash
    nested_table_data_hash["rows"] = rows_array
    nested_table_data_gapi = Google::Apis::BigqueryV2::TableDataList.from_json nested_table_data_hash.to_json

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                nested_table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    nested_data = nested_table.data
    mock.verify

    _(nested_data.class).must_equal Google::Cloud::Bigquery::Data
    _(nested_data.count).must_equal 1

    _(nested_data).must_equal [{ nums: [1, 2, 3], scores: [100.0, 99.9, 0.001], msgs: ["hello", "world"], flags: [true, false] }]
  end

  it "handles nested, repeated records" do
    schema_hash = {
      fields: [
        { name: "name", type: "STRING", mode: "NULLABLE", fields: [] },
        { name: "foo",  type: "RECORD", mode: "REPEATED", fields: [
          { name: "bar", type: "STRING", mode: "NULLABLE", fields: []  },
          { name: "baz", type: "RECORD", mode: "NULLABLE", fields: [
            { name: "bif", type: "INTEGER", mode: "NULLABLE", fields: [] }
          ]}
        ]}
      ]
    }
    rows_array = [
      { f: [ { v: "mike"},
             { v: [ { v: { f: [ { v: "hey" },   { v: { f: [ { v: "1" } ] } } ] } },
                    { v: { f: [ { v: "world" }, { v: { f: [ { v: "2" } ] } } ] } }
                  ]
             }
           ]
      }
    ]

    nested_table_gapi = random_table_gapi dataset_id, table_id, table_name, description
    nested_table_gapi.schema = Google::Apis::BigqueryV2::TableSchema.from_json schema_hash.to_json
    nested_table = Google::Cloud::Bigquery::Table.from_gapi nested_table_gapi, bigquery.service

    nested_table_data_hash = table_data_hash
    nested_table_data_hash["rows"] = rows_array
    nested_table_data_gapi = Google::Apis::BigqueryV2::TableDataList.from_json nested_table_data_hash.to_json

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                nested_table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    nested_data = nested_table.data
    mock.verify

    _(nested_data.class).must_equal Google::Cloud::Bigquery::Data
    _(nested_data.count).must_equal 1

    _(nested_data).must_equal [{ name: "mike", foo: [{ bar: "hey", baz: { bif: 1 } }, { bar: "world", baz: { bif: 2 } }] }]
  end

  it "paginates data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data1 = table.data

    _(data1.class).must_equal Google::Cloud::Bigquery::Data
    _(data1.token).wont_be :nil?
    _(data1.token).must_equal "token1234567890"
    data2 = table.data token: data1.token
    _(data2.class).must_equal Google::Cloud::Bigquery::Data
    mock.verify
  end

  it "paginates data using next? and next" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil).to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data1 = table.data

    _(data1.class).must_equal Google::Cloud::Bigquery::Data
    _(data1.token).wont_be :nil?
    _(data1.next?).must_equal true # can't use must_be :next?
    data2 = data1.next
    _(data2.token).must_be :nil?
    _(data2.next?).must_equal false
    _(data2.class).must_equal Google::Cloud::Bigquery::Data
    mock.verify
  end

  it "paginates data using all" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil).to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data = table.data.all.to_a

    _(data.count).must_equal 6
    data.each { |d| _(d.class).must_equal Hash }
    mock.verify
  end

  it "iterates data using all" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil).to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data = table.data

    data.all { |d| _(d.class).must_equal Hash }
    mock.verify
  end

  it "iterates data using all using Enumerator" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data = table.data.all.take(5)

    _(data.count).must_equal 5
    data.each { |d| _(d.class).must_equal Hash }
    mock.verify
  end

  it "iterates data using all with request_limit set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil, options: {skip_deserialization: true} }]

    data = table.data.all(request_limit: 1).to_a

    _(data.count).must_equal 6
    data.each { |d| _(d.class).must_equal Hash }
    mock.verify
  end

  it "paginates data with max set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: 3, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data max: 3
    _(data.class).must_equal Google::Cloud::Bigquery::Data
  end

  it "paginates data with start set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: 25, options: {skip_deserialization: true} }]

    data = table.data start: 25
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
  end

  describe "statement_type" do
    let(:data_hash) { { totalRows: nil, rows: [] } }

    it "knows its DDL ALTER_TABLE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "ALTER_TABLE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "ALTER_TABLE"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL CREATE_MODEL statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "CREATE_MODEL"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "CREATE_MODEL"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL CREATE_TABLE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "CREATE_TABLE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "CREATE_TABLE"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL CREATE_TABLE_AS_SELECT statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "CREATE_TABLE_AS_SELECT"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "CREATE_TABLE_AS_SELECT"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL CREATE_VIEW statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "CREATE_VIEW"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "CREATE_VIEW"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL DROP_MODEL statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "DROP_MODEL"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "DROP_MODEL"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL DROP_TABLE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "DROP_TABLE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "DROP_TABLE"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DDL DROP_VIEW statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "DROP_VIEW"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "DROP_VIEW"
      _(data.ddl?).must_equal true
      _(data.dml?).must_equal false
    end

    it "knows its DML INSERT statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "INSERT"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "INSERT"
      _(data.ddl?).must_equal false
      _(data.dml?).must_equal true
    end

    it "knows its DML UPDATE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "UPDATE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "UPDATE"
      _(data.ddl?).must_equal false
      _(data.dml?).must_equal true
    end

    it "knows its DML MERGE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "MERGE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "MERGE"
      _(data.ddl?).must_equal false
      _(data.dml?).must_equal true
    end

    it "knows its DML DELETE statement type" do
      gapi = query_job_resp_gapi "query is ignored", statement_type: "DELETE"
      data = Google::Cloud::Bigquery::Data.from_gapi_json data_hash, nil, gapi, nil

      _(data.statement_type).must_equal "DELETE"
      _(data.ddl?).must_equal false
      _(data.dml?).must_equal true
    end
  end
end
