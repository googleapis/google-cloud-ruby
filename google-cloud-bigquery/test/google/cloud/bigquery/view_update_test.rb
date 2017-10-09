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

describe Google::Cloud::Bigquery::View, :update, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:view_hash) { random_view_hash dataset_id, table_id, table_name, description }
  let(:view_gapi) { Google::Apis::BigqueryV2::Table.from_json view_hash.to_json }
  let(:view) { Google::Cloud::Bigquery::View.from_gapi view_gapi,
                                                bigquery.service }


  let(:schema) { view.schema.dup }
  let(:etag) { "etag123456789" }

  it "updates its name" do
    new_table_name = "My Updated View"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, new_table_name, description
    request_view_gapi = Google::Apis::BigqueryV2::Table.new friendly_name: "My Updated View", etag: etag
    mock.expect :patch_table, return_view(view_hash),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.name = new_table_name

    view.name.must_equal new_table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    mock.verify
  end

  it "updates its description" do
    new_description = "This is my updated view"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, new_description
    request_view_gapi = Google::Apis::BigqueryV2::Table.new description: "This is my updated view", etag: etag
    mock.expect :patch_table, return_view(view_hash),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.description = new_description

    view.description.must_equal new_description
    view.name.must_equal table_name
    view.schema.fields.count.must_equal schema.fields.count

    mock.verify
  end

  it "updates its query (query=)" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.query = new_query

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_be :empty?

    mock.verify
  end

  it "updates its query (set_query)" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_be :empty?

    mock.verify
  end

  it "updates its query with standard_sql" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: []
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query, standard_sql: true

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_be :empty?

    mock.verify
  end

  it "updates its query with legacy_sql" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: true,
        user_defined_function_resources: []
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query, legacy_sql: true

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.wont_be :query_standard_sql?
    view.must_be :query_legacy_sql?
    view.query_udfs.must_be :empty?

    mock.verify
  end

  it "updates its query with udfs (array)" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(inline_code: "return x+1;"),
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(resource_uri: "gs://my-bucket/my-lib.js")
        ]
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query, udfs: ["return x+1;", "gs://my-bucket/my-lib.js"]

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_equal ["return x+1;", "gs://my-bucket/my-lib.js"]

    mock.verify
  end

  it "updates its query with udfs (inline)" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(inline_code: "return x+1;")
        ]
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query, udfs: "return x+1;"

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_equal ["return x+1;"]

    mock.verify
  end

  it "updates its query with udfs (url)" do
    new_query = "SELECT name, age FROM `users`"

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset_id, table_id, table_name, description
    view_hash["view"]["query"] = new_query
    request_view_gapi = Google::Apis::BigqueryV2::Table.new(
      view: Google::Apis::BigqueryV2::ViewDefinition.new(
        query: new_query,
        use_legacy_sql: false,
        user_defined_function_resources: [
          Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(resource_uri: "gs://my-bucket/my-lib.js")
        ]
      ),
      etag: etag
    )
    mock.expect :patch_table, return_view(view_hash, request_view_gapi.view),
      [project, dataset_id, table_id, request_view_gapi, {options: {header: {"If-Match" => etag}}}]
    mock.expect :get_table, return_view(view_hash, request_view_gapi.view), [project, dataset_id, table_id]
    view.service.mocked_service = mock

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count

    view.set_query new_query, udfs: "gs://my-bucket/my-lib.js"

    view.name.must_equal table_name
    view.description.must_equal description
    view.schema.fields.count.must_equal schema.fields.count
    view.query.must_equal new_query
    view.must_be :query_standard_sql?
    view.wont_be :query_legacy_sql?
    view.query_udfs.must_equal ["gs://my-bucket/my-lib.js"]

    mock.verify
  end

  def return_view view_hash, view_gapi = nil
    tbl = Google::Apis::BigqueryV2::Table.from_json(view_hash.to_json)
    tbl.view = view_gapi if view_gapi
    tbl
  end
end
