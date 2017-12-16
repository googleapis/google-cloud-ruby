# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Table, :view, :attributes, :mock_bigquery do
  # Create a view object with the project's mocked connection object
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:view_hash) { random_view_small_hash "my_view", table_id, table_name }
  let(:view_full_hash) { random_view_hash "my_view", table_id, table_name, description }
  let(:view_gapi) { Google::Apis::BigqueryV2::TableList::Table.from_json view_hash.to_json }
  let(:view_full_gapi) { Google::Apis::BigqueryV2::Table.from_json view_full_hash.to_json }
  let(:view) { Google::Cloud::Bigquery::Table.from_gapi view_gapi, bigquery.service }

  it "gets full data for created_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, view_full_gapi,
      [view.project_id, view.dataset_id, view.table_id]
    view.service.mocked_service = mock

    view.created_at.must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    view.created_at
  end

  it "gets full data for expires_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, view_full_gapi,
      [view.project_id, view.dataset_id, view.table_id]
    view.service.mocked_service = mock

    view.expires_at.must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    view.expires_at
  end

  it "gets full data for modified_at" do
    mock = Minitest::Mock.new
    mock.expect :get_table, view_full_gapi,
      [view.project_id, view.dataset_id, view.table_id]
    view.service.mocked_service = mock

    view.modified_at.must_be_close_to ::Time.now, 1

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    view.modified_at
  end

  it "gets full data for schema" do
    mock = Minitest::Mock.new
    mock.expect :get_table, view_full_gapi,
      [view.project_id, view.dataset_id, view.table_id]
    view.service.mocked_service = mock

    view.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    view.schema.must_be :frozen?
    view.schema.fields.wont_be :empty?
    view.fields.wont_be :empty?
    view.headers.must_equal [:name, :age, :score, :active, :avatar, :started_at, :duration, :target_end, :birthday]

    mock.verify

    # A second call to attribute does not make a second HTTP API call
    view.schema
  end

  def self.attr_test attr, val
    define_method "test_#{attr}" do
      mock = Minitest::Mock.new
      mock.expect :get_table, view_full_gapi,
        [view.project_id, view.dataset_id, view.table_id]
      view.service.mocked_service = mock

      view.send(attr).must_equal val

      mock.verify

      # A second call to attribute does not make a second HTTP API call
      view.send(attr)
    end
  end

  attr_test :description, "This is my view"
  attr_test :etag, "etag123456789"
  attr_test :api_url, "http://googleapi/bigquery/v2/projects/test-project/datasets/my_view/tables/my_view"
  attr_test :location, "US"

end
