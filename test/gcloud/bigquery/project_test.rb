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
       create_dataset_json("my_dataset")]
    end

    dataset = bigquery.create_dataset "my_dataset"
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
  end

  it "creates a dataset with a name and description" do
    id = "my_dataset"
    name = "My Dataset"
    description = "This is my dataset"
    default_expiration = 999

    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      JSON.parse(env.body)["friendlyName"].must_equal name
      JSON.parse(env.body)["description"].must_equal description
      JSON.parse(env.body)["defaultTableExpirationMs"].must_equal default_expiration
      [200, {"Content-Type"=>"application/json"},
       create_dataset_json(id, name, description, default_expiration)]
    end

    dataset = bigquery.create_dataset id, name: name,
                                      description: description,
                                      expiration: default_expiration
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.name.must_equal name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
  end

  it "raises when creating a dataset with a blank id" do
    id = ""

    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      [400, { "Content-Type" => "application/json" },
       invalid_dataset_id_error_json(id)]
    end

    assert_raises Gcloud::Bigquery::ApiError do
      bigquery.create_dataset id
    end
  end

  it "creates a dataset with optional access" do
    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 1
      rule = access.first
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "WRITER"
      rule["userByEmail"].must_equal "writers@example.com"

      ret_dataset = random_dataset_hash("my_dataset")
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset = bigquery.create_dataset "my_dataset",
      access: [{"role"=>"WRITER", "userByEmail"=>"writers@example.com"}]
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.access.wont_be :empty?
  end

  it "creates a dataset with access block" do
    mock_connection.post "/bigquery/v2/projects/#{project}/datasets" do |env|
      json = JSON.parse env.body
      access = json["access"]
      access.wont_be :nil?
      access.must_be_kind_of Array
      access.wont_be :empty?
      access.count.must_equal 5
      rule = access.last
      rule.wont_be :nil?
      rule.must_be_kind_of Hash
      rule["role"].must_equal "WRITER"
      rule["userByEmail"].must_equal "writers@example.com"

      ret_dataset = random_dataset_hash("my_dataset")
      ret_dataset["access"] = access
      [200, {"Content-Type"=>"application/json"},
       ret_dataset.to_json]
    end

    dataset = bigquery.create_dataset "my_dataset" do |acl|
      refute acl.writer_user? "writers@example.com"
      acl.add_writer_user "writers@example.com"
      assert acl.writer_user? "writers@example.com"
    end
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.access.wont_be :empty?
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
    dataset_id = "found_dataset"
    dataset_name = "Found Dataset"

    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_dataset_json(dataset_id, dataset_name)]
    end

    dataset = bigquery.dataset dataset_id
    dataset.must_be_kind_of Gcloud::Bigquery::Dataset
    dataset.dataset_id.must_equal dataset_id
    dataset.name.must_equal dataset_name
  end

  it "lists jobs" do
    num_jobs = 3
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(num_jobs)]
    end

    jobs = bigquery.jobs
    jobs.size.must_equal num_jobs
    jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
  end

  it "paginates jobs" do
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(3, "next_page_token", 5)]
    end
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(2, nil, 5)]
    end

    first_jobs = bigquery.jobs
    first_jobs.count.must_equal 3
    first_jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
    first_jobs.token.wont_be :nil?
    first_jobs.token.must_equal "next_page_token"
    first_jobs.total.must_equal 5

    second_jobs = bigquery.jobs token: first_jobs.token
    second_jobs.count.must_equal 2
    second_jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
    second_jobs.token.must_be :nil?
    second_jobs.total.must_equal 5
  end

  it "paginates jobs without options" do
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      env.params.wont_include "maxResults"
      env.params.wont_include "stateFilter"
      env.params["projection"].must_equal "full"
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(3, "next_page_token")]
    end

    jobs = bigquery.jobs
    jobs.count.must_equal 3
    jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
    jobs.token.wont_be :nil?
    jobs.token.must_equal "next_page_token"
  end

  it "paginates jobs with max set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      env.params.must_include "maxResults"
      env.params.wont_include "stateFilter"
      env.params["maxResults"].must_equal "3"
      env.params["projection"].must_equal "full"
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(3, "next_page_token")]
    end

    jobs = bigquery.jobs max: 3
    jobs.count.must_equal 3
    jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
    jobs.token.wont_be :nil?
    jobs.token.must_equal "next_page_token"
  end

  it "paginates jobs with filter set" do
    mock_connection.get "/bigquery/v2/projects/#{project}/jobs" do |env|
      env.params.must_include "stateFilter"
      env.params.wont_include "maxResults"
      env.params["stateFilter"].must_equal "running"
      env.params["projection"].must_equal "full"
      [200, {"Content-Type"=>"application/json"},
       list_jobs_json(3, "next_page_token")]
    end

    jobs = bigquery.jobs filter: "running"
    jobs.count.must_equal 3
    jobs.each { |ds| ds.must_be_kind_of Gcloud::Bigquery::Job }
    jobs.token.wont_be :nil?
    jobs.token.must_equal "next_page_token"
  end

  it "finds a job" do
    job_id = "9876543210"

    mock_connection.get "/bigquery/v2/projects/#{project}/jobs/#{job_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       find_job_json(job_id)]
    end

    job = bigquery.job job_id
    job.must_be_kind_of Gcloud::Bigquery::Job
    job.job_id.must_equal job_id
  end

  def create_dataset_json id, name = nil, description = nil, default_expiration = nil
    random_dataset_hash(id, name, description, default_expiration).to_json
  end

  def find_dataset_json id, name = nil, description = nil, default_expiration = nil
    random_dataset_hash(id, name, description, default_expiration).to_json
  end

  def list_datasets_json count = 2, token = nil
    datasets = count.times.map { random_dataset_small_hash }
    hash = {"kind"=>"bigquery#datasetList", "datasets"=>datasets}
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  def find_job_json job_id
    random_job_hash(job_id).to_json
  end

  def list_jobs_json count = 2, token = nil, total = nil
    hash = {
      "kind" => "bigquery#jobList",
      "etag" => "etag",
      "jobs" => count.times.map { random_job_hash },
      "totalItems" => (total || count)
    }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
