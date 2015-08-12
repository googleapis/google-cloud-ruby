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

describe Gcloud::Bigquery::Dataset, :update, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:description) { "This is my dataset" }
  let(:default_expiration) { 999 }
  let(:dataset_hash) { random_dataset_hash dataset_id, dataset_name, description, default_expiration }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_hash,
                                                      bigquery.connection }

  it "updates its name" do
    new_dataset_name = "My Updated Dataset"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      json["friendlyName"].must_equal new_dataset_name
      [200, {"Content-Type"=>"application/json"},
       random_dataset_hash(dataset_id, new_dataset_name, description, default_expiration).to_json]
    end

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.name = new_dataset_name

    dataset.name.must_equal new_dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration
  end

  it "updates its description" do
    new_description = "This is my updated dataset"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      json["description"].must_equal new_description
      [200, {"Content-Type"=>"application/json"},
       random_dataset_hash(dataset_id, dataset_name, new_description, default_expiration).to_json]
    end

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.description = new_description

    dataset.name.must_equal dataset_name
    dataset.description.must_equal new_description
    dataset.default_expiration.must_equal default_expiration
  end

  it "updates its default_expiration" do
    new_default_expiration = 888

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" do |env|
      json = JSON.parse env.body
      json["defaultTableExpirationMs"].must_equal new_default_expiration
      [200, {"Content-Type"=>"application/json"},
       random_dataset_hash(dataset_id, dataset_name, description, new_default_expiration).to_json]
    end

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal default_expiration

    dataset.default_expiration = new_default_expiration

    dataset.name.must_equal dataset_name
    dataset.description.must_equal description
    dataset.default_expiration.must_equal new_default_expiration
  end
end
