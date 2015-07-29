# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a link of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Table, :insert, :mock_bigquery do
  let(:rows) { [{"name"=>"Heidi", "age"=>"36", "score"=>"7.65", "active"=>"true"},
                {"name"=>"Aaron", "age"=>"42", "score"=>"8.15", "active"=>"false"},
                {"name"=>"Sally", "age"=>nil, "score"=>nil, "active"=>nil}] }
  let(:dataset_id) { "dataset" }
  let(:table_hash) { random_table_hash dataset_id }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "can insert one row" do
    mock_connection.post "/bigquery/v2/projects/#{table.project_id}/datasets/#{table.dataset_id}/tables/#{table.table_id}/insertAll" do |env|
      json = JSON.parse(env.body)
      json.wont_include "skipInvalidRows"
      json.wont_include "ignoreUnknownValues"
      [200, {"Content-Type"=>"application/json"},
       success_table_insert_json]
    end

    result = table.insert rows.first
    result.must_be :success?
    result.insert_count.must_equal 1
    result.error_count.must_equal 0
  end

  it "can insert multiple rows" do
    mock_connection.post "/bigquery/v2/projects/#{table.project_id}/datasets/#{table.dataset_id}/tables/#{table.table_id}/insertAll" do |env|
      json = JSON.parse(env.body)
      json.wont_include "skipInvalidRows"
      json.wont_include "ignoreUnknownValues"
      [200, {"Content-Type"=>"application/json"},
       success_table_insert_json]
    end

    result = table.insert rows
    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "will indicate there was a problem with the data" do
    mock_connection.post "/bigquery/v2/projects/#{table.project_id}/datasets/#{table.dataset_id}/tables/#{table.table_id}/insertAll" do |env|
      json = JSON.parse(env.body)
      json.wont_include "skipInvalidRows"
      json.wont_include "ignoreUnknownValues"
      [200, {"Content-Type"=>"application/json"},
       failure_table_insert_json]
    end

    result = table.insert rows
    result.wont_be :success?
    result.insert_count.must_equal 2
    result.error_count.must_equal 1
    result.insert_errors.count.must_equal 1
    result.insert_errors.first.row.must_equal rows.first
    result.insert_errors.first.errors.count.must_equal 1
    result.insert_errors.first.errors.first["reason"].must_equal "r34s0n"
    result.insert_errors.first.errors.first["location"].must_equal "l0c4t10n"
    result.insert_errors.first.errors.first["debugInfo"].must_equal "d3bugInf0"
    result.insert_errors.first.errors.first["message"].must_equal "m3ss4g3"

    result.error_rows.first.must_equal rows.first
    first_row_errors = result.errors_for(rows.first)
    first_row_errors.count.must_equal 1
    first_row_errors.first["reason"].must_equal "r34s0n"
    first_row_errors.first["location"].must_equal "l0c4t10n"
    first_row_errors.first["debugInfo"].must_equal "d3bugInf0"
    first_row_errors.first["message"].must_equal "m3ss4g3"

    last_row_errors = result.errors_for(rows.last)
    last_row_errors.count.must_equal 0
  end

  it "can specify skipping invalid rows" do
    mock_connection.post "/bigquery/v2/projects/#{table.project_id}/datasets/#{table.dataset_id}/tables/#{table.table_id}/insertAll" do |env|
      json = JSON.parse(env.body)
      json.must_include "skipInvalidRows"
      json["skipInvalidRows"].must_equal true
      json.wont_include "ignoreUnknownValues"
      [200, {"Content-Type"=>"application/json"},
       success_table_insert_json]
    end

    result = table.insert rows, skip_invalid: true
    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  it "can specify ignoring unknown values" do
    mock_connection.post "/bigquery/v2/projects/#{table.project_id}/datasets/#{table.dataset_id}/tables/#{table.table_id}/insertAll" do |env|
      json = JSON.parse(env.body)
      json.wont_include "skipInvalidRows"
      json.must_include "ignoreUnknownValues"
      json["ignoreUnknownValues"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       success_table_insert_json]
    end

    result = table.insert rows, ignore_unknown: true
    result.must_be :success?
    result.insert_count.must_equal 3
    result.error_count.must_equal 0
  end

  def success_table_insert_json
    {
      "kind" => "bigquery#tableDataInsertAllResponse",
      "insertErrors" => []
    }.to_json
  end

  def failure_table_insert_json
    {
      "kind" => "bigquery#tableDataInsertAllResponse",
      "insertErrors" => [
        {
          "index" => 0,
          "errors" => [
            {
              "reason"    => "r34s0n",
              "location"  => "l0c4t10n",
              "debugInfo" => "d3bugInf0",
              "message"   => "m3ss4g3"
            }
          ]
        }
      ]
    }.to_json
  end
end
