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

describe Gcloud::Bigquery::View, :update, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:view_hash) { random_view_hash dataset_id, table_id, table_name, description }
  let(:view) { Gcloud::Bigquery::View.from_gapi view_hash,
                                                bigquery.connection }

  let(:schema) { view.schema.dup }

  it "updates its name" do
    new_table_name = "My Updated View"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["friendlyName"].must_equal new_table_name
      [200, {"Content-Type"=>"application/json"},
       random_view_hash(dataset_id, table_id, new_table_name, description).to_json]
    end

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.must_equal schema

    view.name = new_table_name

    view.name.must_equal new_table_name
    view.description.must_equal description
    view.schema.must_equal schema
  end

  it "updates its description" do
    new_description = "This is my updated view"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["description"].must_equal new_description
      [200, {"Content-Type"=>"application/json"},
       random_view_hash(dataset_id, table_id, table_name, new_description).to_json]
    end

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.must_equal schema

    view.description = new_description

    view.name.must_equal table_name
    view.description.must_equal new_description
    view.schema.must_equal schema
  end

  it "updates its query" do
    new_query = "SELECT name, age FROM [users]"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["view"]["query"].must_equal new_query
      [200, {"Content-Type"=>"application/json"},
       new_view_json(new_query)]
    end

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.must_equal schema

    view.query = new_query

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.must_equal schema
    view.query.must_equal new_query
  end

  def new_view_json query
    hash = random_view_hash dataset_id, table_id, table_name, description
    hash["view"] = { "query" => query }
    hash.to_json
  end
end
