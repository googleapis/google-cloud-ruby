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

describe Google::Cloud::Bigquery::Table, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:dataset) { "my_dataset" }

  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  let(:schema_hash) { table_gapi.schema.to_h }

  let(:new_table_hash) { random_table_hash dataset, table_id, table_name, description }

  let(:field_string_required_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "first_name", type: "STRING", mode: "REQUIRED", fields: nil }
  let(:field_integer_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "rank", type: "INTEGER", description: "An integer value from 1 to 100", mode: "NULLABLE", fields: nil }
  let(:field_float_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "accuracy", type: "FLOAT", mode: "NULLABLE", fields: nil }
  let(:field_boolean_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "approved", type: "BOOLEAN", mode: "NULLABLE", fields: nil }
  let(:field_timestamp_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "start_date", type: "TIMESTAMP", mode: "NULLABLE", fields: nil }
  let(:field_record_repeated_gapi) { Google::Apis::BigqueryV2::TableFieldSchema.new name: "cities_lived", type: "RECORD", mode: "REPEATED", fields: [ field_integer_gapi, field_timestamp_gapi ] }

  let(:field_string_required) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_string_required_gapi }
  let(:field_integer) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_integer_gapi }
  let(:field_float) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_float_gapi }
  let(:field_boolean) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_boolean_gapi }
  let(:field_timestamp) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_timestamp_gapi }
  let(:field_record_repeated) { Google::Cloud::Bigquery::Schema::Field.from_gapi field_record_repeated_gapi }

  it "gets the schema, fields, and headers" do
    table.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.schema.must_be :frozen?
    table.schema.fields.count.must_equal 4

    table.schema.fields[0].name.must_equal "name"
    table.schema.fields[0].type.must_equal "STRING"
    table.schema.fields[0].description.must_equal nil
    table.schema.fields[0].mode.must_equal "REQUIRED"

    table.schema.fields[1].name.must_equal "age"
    table.schema.fields[1].type.must_equal "INTEGER"
    table.schema.fields[1].description.must_equal nil
    table.schema.fields[1].mode.must_equal nil

    table.schema.fields[2].name.must_equal "score"
    table.schema.fields[2].type.must_equal "FLOAT"
    table.schema.fields[2].description.must_equal "A score from 0.0 to 10.0"
    table.schema.fields[2].mode.must_equal nil

    table.schema.fields[3].name.must_equal "active"
    table.schema.fields[3].type.must_equal "BOOLEAN"
    table.schema.fields[3].description.must_equal nil
    table.schema.fields[3].mode.must_equal nil

    table.fields.count.must_equal 4
    table.fields.map(&:name).must_equal table.schema.fields.map(&:name)
    table.headers.must_equal ["name", "age", "score", "active"]
  end

  it "sets a flat schema via a block with replace option true" do
    new_schema = Google::Apis::BigqueryV2::TableSchema.new(
      fields: [field_string_required_gapi,
               field_integer_gapi,
               field_float_gapi,
               field_boolean_gapi,
               field_timestamp_gapi])

    mock = Minitest::Mock.new
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(schema: new_schema)
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi]
    table.service.mocked_service = mock

    table.schema replace: true do |schema|
      schema.string "first_name", mode: :required
      schema.integer "rank", description: "An integer value from 1 to 100"
      schema.float "accuracy"
      schema.boolean "approved"
      schema.timestamp "start_date"
    end

    mock.verify
  end

  it "adds to its existing schema" do
    mock = Minitest::Mock.new
    end_date_timestamp_gapi = field_timestamp_gapi.dup
    end_date_timestamp_gapi.name = "end_date"
    new_schema_gapi = table_gapi.schema.dup
    new_schema_gapi.fields << end_date_timestamp_gapi
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema_gapi
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(schema: new_schema_gapi)
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi]
    table.service.mocked_service = mock

    table.schema do |schema|
      schema.timestamp "end_date"
    end

    mock.verify

    table.headers.must_include "end_date"
  end

  it "replaces existing schema with replace option" do
    mock = Minitest::Mock.new
    new_schema_gapi = Google::Apis::BigqueryV2::TableSchema.new(
      fields: [field_timestamp_gapi])
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema_gapi
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(schema: new_schema_gapi)
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi]
    table.service.mocked_service = mock

    table.schema replace: true do |schema|
      schema.timestamp "start_date"
    end

    mock.verify

    table.schema.fields.must_include field_timestamp
  end

  it "sets a nested repeated schema field via a nested block" do
    mock = Minitest::Mock.new
    new_schema_gapi = Google::Apis::BigqueryV2::TableSchema.new(
      fields: [field_string_required_gapi, field_record_repeated_gapi])
    returned_table_gapi = table_gapi.dup
    returned_table_gapi.schema = new_schema_gapi
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(schema: new_schema_gapi)
    mock.expect :patch_table, returned_table_gapi,
      [table.project_id, table.dataset_id, table.table_id, patch_table_gapi]
    table.service.mocked_service = mock

    table.schema replace: true do |schema|
      schema.string "first_name", mode: :required
      schema.record "cities_lived", mode: :repeated do |nested|
        nested.integer "rank", description: "An integer value from 1 to 100"
        nested.timestamp "start_date"
      end
    end

    mock.verify

    table.schema.fields.must_include field_string_required
    table.schema.fields.must_include field_record_repeated
    # table.schema.fields.must_equal [field_string_required, field_record_repeated]
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
end
