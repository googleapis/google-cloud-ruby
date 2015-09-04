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

describe Gcloud::Bigquery::Table, :update, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_hash) { random_table_hash dataset_id, table_id, table_name, description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  let(:schema) { table.schema.dup }

  it "updates its name" do
    new_table_name = "My Updated Dataset"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["friendlyName"].must_equal new_table_name
      [200, {"Content-Type"=>"application/json"},
       random_table_hash(dataset_id, table_id, new_table_name, description).to_json]
    end

    table.name.must_equal table_name
    table.description.must_equal description
    table.schema.must_equal schema

    table.name = new_table_name

    table.name.must_equal new_table_name
    table.description.must_equal description
    table.schema.must_equal schema
  end

  it "updates its description" do
    new_description = "This is my updated table"

    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["description"].must_equal new_description
      [200, {"Content-Type"=>"application/json"},
       random_table_hash(dataset_id, table_id, table_name, new_description).to_json]
    end

    table.name.must_equal table_name
    table.description.must_equal description
    table.schema.must_equal schema

    table.description = new_description

    table.name.must_equal table_name
    table.description.must_equal new_description
    table.schema.must_equal schema
  end
end
