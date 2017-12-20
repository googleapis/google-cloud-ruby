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

describe Google::Cloud::BigQuery::Table, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { "foo" => "bar" } }
  let(:api_url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::BigQuery::Table.from_gapi table_gapi, bigquery.service }

  it "knows its attributes" do
    table.table_id.must_equal table_id
    table.dataset_id.must_equal dataset
    table.project_id.must_equal project
    table.table_ref.must_be_kind_of Google::Apis::BigqueryV2::TableReference
    table.table_ref.table_id.must_equal table_id
    table.table_ref.dataset_id.must_equal dataset
    table.table_ref.project_id.must_equal project

    table.name.must_equal table_name
    table.description.must_equal description
    table.etag.must_equal etag
    table.api_url.must_equal api_url
    table.bytes_count.must_equal 1000
    table.rows_count.must_equal 100
    table.table?.must_equal true
    table.view?.must_equal false
    table.location.must_equal location_code
    table.labels.must_equal labels
    table.labels.must_be :frozen?
  end

  it "knows its fully-qualified ID" do
    table.id.must_equal "#{project}:#{dataset}.#{table_id}"
  end

  it "knows its fully-qualified query ID" do
    standard_id = "`#{project}.#{dataset}.#{table_id}`"
    legacy_id = "[#{project}:#{dataset}.#{table_id}]"

    table.query_id.must_equal standard_id
    table.query_id(standard_sql: true).must_equal standard_id
    table.query_id(standard_sql: false).must_equal legacy_id
    table.query_id(legacy_sql: true).must_equal legacy_id
    table.query_id(legacy_sql: false).must_equal standard_id
  end

  it "knows its creation and modification and expiration times" do
    now = ::Time.now
    table_hash["creationTime"] = time_millis
    table_hash["lastModifiedTime"] = time_millis
    table_hash["expirationTime"] = time_millis


    table.created_at.must_be_close_to now, 1
    table.modified_at.must_be_close_to now, 1
    table.expires_at.must_be_close_to now, 1
  end

  it "can have an empty expiration times" do
    table_hash["expirationTime"] = nil

    table.expires_at.must_be :nil?
  end

  it "knows schema, fields, and headers" do
    table.schema.must_be_kind_of Google::Cloud::BigQuery::Schema
    table.schema.must_be :frozen?
    table.fields.map(&:name).must_equal table.schema.fields.map(&:name)
    table.headers.must_equal [:name, :age, :score, :active, :avatar, :started_at, :duration, :target_end, :birthday]
  end

  it "knows its streaming buffer attributes" do
    table.buffer_bytes.must_equal 2000
    table.buffer_rows.must_equal 200
    table.buffer_oldest_at.must_be_close_to ::Time.now, 1
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_table, nil,
      [project, dataset, table_id]
    table.service.mocked_service = mock

    table.delete

    mock.verify
  end
end
