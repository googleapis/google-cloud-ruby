# Copyright 2021 Google LLC
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

describe Google::Cloud::Bigquery::Table, :materialized_view, :mock_bigquery do
  # Create a materialized_view object with the project's mocked connection object
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_materialized_view" }
  let(:table_name) { "My Materialized View" }
  let(:description) { "This is my materialized view" }
  let(:etag) { "etag123456789" }
  let(:query) { "SELECT name, age, score, active FROM `external.publicdata.users`" }
  let(:materialized_view_hash) { random_materialized_view_hash dataset_id, table_id, table_name, description }
  let(:materialized_view_gapi) { Google::Apis::BigqueryV2::Table.from_json materialized_view_hash.to_json }
  let(:materialized_view) { Google::Cloud::Bigquery::Table.from_gapi materialized_view_gapi,
                                                bigquery.service }

  it "knows its attributes" do
    _(materialized_view.query_standard_sql?).must_be :nil?
    _(materialized_view.query_legacy_sql?).must_be :nil?
    _(materialized_view.query_udfs).must_be :nil?
    _(materialized_view.table?).must_equal false
    _(materialized_view.view?).must_equal false
    _(materialized_view.materialized_view?).must_equal true
    _(materialized_view.enable_refresh?).must_equal true
    _(materialized_view.last_refresh_time).must_be_close_to ::Time.now, 1
    _(materialized_view.query).must_equal query
    _(materialized_view.refresh_interval_ms).must_equal 3_600_000
  end

  it "updates enable_refresh" do
    new_enable_refresh = false
    mock = Minitest::Mock.new
    returned_table_gapi = materialized_view_gapi.dup
    returned_table_gapi.materialized_view.enable_refresh = new_enable_refresh
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(
      etag: etag,
      materialized_view: Google::Apis::BigqueryV2::MaterializedViewDefinition.new(
        enable_refresh: new_enable_refresh
      )
    )
    mock.expect :patch_table, returned_table_gapi, [project, dataset_id, table_id, patch_table_gapi], options: {header: {"If-Match" => etag}}    
    materialized_view.service.mocked_service = mock

    materialized_view.enable_refresh = new_enable_refresh

    mock.verify

    _(materialized_view.enable_refresh?).must_equal new_enable_refresh
  end

  it "updates refresh_interval_ms" do
    new_refresh_interval_ms = 7_200_000
    mock = Minitest::Mock.new
    returned_table_gapi = materialized_view_gapi.dup
    returned_table_gapi.materialized_view.refresh_interval_ms = new_refresh_interval_ms
    patch_table_gapi = Google::Apis::BigqueryV2::Table.new(
      etag: etag,
      materialized_view: Google::Apis::BigqueryV2::MaterializedViewDefinition.new(
        refresh_interval_ms: new_refresh_interval_ms
      )
    )
    mock.expect :patch_table, returned_table_gapi, [project, dataset_id, table_id, patch_table_gapi], options: {header: {"If-Match" => etag}}    
    materialized_view.service.mocked_service = mock

    materialized_view.refresh_interval_ms = new_refresh_interval_ms

    mock.verify

    _(materialized_view.refresh_interval_ms).must_equal new_refresh_interval_ms
  end

  it "raises if query= is called" do
    new_query = "SELECT name, age, score, active FROM `external.publicdata.users` LIMIT 10"
    err = expect { materialized_view.set_query new_query }.must_raise RuntimeError
    _(err.message).must_equal "Updating the query is not supported for Table type: MATERIALIZED_VIEW"

    _(materialized_view.query).must_equal query
  end

  it "raises if set_query is called" do
    new_query = "SELECT name, age, score, active FROM `external.publicdata.users` LIMIT 10"
    err = expect { materialized_view.set_query new_query }.must_raise RuntimeError
    _(err.message).must_equal "Updating the query is not supported for Table type: MATERIALIZED_VIEW"

    _(materialized_view.query).must_equal query
  end
end
