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
  let(:table_hash) {
    hash = random_table_hash dataset_id, table_id, table_name, description
    hash["schema"] = table_schema["schema"]
    hash
  }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "returns data as a list of hashes" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}/data" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_data_json]
    end

    data = table.data
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
    data.kind.must_equal "bigquery#tableDataList"
    data.etag.must_equal "etag1234567890"
    data.token.must_equal "token1234567890"
    data.total.must_equal 3
  end

  # TODO: maxResults	unsigned integer	Maximum number of results to return
  # TODO: pageToken	string	Page token, returned by a previous call, identifying the result set
  # TODO: startIndex	unsigned long	Zero-based index of the starting row to read
  # TODO: get raw rows from the data (data.raw)
  # data.raw.count.must_equal 3
  # data.raw[0].must_equal "Mike"
  # data.raw[0].must_equal "41"
  # data.raw[0].must_equal "7.65"
  # data.raw[0].must_equal "true"
  # TODO: get headers/fields from table

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

  def table_schema
    {
      "schema" => {
        "fields" => [
          {
            "name" => "name",
            "type" => "STRING",
            "mode" => "NULLABLE"
          },
          {
            "name" => "age",
            "type" => "INTEGER",
            "mode" => "NULLABLE"
          },
          {
            "name" => "score",
            "type" => "FLOAT",
            "mode" => "NULLABLE"
          },
          {
            "name" => "active",
            "type" => "BOOLEAN",
            "mode" => "NULLABLE"
          }
        ]
      }
    }
  end
end
