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
  let(:dataset) { "my_dataset" }
  let(:table_id) { "my_materialized_view" }
  let(:table_name) { "My Materialized View" }
  let(:description) { "This is my materialized view" }
  let(:materialized_view_hash) { random_materialized_view_hash dataset, table_id, table_name, description }
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
    _(materialized_view.query).must_equal "SELECT name, age, score, active FROM `external.publicdata.users`"
    _(materialized_view.refresh_interval_ms).must_equal 3600000
  end
end
