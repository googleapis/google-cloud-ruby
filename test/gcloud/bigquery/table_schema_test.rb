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
require "uri"

describe Gcloud::Bigquery::Table, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:dataset) { "my_dataset" }

  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash, bigquery.connection }

  let(:schema) { table.schema.dup }

  it "gets the schema, fields, and headers" do
    table.schema.must_be_kind_of Hash
    table.schema.keys.must_include "fields"
    table.fields.must_equal table.schema["fields"]
    table.headers.must_equal ["name", "age", "score", "active"]
  end

  it "sets its schema if assigned a hash" do
    new_table_data = new_table_hash
    new_table_data["schema"]["fields"].first["name"] = "moniker"
    new_schema = new_table_data["schema"]
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["schema"].must_equal new_schema
      [200, { "Content-Type" => "application/json" },
       new_table_data.to_json]
    end

    table.schema = new_schema

    table.schema.must_equal new_schema
    table.schema["fields"].first["name"].must_equal "moniker"
  end

  it "sets a flat schema via a block" do
    new_table_data = new_table_hash
    new_table_data["schema"]["fields"] = [
      field_string_required,
      field_integer,
      field_float,
      field_boolean,
      field_timestamp
    ]
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["schema"].must_equal new_table_data["schema"]
      [200, { "Content-Type" => "application/json" }, new_table_data.to_json]
    end

    table.schema do |schema|
      schema.string "first_name", mode: :required
      schema.integer "rank", description: "An integer value from 1 to 100"
      schema.float "accuracy"
      schema.boolean "approved"
      schema.timestamp "start_date"
    end

    table.schema.must_equal new_table_data["schema"]
  end

  it "adds to its existing schema with replace option false" do
    new_table_data = new_table_hash
    new_table_data["schema"]["fields"] << field_timestamp
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["schema"].must_equal new_table_data["schema"]
      [200, { "Content-Type" => "application/json" }, new_table_data.to_json]
    end

    table.schema replace: false do |schema|
      schema.timestamp "start_date"
    end

    table.schema.must_equal new_table_data["schema"]
  end

  it "sets a nested repeated schema field via a nested block" do
    new_table_data = new_table_hash
    new_table_data["schema"]["fields"] = [
      field_string_required,
      field_record_repeated
    ]
    mock_connection.patch "/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" do |env|
      json = JSON.parse env.body
      json["schema"].must_equal new_table_data["schema"]
      [200, { "Content-Type" => "application/json" }, new_table_data.to_json]
    end

    table.schema do |schema|
      schema.string "first_name", mode: :required
      schema.record "cities_lived", mode: :repeated do |nested|
        nested.integer "rank", description: "An integer value from 1 to 100"
        nested.timestamp "start_date"
      end
    end

    table.schema.must_equal new_table_data["schema"]
  end

  it "raises when nesting fields more than one level deep" do
    original_schema = table.schema.dup

    assert_raises ArgumentError do
      table.schema do |schema|
        schema.string "first_name", mode: :required
        schema.record "countries_lived", mode: :repeated do |nested|
          nested.record "cities_lived", mode: :repeated do |nested_2|
            nested_2.integer "rank", description: "An integer value from 1 to 100"
          end
        end
      end
    end

    table.schema.must_equal original_schema
  end

  protected

  def new_table_hash
    random_table_hash dataset, table_id, table_name, description
  end

  def field_string_required
    {
      "name" => "first_name",
      "type" => "STRING",
      "mode" => "REQUIRED"
    }
  end

  def field_integer
    {
      "name" => "rank",
      "type" => "INTEGER",
      "description" => "An integer value from 1 to 100"
    }
  end

  def field_float
    {
      "name" => "accuracy",
      "type" => "FLOAT"
    }
  end

  def field_boolean
    {
      "name" => "approved",
      "type" => "BOOLEAN"
    }
  end

  def field_timestamp
    {
      "name" => "start_date",
      "type" => "TIMESTAMP"
    }
  end

  def field_record_repeated
    {
      "name" => "cities_lived",
      "type" => "RECORD",
      "mode" => "REPEATED",
      "fields" => [ field_integer, field_timestamp ]
    }
  end
end
