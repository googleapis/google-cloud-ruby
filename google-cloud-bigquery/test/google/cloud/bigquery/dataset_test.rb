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

describe Google::Cloud::Bigquery::Dataset, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:dataset_name) { "My Dataset" }
  let(:dataset_description) { "This is my dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:table_description) { "This is my table" }
  let(:time_partitioning_gapi) do
    Google::Apis::BigqueryV2::TimePartitioning.new type: "DAY", field: "dob", expiration_ms: 5000
  end
  let(:range_partitioning_gapi) do
    Google::Apis::BigqueryV2::RangePartitioning.new(
      field: "my_table_id",
      range: Google::Apis::BigqueryV2::RangePartitioning::Range.new(
        start: 0,
        interval: 10,
        end: 100
      )
    ) 
  end
  let(:clustering_fields) { ["last_name", "first_name"] }
  let(:clustering_gapi) do
    Google::Apis::BigqueryV2::Clustering.new fields: clustering_fields
  end
  let(:policy_tag) { "projects/#{project}/locations/us/taxonomies/1/policyTags/1" }
  let(:policy_tag_2) { "projects/#{project}/locations/us/taxonomies/1/policyTags/2" }
  let(:policy_tags) { [ policy_tag, policy_tag_2 ] }
  let(:policy_tags_gapi) { Google::Apis::BigqueryV2::TableFieldSchema::PolicyTags.new names: policy_tags }
  let(:table_schema_gapi) do
    Google::Apis::BigqueryV2::TableSchema.new(
      fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name", type: "STRING", description: nil, fields: [], max_length: max_length_string),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age", type: "INTEGER", description: nil, fields: [], policy_tags: policy_tags_gapi),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score", type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active", type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar", type: "BYTES", description: nil, fields: [], max_length: max_length_bytes)
      ]
    )
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
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }
  let(:max_length_string) { 50 }
  let(:max_length_bytes) { 1024 }
  let(:precision_numeric) { 10 }
  let(:precision_bignumeric) { 38 }
  let(:scale_numeric) { 9 }
  let(:scale_bignumeric) { 37 }

  it "knows its attributes" do
    _(dataset.name).must_equal dataset_name
    _(dataset.description).must_equal dataset_description
    _(dataset.default_expiration).must_equal default_expiration
    _(dataset.etag).must_equal etag
    _(dataset.api_url).must_equal api_url
    _(dataset.location).must_equal location_code
    _(dataset.labels).must_equal labels
    _(dataset.labels).must_be :frozen?
  end

  it "knows its creation and modification times" do
    now = ::Time.now

    dataset.gapi.creation_time = time_millis
    _(dataset.created_at).must_be_close_to now, 0.1

    dataset.gapi.last_modified_time = time_millis
    _(dataset.modified_at).must_be_close_to now, 0.1
  end

  it "can test its existence without reloading" do
    _(dataset.exists?).must_equal true
  end

  it "can test its existence with force reload" do
    mock = Minitest::Mock.new
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    dataset.service.mocked_service = mock

    _(dataset.exists?(force: true)).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id, delete_contents: nil]
    dataset.service.mocked_service = mock

    _(dataset.delete).must_equal true

    _(dataset.exists?).must_equal false

    mock.verify
  end

  it "can delete itself and all table data" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id, delete_contents: true]
    dataset.service.mocked_service = mock

    _(dataset.delete(force: true)).must_equal true

    _(dataset.exists?).must_equal false

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

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
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

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.name).must_equal table_name
    _(table.description).must_equal table_description
    _(table.schema).must_be :empty?
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
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
      expect { t.data }.must_raise RuntimeError
      expect { t.copy_job }.must_raise RuntimeError
      expect { t.copy }.must_raise RuntimeError
      expect { t.extract_job }.must_raise RuntimeError
      expect { t.extract }.must_raise RuntimeError
      expect { t.load_job }.must_raise RuntimeError
      expect { t.load }.must_raise RuntimeError
      expect { t.insert }.must_raise RuntimeError
      expect { t.insert_async }.must_raise RuntimeError
      expect { t.delete }.must_raise RuntimeError
      expect { t.query_job }.must_raise RuntimeError
      expect { t.query }.must_raise RuntimeError
      expect { t.external }.must_raise RuntimeError
      expect { t.reload! }.must_raise RuntimeError
      expect { t.refresh! }.must_raise RuntimeError
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.name).must_equal table_name
    _(table.description).must_equal table_description
    _(table.schema).must_be :empty?
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
  end

  it "creates a table with time partitioning and clustering in a block" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      time_partitioning: time_partitioning_gapi,
      clustering: clustering_gapi)
    mock.expect :insert_table, insert_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.time_partitioning_type = "DAY"
      t.time_partitioning_field = "dob"
      t.time_partitioning_expiration = 5
      t.clustering_fields = clustering_fields
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.time_partitioning?).must_equal true
    _(table.time_partitioning_type).must_equal "DAY"
    _(table.time_partitioning_field).must_equal "dob"
    _(table.time_partitioning_expiration).must_equal 5
    _(table.clustering_fields).must_equal clustering_fields
  end

  it "creates a table with range partitioning in a block" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      range_partitioning: range_partitioning_gapi)
    mock.expect :insert_table, insert_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.range_partitioning_field = "my_table_id"
      t.range_partitioning_start = 0
      t.range_partitioning_interval = 10
      t.range_partitioning_end = 100
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.range_partitioning?).must_equal true
    _(table.range_partitioning_field).must_equal "my_table_id"
    _(table.range_partitioning_start).must_equal 0
    _(table.range_partitioning_interval).must_equal 10
    _(table.range_partitioning_end).must_equal 100
  end

  it "creates a table with require_partition_filter in a block" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      require_partition_filter: true)
    mock.expect :insert_table, insert_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |t|
      t.require_partition_filter = true
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.require_partition_filter).must_equal true
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
      t.schema.string "name", mode: :required, max_length: max_length_string
      t.schema.integer "age", policy_tags: policy_tags
      t.schema.float "score", description: "A score from 0.0 to 10.0"
      t.schema.boolean "active"
      t.schema.bytes "avatar", max_length: max_length_bytes
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.name).must_equal table_name
    _(table.description).must_equal table_description
    _(table.schema).wont_be :empty?
    _(table.schema).must_be :frozen?
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
  end

  it "creates a table with a old schema syntax" do
    mock = Minitest::Mock.new
    insert_table = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: table_id),
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: [], max_length: max_length_string),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", policy_tags: policy_tags_gapi, description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "cost",          type: "NUMERIC", description: nil, fields: [], precision: precision_numeric, scale: scale_numeric),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "my_bignumeric", type: "BIGNUMERIC", description: nil, fields: [], precision: precision_bignumeric, scale: scale_bignumeric),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: [], max_length: max_length_bytes),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "creation_date", type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "home",          type: "GEOGRAPHY", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REPEATED", name: "cities_lived",  type: "RECORD", description: nil, fields: [
          Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "place",           type: "STRING",  description: nil, fields: []),
          Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "location",        type: "GEOGRAPHY",  description: nil, fields: []),
          Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "number_of_years", type: "INTEGER", description: nil, fields: [])])
        ]))
    return_table = create_table_gapi table_id, table_name, table_description
    return_table.schema = table_schema_gapi
    mock.expect :insert_table, return_table, [project, dataset_id, insert_table]
    dataset.service.mocked_service = mock

    table = dataset.create_table table_id do |schema|
      schema.string "name", mode: :required, max_length: max_length_string
      schema.integer "age", policy_tags: policy_tags
      schema.float "score", description: "A score from 0.0 to 10.0"
      schema.numeric "cost", precision: precision_numeric, scale: scale_numeric
      schema.bignumeric "my_bignumeric", precision: precision_bignumeric, scale: scale_bignumeric
      schema.boolean "active"
      schema.bytes "avatar", max_length: max_length_bytes
      schema.timestamp "creation_date"
      schema.time "duration"
      schema.datetime "target_end"
      schema.date "birthday"
      schema.geography "home"
      schema.record "cities_lived", mode: :repeated do |nested_schema|
        nested_schema.string "place"
        nested_schema.geography "location"
        nested_schema.integer "number_of_years"
      end
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.name).must_equal table_name
    _(table.description).must_equal table_description
    _(table.schema).wont_be :empty?
    _(table.schema).must_be :frozen?
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
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
        s.string "name", mode: :required, max_length: max_length_string
        s.integer "age", policy_tags: policy_tags
        s.float "score", description: "A score from 0.0 to 10.0"
        s.boolean "active"
        s.bytes "avatar", max_length: max_length_bytes
      end
    end

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal table_id
    _(table.name).must_equal table_name
    _(table.description).must_equal table_description
    _(table.schema).wont_be :empty?
    _(table.schema).must_be :frozen?
    _(table).must_be :table?
    _(table).wont_be :view?
    _(table).wont_be :materialized_view?
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

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_be :empty?
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table.name).must_equal view_name
    _(table.description).must_equal view_description
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_be :empty?
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_be :empty?
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).wont_be :query_standard_sql?
    _(table).must_be :query_legacy_sql?
    _(table.query_udfs).must_be :empty?
    _(table.name).must_equal view_name
    _(table.description).must_equal view_description
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_equal ["return x+1;", "gs://my-bucket/my-lib.js"]
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_equal ["return x+1;"]
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
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


    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).must_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_equal ["gs://my-bucket/my-lib.js"]
    _(table).must_be :view?
    _(table).wont_be :table?
    _(table).wont_be :materialized_view?
  end

  it "can create a materialized view" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id
      ),
      materialized_view: Google::Apis::BigqueryV2::MaterializedViewDefinition.new(
        enable_refresh: nil,
        query: query,
        refresh_interval_ms: nil
      )
    )
    return_view = create_materialized_view_gapi view_id, insert_view.materialized_view
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_materialized_view view_id, query

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).wont_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_be :nil?
    _(table).wont_be :table?
    _(table).wont_be :view?
    _(table).must_be :materialized_view?
  end

  it "can create a materialized view with options" do
    mock = Minitest::Mock.new
    insert_view = Google::Apis::BigqueryV2::Table.new(
      table_reference: Google::Apis::BigqueryV2::TableReference.new(
        project_id: project, dataset_id: dataset_id, table_id: view_id
      ),
      materialized_view: Google::Apis::BigqueryV2::MaterializedViewDefinition.new(
        enable_refresh: false,
        query: query,
        refresh_interval_ms: 3_600_000
      )
    )
    return_view = create_materialized_view_gapi view_id, insert_view.materialized_view
    mock.expect :insert_table, return_view, [project, dataset_id, insert_view]
    dataset.service.mocked_service = mock

    table = dataset.create_materialized_view view_id, query, enable_refresh: false, refresh_interval_ms: 3_600_000

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal view_id
    _(table.query).must_equal query
    _(table).wont_be :query_standard_sql?
    _(table).wont_be :query_legacy_sql?
    _(table.query_udfs).must_be :nil?
    _(table).wont_be :table?
    _(table).wont_be :view?
    _(table).must_be :materialized_view?
  end

  it "lists tables" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3),
      [project, dataset_id, max_results: nil, page_token: nil]
    dataset.service.mocked_service = mock

    tables = dataset.tables

    mock.verify

    _(tables.size).must_equal 3
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
  end

  it "lists tables with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token"),
      [project, dataset_id, max_results: 3, page_token: nil]
    dataset.service.mocked_service = mock

    tables = dataset.tables max: 3

    mock.verify

    _(tables.count).must_equal 3
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(tables.token).wont_be :nil?
    _(tables.token).must_equal "next_page_token"
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

    _(first_tables.count).must_equal 3
    first_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(first_tables.token).wont_be :nil?
    _(first_tables.token).must_equal "next_page_token"
    _(first_tables.total).must_equal 5

    _(second_tables.count).must_equal 2
    second_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(second_tables.token).must_be :nil?
    _(second_tables.total).must_equal 5
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

    _(first_tables.count).must_equal 3
    first_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(first_tables.token).wont_be :nil?
    _(first_tables.token).must_equal "next_page_token"
    _(first_tables.total).must_equal 5

    _(second_tables.count).must_equal 2
    second_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(second_tables.token).must_be :nil?
    _(second_tables.total).must_equal 5
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

    _(first_tables.count).must_equal 3
    first_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(first_tables.next?).must_equal true
    _(first_tables.total).must_equal 5

    _(second_tables.count).must_equal 2
    second_tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
    _(second_tables.next?).must_equal false
    _(second_tables.total).must_equal 5
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

    _(tables.count).must_equal 5
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
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

    _(tables.count).must_equal 5
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
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

    _(tables.count).must_equal 5
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
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

    _(tables.count).must_equal 6
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
  end

  it "finds a table" do
    found_table_id = "found_table"

    mock = Minitest::Mock.new
    mock.expect :get_table, find_table_gapi(found_table_id), [project, dataset_id, found_table_id]
    dataset.service.mocked_service = mock

    table = dataset.table found_table_id

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal found_table_id
  end

  it "finds a table with skip_lookup option" do
    table_id = "found_table"
    # No HTTP mock needed, since the lookup is not made

    table = dataset.table table_id, skip_lookup: true

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table).must_be :reference?
    _(table).wont_be :resource?
    _(table).wont_be :resource_partial?
    _(table).wont_be :resource_full?
  end

  it "finds a table with skip_lookup option if table_id is nil" do
    table_id = nil
    # No HTTP mock needed, since the lookup is not made

    error = expect do
      dataset.table table_id, skip_lookup: true
    end.must_raise ArgumentError
    _(error.message).must_equal "table_id is required"
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

  def create_materialized_view_gapi id, view, name = nil, description = nil
    hash = random_table_hash dataset_id, id, name, description
    hash["type"] = "MATERIALIZED_VIEW"

    Google::Apis::BigqueryV2::Table.from_json(hash.to_json).tap do |v|
      v.materialized_view = view
    end
  end

  def find_table_gapi id, name = nil, description = nil
    Google::Apis::BigqueryV2::Table.from_json random_table_hash(dataset_id, id, name, description).to_json
  end
end
