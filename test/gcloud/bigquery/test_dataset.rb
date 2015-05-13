# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "json"
require "uri"

describe Gcloud::Bigquery::Dataset, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_name) { "my-dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { 999 }
  let(:dataset_hash) { random_dataset_hash dataset_name, description, default_expiration }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }
  let(:dataset_id) { dataset.dataset_id }

  it "knows its attributes" do
    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
  end

  it "knows its creation and modification times" do
    now = Time.now

    dataset.gapi["creationTime"] = nil
    dataset.created_at.must_be :nil?

    dataset.gapi["creationTime"] = (now.to_f * 1000).floor
    dataset.created_at.must_be_close_to now

    dataset.gapi["lastModifiedTime"] = nil
    dataset.modified_at.must_be :nil?

    dataset.gapi["lastModifiedTime"] = (now.to_f * 1000).floor
    dataset.modified_at.must_be_close_to now
  end

  it "can delete itself" do
    mock_connection.delete "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}" do |env|
      env.params.wont_include "deleteContents"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    dataset.delete
  end

  it "can delete itself and all table data" do
    mock_connection.delete "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}" do |env|
      env.params.must_include "deleteContents"
      env.params["deleteContents"].must_equal "true"
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    dataset.delete force: true
  end

  it "creates an empty table" do
    mock_connection.post "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      [200, {"Content-Type"=>"application/json"},
       create_table_json]
    end

    table = dataset.create_table
    table.must_be_kind_of Gcloud::Bigquery::Table
  end

  it "creates a table with a name and description" do
    name = "my-table"
    description = "This is my table"

    mock_connection.post "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      JSON.parse(env.body)["friendlyName"].must_equal name
      JSON.parse(env.body)["description"].must_equal description
      [200, {"Content-Type"=>"application/json"},
       create_table_json(name, description)]
    end

    table = dataset.create_table name: name,
                                 description: description
    table.must_be_kind_of Gcloud::Bigquery::Table
    table.name.must_equal name
    table.description.must_equal description
  end

  it "lists tables" do
    num_tables = 3
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_tables_json(num_tables)]
    end

    tables = dataset.tables
    tables.size.must_equal num_tables
    tables.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Table }
  end

  it "paginates tables" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_tables_json(3, "next_page_token")]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_tables_json(2)]
    end

    first_tables = dataset.tables
    first_tables.count.must_equal 3
    first_tables.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Table }
    first_tables.token.wont_be :nil?
    first_tables.token.must_equal "next_page_token"

    second_tables = dataset.tables token: first_tables.token
    second_tables.count.must_equal 2
    second_tables.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Table }
    second_tables.token.must_be :nil?
  end

  it "paginates tables with max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_tables_json(3, "next_page_token")]
    end

    tables = dataset.tables max: 3
    tables.count.must_equal 3
    tables.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Table }
    tables.token.wont_be :nil?
    tables.token.must_equal "next_page_token"
  end

  it "paginates tables without max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_tables_json(3, "next_page_token")]
    end

    tables = dataset.tables
    tables.count.must_equal 3
    tables.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Table }
    tables.token.wont_be :nil?
    tables.token.must_equal "next_page_token"
  end

  it "finds a table" do
    table_name = "found-table"

    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset.dataset_id}/tables/#{table_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_table_json(table_name)]
    end

    table = dataset.table table_name
    table.must_be_kind_of Gcloud::Bigquery::Table
    table.name.must_equal table_name
  end

  def create_table_json name = nil, description = nil
    random_table_hash(dataset_id, name, description).to_json
  end

  def find_table_json name
    random_table_hash(dataset_id, name).to_json
  end

  def list_tables_json count = 2, token = nil
    tables = count.times.map { random_table_small_hash(dataset_id) }
    hash = {"kind"=>"bigquery#tableList", "tables"=>tables,
            "totalItems"=> (token ? count+1 : count)}
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
