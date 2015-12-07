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

describe Gcloud::Bigquery::Project, :query, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM [some_project:some_dataset.users]" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }
  let(:table_id) { "my_table" }
  let(:table_hash) { random_table_hash dataset_id, table_id }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "queries the data" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].must_be :nil?
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query
    # data.must_be_kind_of Gcloud::Bigquery::QueryData
    data.class.must_equal Gcloud::Bigquery::QueryData
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

  it "paginates the data" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      [200, {"Content-Type"=>"application/json"},
      query_data_json]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/queries/job9876543210" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "token1234567890"
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query
    # data.must_be_kind_of Gcloud::Bigquery::QueryData
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
    data.token.must_equal "token1234567890"
    data.next?.must_equal true

    data2 = data.next
    data2.class.must_equal Gcloud::Bigquery::QueryData
    data2.count.must_equal 3
  end

  it "queries the data with max option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_equal 42
      json["defaultDataset"].must_be :nil?
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, max: 42
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end

  it "queries the data with dataset option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].wont_be :nil?
      json["defaultDataset"]["datasetId"].must_equal "some_random_dataset"
      json["defaultDataset"]["projectId"].must_equal project
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, dataset: "some_random_dataset"
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end

  it "queries the data with dataset and project options" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].wont_be :nil?
      json["defaultDataset"]["datasetId"].must_equal "some_random_dataset"
      json["defaultDataset"]["projectId"].must_equal "some_random_project"
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, dataset: "some_random_dataset",
                                 project: "some_random_project"
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end

  it "queries the data with timeout option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].must_be :nil?
      json["timeoutMs"].must_equal 15000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, timeout: 15000
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end

  it "queries the data with dryrun option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].must_be :nil?
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_equal true
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, dryrun: true
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end

  it "queries the data with cache option" do
    mock_connection.post "/bigquery/v2/projects/#{project}/queries" do |env|
      json = JSON.parse(env.body)
      json["query"].must_equal query
      json["maxResults"].must_be :nil?
      json["defaultDataset"].must_be :nil?
      json["timeoutMs"].must_equal 10000
      json["dryRun"].must_be :nil?
      json["useQueryCache"].must_equal true
      [200, {"Content-Type"=>"application/json"},
       query_data_json]
    end

    data = bigquery.query query, cache: true
    data.class.must_equal Gcloud::Bigquery::QueryData
    data.count.must_equal 3
  end
end
