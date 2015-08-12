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

describe Gcloud::Bigquery::Data, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_hash) { random_table_hash dataset_id, table_id, table_name, description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "returns data as a list of hashes" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data
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

  it "knows the data metadata" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "knows the raw, unformatted data" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data

    data.raw.wont_be :nil?
    data.raw.count.must_equal data.count
    data.raw[0][0].must_equal data[0]["name"].to_s
    data.raw[0][1].must_equal data[0]["age"].to_s
    data.raw[0][2].must_equal data[0]["score"].to_s
    data.raw[0][3].must_equal data[0]["active"].to_s

    data.raw[1][0].must_equal data[1]["name"].to_s
    data.raw[1][1].must_equal data[1]["age"].to_s
    data.raw[1][2].must_equal data[1]["score"].to_s
    data.raw[1][3].must_equal data[1]["active"].to_s

    data.raw[2][0].must_equal data[2]["name"].to_s
    data.raw[2][1].must_equal nil
    data.raw[2][2].must_equal nil
    data.raw[2][3].must_equal nil
  end

  it "knows the data metadata" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  it "paginates data" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "token1234567890"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data1 = table.data
    data1.class.must_equal Gcloud::Bigquery::Data
    data1.token.wont_be :nil?
    data1.token.must_equal "token1234567890"
    data2 = table.data token: data1.token
    data2.class.must_equal Gcloud::Bigquery::Data
  end

  it "paginates data using next? and next" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "token1234567890"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data1 = table.data
    data1.class.must_equal Gcloud::Bigquery::Data
    data1.token.wont_be :nil?
    data1.next?.must_equal true # can't use must_be :next?
    data2 = data1.next
    data2.class.must_equal Gcloud::Bigquery::Data
  end

  it "paginates data with max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data max: 3
    data.class.must_equal Gcloud::Bigquery::Data
  end

  it "paginates data without max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data
  end

  it "paginates data with start set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.must_include "startIndex"
      env.params["startIndex"].must_equal "25"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data start: 25
    data.class.must_equal Gcloud::Bigquery::Data
  end

  it "paginates data without start set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      env.params.wont_include "startIndex"
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
    data.class.must_equal Gcloud::Bigquery::Data
  end

  def table_data_json
    table_data_hash.to_json
  end

  def table_data_hash
    {
      "kind" => "bigquery#tableDataList",
      "etag" => "etag1234567890",
      "rows" => [
        {
          "f" => [
            {
              "v" => "Heidi"
            },
            {
              "v" => "36"
            },
            {
              "v" => "7.65"
            },
            {
              "v" => "true"
            }
          ]
        },
        {
          "f" => [
            {
              "v" => "Aaron"
            },
            {
              "v" => "42"
            },
            {
              "v" => "8.15"
            },
            {
              "v" => "false"
            }
          ]
        },
        {
          "f" => [
            {
              "v" => "Sally"
            },
            {
              "v" => nil
            },
            {
              "v" => nil
            },
            {
              "v" => nil
            }
          ]
        }
      ],
      "pageToken" => "token1234567890",
      "totalRows" => 3
    }
  end
end
