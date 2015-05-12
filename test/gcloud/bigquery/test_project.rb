# Copyright 2015 Google Inc. All rights reserved.
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

describe Gcloud::Bigquery::Project, :mock_bigquery do
  it "creates an empty dataset" do
    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      [200, {"Content-Type"=>"application/json"},
       create_dataset_json]
    end

    dataset = bigquery.create_dataset
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
  end

  it "creates a dataset with a name and description" do
    name = "my-dataset"
    description = "This is my dataset"
    default_expiration = 999

    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      JSON.parse(env.body)["friendlyName"].must_equal name
      JSON.parse(env.body)["description"].must_equal description
      JSON.parse(env.body)["defaultTableExpirationMs"].must_equal default_expiration
      [200, {"Content-Type"=>"application/json"},
       create_dataset_json(name, description, default_expiration)]
    end

    dataset = bigquery.create_dataset name: name,
                                      description: description,
                                      default_expiration: default_expiration
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.name.must_equal name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
  end

  it "lists datasets" do
    num_datasets = 3
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(num_datasets)]
    end

    datasets = bigquery.datasets
    datasets.size.must_equal num_datasets
    datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
  end

  it "paginates datasets" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(3, "next_page_token")]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(2)]
    end

    first_datasets = bigquery.datasets
    first_datasets.count.must_equal 3
    first_datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
    first_datasets.token.wont_be :nil?
    first_datasets.token.must_equal "next_page_token"

    second_datasets = bigquery.datasets token: first_datasets.token
    second_datasets.count.must_equal 2
    second_datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
    second_datasets.token.must_be :nil?
  end

  it "paginates datasets with max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(3, "next_page_token")]
    end

    datasets = bigquery.datasets max: 3
    datasets.count.must_equal 3
    datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
    datasets.token.wont_be :nil?
    datasets.token.must_equal "next_page_token"
  end

  it "paginates datasets without max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets" do |env|
      env.params.wont_include "maxResults"
      [200, {"Content-Type"=>"application/json"},
       list_datasets_json(3, "next_page_token")]
    end

    datasets = bigquery.datasets
    datasets.count.must_equal 3
    datasets.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Dataset }
    datasets.token.wont_be :nil?
    datasets.token.must_equal "next_page_token"
  end

  it "finds a dataset" do
    dataset_name = "found-dataset"

    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_dataset_json(dataset_name)]
    end

    dataset = bigquery.dataset dataset_name
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.name.must_equal dataset_name
  end

  def create_dataset_json name = nil, description = nil, default_expiration = nil
    random_dataset_hash(name, description, default_expiration).to_json
  end

  def find_dataset_json name = nil, description = nil, default_expiration = nil
    random_dataset_hash(name, description, default_expiration).to_json
  end

  def list_datasets_json count = 2, token = nil
    datasets = count.times.map { random_dataset_small_hash }
    hash = {"kind"=>"bigquery#datasetList", "datasets"=>datasets}
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
