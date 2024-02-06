# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :reference, :mock_bigquery do
  # Create a dataset object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:table_description) { "This is my table" }
  let(:view_id) { "my_view" }
  let(:view_name) { "My View" }
  let(:view_description) { "This is my view" }
  let(:query) { "SELECT * FROM [table]" }
  let(:dataset) {Google::Cloud::Bigquery::Dataset.new_reference project, dataset_id, bigquery.service }

  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }

  it "knows its attributes" do
    _(dataset.dataset_id).must_equal dataset_id
    _(dataset.project_id).must_equal project
    _(dataset.dataset_ref).must_be_kind_of Hash
    _(dataset.dataset_ref[:dataset_id]).must_equal dataset_id
    _(dataset.dataset_ref[:project_id]).must_equal project

    _(dataset.name).must_be_nil
    _(dataset.description).must_be_nil
    _(dataset.default_expiration).must_be_nil
    _(dataset.etag).must_be_nil
    _(dataset.api_url).must_be_nil
    _(dataset.location).must_be_nil
    _(dataset.labels).must_be_nil
    _(dataset.created_at).must_be_nil
    _(dataset.modified_at).must_be_nil

    _(dataset.default_encryption).must_be_nil
    _(dataset.storage_billing_model).must_be_nil
  end

  it "can test its existence" do
    mock = Minitest::Mock.new
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    dataset.service.mocked_service = mock

    _(dataset.exists?).must_equal true

    mock.verify
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_dataset, dataset_gapi, [project, dataset_id]
    dataset.service.mocked_service = mock

    _(dataset.exists?(force: true)).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id], delete_contents: nil
    dataset.service.mocked_service = mock

    _(dataset.delete).must_equal true

    _(dataset.exists?).must_equal false

    mock.verify
  end

  it "can delete itself and all table data" do
    mock = Minitest::Mock.new
    mock.expect :delete_dataset, nil,
      [project, dataset.dataset_id], delete_contents: true
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

  it "can create a materialized view" do
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
      [project, dataset_id], max_results: nil, page_token: nil
    dataset.service.mocked_service = mock

    tables = dataset.tables

    mock.verify

    _(tables.size).must_equal 3
    tables.each { |ds| _(ds).must_be_kind_of Google::Cloud::Bigquery::Table }
  end

  it "paginates tables" do
    mock = Minitest::Mock.new
    mock.expect :list_tables, list_tables_gapi(3, "next_page_token", 5),
      [project, dataset_id], max_results: nil, page_token: nil
    mock.expect :list_tables, list_tables_gapi(2, nil, 5),
      [project, dataset_id], max_results: nil, page_token: "next_page_token"
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

  it "finds a table" do
    found_table_id = "found_table"

    mock = Minitest::Mock.new
    mock.expect :get_table, find_table_gapi(found_table_id), [project, dataset_id, found_table_id], **patch_table_args
    dataset.service.mocked_service = mock

    table = dataset.table found_table_id

    mock.verify

    _(table).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table.table_id).must_equal found_table_id
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
