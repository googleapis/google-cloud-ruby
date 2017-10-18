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

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.count.must_equal 3
    data[0].must_be_kind_of Hash
    data[0][:name].must_equal "Heidi"
    data[0][:age].must_equal 36
    data[0][:score].must_equal 7.65
    data[0][:active].must_equal true
    data[0][:avatar].must_be_kind_of StringIO
    data[0][:avatar].read.must_equal "image data"
    data[0][:started_at].must_equal Time.parse("2016-12-25 13:00:00 UTC")
    data[0][:duration].must_equal Google::Cloud::Bigquery::Time.new("04:00:00")
    data[0][:target_end].must_equal Time.parse("2017-01-01 00:00:00 UTC").to_datetime
    data[0][:birthday].must_equal Date.parse("1968-10-20")

    data[1].must_be_kind_of Hash
    data[1][:name].must_equal "Aaron"
    data[1][:age].must_equal 42
    data[1][:score].must_equal 8.15
    data[1][:active].must_equal false
    data[1][:avatar].must_be :nil?
    data[1][:started_at].must_be :nil?
    data[1][:duration].must_equal Google::Cloud::Bigquery::Time.new("04:32:10.555555")
    data[1][:target_end].must_be :nil?
    data[1][:birthday].must_be :nil?

    data[2].must_be_kind_of Hash
    data[2][:name].must_equal "Sally"
    data[2][:age].must_be :nil?
    data[2][:score].must_be :nil?
    data[2][:active].must_be :nil?
    data[2][:avatar].must_be :nil?
    data[2][:started_at].must_be :nil?
    data[2][:duration].must_be :nil?
    data[2][:target_end].must_be :nil?
    data[2][:birthday].must_be :nil?
  end

  it "knows the data metadata" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "knows schema, fields, and headers" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data
    mock.verify

    data.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    data.schema.must_be :frozen?
    data.fields.must_equal data.schema.fields
    data.headers.must_equal [:name, :age, :score, :active, :avatar, :started_at, :duration, :target_end, :birthday]
  end

  it "handles missing rows and fields" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                nil_table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    nil_data = table.data
    mock.verify

    nil_data.class.must_equal Google::Cloud::Bigquery::Data
    nil_data.count.must_equal 0
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

    nested_data.class.must_equal Google::Cloud::Bigquery::Data
    nested_data.count.must_equal 1

    nested_data.must_equal [{ nums: [1, 2, 3], scores: [100.0, 99.9, 0.001], msgs: ["hello", "world"], flags: [true, false] }]
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

    nested_data.class.must_equal Google::Cloud::Bigquery::Data
    nested_data.count.must_equal 1

    nested_data.must_equal [{ name: "mike", foo: [{ bar: "hey", baz: { bif: 1 } }, { bar: "world", baz: { bif: 2 } }] }]
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

    data1.class.must_equal Google::Cloud::Bigquery::Data
    data1.token.wont_be :nil?
    data1.token.must_equal "token1234567890"
    data2 = table.data token: data1.token
    data2.class.must_equal Google::Cloud::Bigquery::Data
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

    data1.class.must_equal Google::Cloud::Bigquery::Data
    data1.token.wont_be :nil?
    data1.next?.must_equal true # can't use must_be :next?
    data2 = data1.next
    data2.token.must_be :nil?
    data2.next?.must_equal false
    data2.class.must_equal Google::Cloud::Bigquery::Data
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

    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
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

    data.all { |d| d.class.must_equal Hash }
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

    data.count.must_equal 5
    data.each { |d| d.class.must_equal Hash }
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

    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "paginates data with max set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: 3, page_token: nil, start_index: nil, options: {skip_deserialization: true} }]

    data = table.data max: 3
    data.class.must_equal Google::Cloud::Bigquery::Data
  end

  it "paginates data with start set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: 25, options: {skip_deserialization: true} }]

    data = table.data start: 25
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
  end
end
