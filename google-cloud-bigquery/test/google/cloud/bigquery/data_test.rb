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
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.count.must_equal 3
    data[0].must_be_kind_of Hash
    data[0]["name"].must_equal "Heidi"
    data[0]["age"].must_equal 36
    data[0]["score"].must_equal 7.65
    data[0]["active"].must_equal true
    data[0]["avatar"].must_be_kind_of StringIO
    data[0]["avatar"].read.must_equal "image data"
    data[1].must_be_kind_of Hash
    data[1]["name"].must_equal "Aaron"
    data[1]["age"].must_equal 42
    data[1]["score"].must_equal 8.15
    data[1]["active"].must_equal false
    data[1]["avatar"].must_equal nil
    data[2].must_be_kind_of Hash
    data[2]["name"].must_equal "Sally"
    data[2]["age"].must_equal nil
    data[2]["score"].must_equal nil
    data[2]["active"].must_equal nil
    data[2]["avatar"].must_equal nil
  end

  it "knows the data metadata" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "knows the raw, unformatted data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data

    data.raw.wont_be :nil?
    data.raw.count.must_equal data.count
    data.raw[0][0].must_equal data[0]["name"].to_s
    data.raw[0][1].must_equal data[0]["age"].to_s
    data.raw[0][2].must_equal data[0]["score"].to_s
    data.raw[0][3].must_equal data[0]["active"].to_s
    data.raw[0][4].must_equal Base64.strict_encode64(data[0]["avatar"].read)

    data.raw[1][0].must_equal data[1]["name"].to_s
    data.raw[1][1].must_equal data[1]["age"].to_s
    data.raw[1][2].must_equal data[1]["score"].to_s
    data.raw[1][3].must_equal data[1]["active"].to_s
    data.raw[1][4].must_equal nil

    data.raw[2][0].must_equal data[2]["name"].to_s
    data.raw[2][1].must_equal nil
    data.raw[2][2].must_equal nil
    data.raw[2][3].must_equal nil
    data.raw[2][4].must_equal nil
  end

  it "knows the data metadata" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]

    data = table.data
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "handles missing rows and fields" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                nil_table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]

    nil_data = table.data
    mock.verify

    nil_data.class.must_equal Google::Cloud::Bigquery::Data
    nil_data.count.must_equal 0
  end

  it "paginates data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

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
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil),
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

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
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil),
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

    data = table.data.all.to_a

    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "iterates data using all" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi(token: nil),
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

    data = table.data

    data.all { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "iterates data using all using Enumerator" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

    data = table.data.all.take(5)

    data.count.must_equal 5
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "iterates data using all with request_limit set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: nil }]
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: "token1234567890", start_index: nil }]

    data = table.data.all(request_limit: 1).to_a

    data.count.must_equal 6
    data.each { |d| d.class.must_equal Hash }
    mock.verify
  end

  it "paginates data with max set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: 3, page_token: nil, start_index: nil }]

    data = table.data max: 3
    data.class.must_equal Google::Cloud::Bigquery::Data
  end

  it "paginates data with start set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    mock.expect :list_table_data,
                table_data_gapi,
                [project, dataset_id, table_id, {  max_results: nil, page_token: nil, start_index: 25 }]

    data = table.data start: 25
    mock.verify

    data.class.must_equal Google::Cloud::Bigquery::Data
  end

  def table_data_gapi token: "token1234567890"
    Google::Apis::BigqueryV2::TableDataList.from_json table_data_hash(token: token).to_json
  end

  def table_data_hash token: "token1234567890"
    {
      "kind" => "bigquery#tableDataList",
      "etag" => "etag1234567890",
      "rows" => [
        {
          "f" => [
            { "v" => "Heidi" },
            { "v" => "36" },
            { "v" => "7.65" },
            { "v" => "true" },
            { "v" => "aW1hZ2UgZGF0YQ==" }
          ]
        },
        {
          "f" => [
            { "v" => "Aaron" },
            { "v" => "42" },
            { "v" => "8.15" },
            { "v" => "false" },
            { "v" => nil }
          ]
        },
        {
          "f" => [
            { "v" => "Sally" },
            { "v" => nil },
            { "v" => nil },
            { "v" => nil },
            { "v" => nil }
          ]
        }
      ],
      "pageToken" => token,
      "totalRows" => "3" # String per google/google-api-ruby-client#439
    }
  end

  def nil_table_data_gapi
    Google::Apis::BigqueryV2::TableDataList.from_json nil_table_data_json
  end

  def nil_table_data_json
    h = table_data_hash
    h.delete "rows"
    h.to_json
  end
end
