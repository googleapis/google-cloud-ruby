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

describe Google::Cloud::Bigquery::Table, :attributes, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_hash) { random_table_partial_hash "my_table", table_id, table_name }
  let(:table_full_hash) { random_table_hash "my_table", table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::TableList::Table.from_json table_hash.to_json }
  let(:table_full_gapi) { Google::Apis::BigqueryV2::Table.from_json table_full_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

  it "gets full data for created_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_full_gapi,
      [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    _(table.created_at).must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    table.created_at
  end

  it "gets full data for expires_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_full_gapi,
      [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    _(table.expires_at).must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    table.expires_at
  end

  it "handles nil for optional expires_at" do
    mock = Minitest::Mock.new
    g = table_full_gapi
    g.expiration_time = nil
    mock.expect :get_table, g,
      [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    _(table.expires_at).must_be :nil?

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    table.expires_at
  end

  it "gets full data for modified_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_full_gapi,
      [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    _(table.modified_at).must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    table.modified_at
  end

  it "gets full data for schema" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_full_gapi,
      [table.project_id, table.dataset_id, table.table_id]
    table.service.mocked_service = mock

    _(table.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(table.schema).must_be :frozen?
    _(table.schema.fields).wont_be :empty?
    _(table.fields).wont_be :empty?
    _(table.headers).must_equal [:name, :age, :score, :pi, :my_bignumeric, :active, :avatar, :started_at, :duration, :target_end, :birthday, :home]
    _(table.param_types).must_equal({ name: :STRING, age: :INTEGER, score: :FLOAT, pi: :NUMERIC, my_bignumeric: :BIGNUMERIC, active: :BOOLEAN, avatar: :BYTES, started_at: :TIMESTAMP, duration: :TIME, target_end: :DATETIME, birthday: :DATE, home: :GEOGRAPHY })

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    table.schema
  end

  def self.attr_test attr, val
    define_method "test_#{attr}" do
      mock = Minitest::Mock.new
      mock.expect :get_table, table_full_gapi,
        [table.project_id, table.dataset_id, table.table_id]
      table.service.mocked_service = mock

      _(table.send(attr)).must_equal val

      mock.verify

      # A second call to attribute does not make a second HTTP API call
      table.send(attr)
    end
  end

  attr_test :description, "This is my table"
  attr_test :etag, "etag123456789"
  attr_test :api_url, "http://googleapi/bigquery/v2/projects/test-project/datasets/my_table/tables/my_table"
  attr_test :bytes_count, 1000
  attr_test :rows_count, 100
  attr_test :location, "US"
  attr_test :buffer_bytes, 2000
  attr_test :buffer_rows, 200

end
