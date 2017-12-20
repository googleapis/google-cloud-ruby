# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "json"
require "uri"

describe Google::Cloud::BigQuery::Dataset, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:dataset_description) { "This is my dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:table_description) { "This is my table" }
  let(:table_schema) {
    {
      fields: [
        { mode: "REQUIRED", name: "name", type: "STRING", description: nil, fields: [] },
        { mode: "NULLABLE", name: "age", type: "INTEGER", description: nil, fields: [] },
        { mode: "NULLABLE", name: "score", type: "FLOAT", description: "A score from 0.0 to 10.0", fields: [] },
        { mode: "NULLABLE", name: "active", type: "BOOLEAN", description: nil, fields: [] },
        { mode: "NULLABLE", name: "avatar", type: "BYTES", description: nil, fields: [] }
      ]
    }
  }
  let(:table_schema_gapi) do
    gapi = Google::Apis::BigqueryV2::TableSchema.from_json table_schema.to_json
    gapi.fields.each do |f|
      f.update! fields: []
    end
    gapi
  end
  let(:view_id) { "my_view" }
  let(:view_name) { "My View" }
  let(:view_description) { "This is my view" }
  let(:query) { "SELECT * FROM [table]" }
  let(:default_expiration) { 999 }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { "foo" => "bar" } }
  let(:api_url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset_id}" }
  let(:dataset_hash) { random_dataset_hash dataset_id, dataset_name, dataset_description, default_expiration }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::BigQuery::Dataset.from_gapi dataset_gapi, bigquery.service }

  it "knows its attributes" do
    dataset.name.must_equal dataset_name
    dataset.description.must_equal dataset_description
    dataset.default_expiration.must_equal default_expiration
    dataset.etag.must_equal etag
    dataset.api_url.must_equal api_url
    dataset.location.must_equal location_code
    dataset.labels.must_equal labels
    dataset.labels.must_be :frozen?
  end

  it "knows its creation and modification times" do
    now = ::Time.now

    dataset.gapi.creation_time = time_millis
    dataset.created_at.must_be_close_to now, 0.1

    dataset.gapi.last_modified_time = time_millis
    dataset.modified_at.must_be_close_to now, 0.1
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id, delete_contents: nil]
    dataset.service.mocked_service = mock

    dataset.delete

    mock.verify
  end

  it "can delete itself and all table data" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id, delete_contents: true]
    dataset.service.mocked_service = mock

    dataset.delete force: true

    mock.verify
  end

  it "creates an empty table" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id))
    return_table = create_table_gapi table_id
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.must_be :table?
    table.wont_be :view?
  end

  it "creates a table with a name, description options" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      friendly_name: table_name,
      description: table_description)
    return_table = create_table_gapi table_id, table_name, table_description
    # Make sure the returning table has no schema
    return_table.update! schema: nil
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id,
                                 name: table_name,
                                 description: table_description

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.name.must_equal table_name
    table.description.must_equal table_description
    table.schema.must_be :empty?
    table.must_be :table?
    table.wont_be :view?
  end

  it "creates a table with a name, description in a block" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      friendly_name: table_name,
      description: table_description)
    return_table = create_table_gapi table_id, table_name, table_description
    # Make sure the returning table has no schema
    return_table.update! schema: nil
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.name = table_name
      t.description = table_description
    end

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.name.must_equal table_name
    table.description.must_equal table_description
    table.schema.must_be :empty?
    table.must_be :table?
    table.wont_be :view?
  end

  it "creates a table with a schema inline" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      friendly_name: table_name,
      description: table_description,
      schema: table_schema_gapi)
    return_table = create_table_gapi table_id, table_name, table_description
    return_table.schema = table_schema_gapi
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.name = table_name
      t.description = table_description
      t.schema.string "name", mode: :required
      t.schema.integer "age"
      t.schema.float "score", description: "A score from 0.0 to 10.0"
      t.schema.boolean "active"
      t.schema.bytes "avatar"
    end

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.name.must_equal table_name
    table.description.must_equal table_description
    table.schema.wont_be :empty?
    table.schema.must_be :frozen?
    table.must_be :table?
    table.wont_be :view?
  end

  it "creates a table with a old schema syntax" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "creation_date", type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REPEATED", name: "cities_lived",  type: "RECORD", description: nil, fields: [
          Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "place",           type: "STRING",  description: nil, fields: []),
          Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "number_of_years", type: "INTEGER", description: nil, fields: [])])
        ]))
    return_table = create_table_gapi table_id, table_name, table_description
    return_table.schema = table_schema_gapi
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |schema|
      schema.string "name", mode: :required
      schema.integer "age"
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.boolean "active"
      schema.bytes "avatar"
      schema.timestamp "creation_date"
      schema.time "duration"
      schema.datetime "target_end"
      schema.date "birthday"
      schema.record "cities_lived", mode: :repeated do |nested_schema|
        nested_schema.string "place"
        nested_schema.integer "number_of_years"
      end
    end

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.name.must_equal table_name
    table.description.must_equal table_description
    table.schema.wont_be :empty?
    table.schema.must_be :frozen?
    table.must_be :table?
    table.wont_be :view?
  end

  it "creates a table with a schema in a block" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      friendly_name: table_name,
      description: table_description,
      schema: table_schema_gapi)
    return_table = create_table_gapi table_id, table_name, table_description
    return_table.schema = table_schema_gapi
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.name = table_name
      t.description = table_description
      t.schema do |s|
        s.string "name", mode: :required
        s.integer "age"
        s.float "score", description: "A score from 0.0 to 10.0"
        s.boolean "active"
        s.bytes "avatar"
      end
    end

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal table_id
    table.name.must_equal table_name
    table.description.must_equal table_description
    table.schema.wont_be :empty?
    table.schema.must_be :frozen?
    table.must_be :table?
    table.wont_be :view?
  end

  it "can create a empty view" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id
      ),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      )
    )
    return_view = create_view_gapi view_id, insert_view.view
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_be :empty?
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with a name and description" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      friendly_name: view_name,
      description: view_description,
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query,
                                name: view_name,
                                description: view_description

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.name.must_equal view_name
    table.description.must_equal view_description
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_be :empty?
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with standard_sql" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query, standard_sql: true

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_be :empty?
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with legacy_sql" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: true,
        user_defined_function_resources: []
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query, legacy_sql: true

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.wont_be :query_standard_sql?
    table.must_be :query_legacy_sql?
    table.query_udfs.must_be :empty?
    table.name.must_equal view_name
    table.description.must_equal view_description
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with udfs (array)" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(inline_code: "return x+1;"),
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(resource_uri: "gs://my-bucket/my-lib.js")
        ]
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query, udfs: ["return x+1;", "gs://my-bucket/my-lib.js"]

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_equal ["return x+1;", "gs://my-bucket/my-lib.js"]
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with udfs (inline)" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(inline_code: "return x+1;")
        ]
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query, udfs: "return x+1;"

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_equal ["return x+1;"]
    table.must_be :view?
    table.wont_be :table?
  end

  it "can create a view with udfs (url)" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id),
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(resource_uri: "gs://my-bucket/my-lib.js")
        ]
      )
    )
    return_view = create_view_gapi view_id, insert_view.view, view_name, view_description
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_view view_id, query, udfs: "gs://my-bucket/my-lib.js"

    mock.verify


    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal view_id
    table.query.must_equal query
    table.must_be :query_standard_sql?
    table.wont_be :query_legacy_sql?
    table.query_udfs.must_equal ["gs://my-bucket/my-lib.js"]
    table.must_be :view?
    table.wont_be :table?
  end

  it "lists tables" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3),
      [project, dataset_id, max_results: nil, page_token: nil]
    dataset.service.mocked_service = mock

    tables = dataset.tables

    mock.verify

    tables.size.must_equal 3
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
  end

  it "lists tables with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token"),
      [project, dataset_id, max_results: 3, page_token: nil]
    dataset.service.mocked_service = mock

    tables = dataset.tables max: 3

    mock.verify

    tables.count.must_equal 3
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    tables.token.wont_be :nil?
    tables.token.must_equal "next_page_token"
  end

  it "paginates tables" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id, max_results: nil, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id, max_results: nil, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    first_tables = dataset.tables
    second_tables = dataset.tables token: first_tables.token

    mock.verify

    first_tables.count.must_equal 3
    first_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    first_tables.token.wont_be :nil?
    first_tables.token.must_equal "next_page_token"
    first_tables.total.must_equal 5

    second_tables.count.must_equal 2
    second_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    second_tables.token.must_be :nil?
    second_tables.total.must_equal 5
  end

  it "paginates tables with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id, max_results: nil, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id, max_results: nil, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    first_tables = dataset.tables
    second_tables = first_tables.next

    mock.verify

    first_tables.count.must_equal 3
    first_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    first_tables.token.wont_be :nil?
    first_tables.token.must_equal "next_page_token"
    first_tables.total.must_equal 5

    second_tables.count.must_equal 2
    second_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    second_tables.token.must_be :nil?
    second_tables.total.must_equal 5
  end

  it "paginates tables with next? and next and max" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id, max_results: 3, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id, max_results: 3, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    first_tables = dataset.tables max: 3
    second_tables = first_tables.next

    mock.verify

    first_tables.count.must_equal 3
    first_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    first_tables.next?.must_equal true
    first_tables.total.must_equal 5

    second_tables.count.must_equal 2
    second_tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
    second_tables.next?.must_equal false
    second_tables.total.must_equal 5
  end

  it "paginates tables with all" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id, max_results: nil, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id, max_results: nil, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    tables = dataset.tables.all.to_a

    mock.verify

    tables.count.must_equal 5
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
  end

  it "paginates tables with all and max" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id, max_results: 3, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id, max_results: 3, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    tables = dataset.tables(max: 3).all.to_a

    mock.verify

    tables.count.must_equal 5
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
  end

  it "iterates tables with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 25),
      [project, dataset_id, max_results: nil, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(3, "second_page_token", 25),
      [project, dataset_id, max_results: nil, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    tables = dataset.tables.all.take(5)

    mock.verify

    tables.count.must_equal 5
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
  end

  it "iterates tables with all with request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 25),
      [project, dataset_id, max_results: nil, page_token: nil]
    mock.expect :list_tables, list_tables_gapi(3, "second_page_token", 25),
      [project, dataset_id, max_results: nil, page_token: "next_page_token"]
    dataset.service.mocked_service = mock

    tables = dataset.tables.all(request_limit: 1).to_a

    mock.verify

    tables.count.must_equal 6
    tables.each { |ds| ds.must_be_kind_of Google::Cloud::BigQuery::Table }
  end

  it "finds a table" do
    found_table_id = "found_table"

    mock = Minitest::Mock.new
    mock.expect :get_table, find_table_gapi(found_table_id), [project, dataset_id, found_table_id]
    dataset.service.mocked_service = mock

    table = dataset.table found_table_id

    mock.verify

    table.must_be_kind_of Google::Cloud::BigQuery::Table
    table.table_id.must_equal found_table_id
  end

  def create_table_gapi id, name = nil, description = nil
    Google::Apis::BigqueryV2::Table.from_json random_table_hash(dataset_id, id, name, description).to_json
  end

  def create_view_gapi id, view, name = nil, description = nil
    hash = random_table_hash dataset_id, id, name, description
    hash["type"] = "VIEW"

    Google::Apis::BigqueryV2::Table.from_json(hash.to_json).tap do |v|
      v.view = view
    end
  end

  def find_table_gapi id, name = nil, description = nil
    Google::Apis::BigqueryV2::Table.from_json random_table_hash(dataset_id, id, name, description).to_json
  end
end
