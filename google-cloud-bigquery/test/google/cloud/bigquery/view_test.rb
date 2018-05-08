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

describe Google::Cloud::Bigquery::Table, :view, :mock_bigquery do
  # Create a view object with the project's mocked connection object
  let(:dataset) { "my_dataset" }
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:api_url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:view_hash) { random_view_hash dataset, table_id, table_name, description }
  let(:view_gapi) { Google::Apis::BigqueryV2::Table.from_json view_hash.to_json }
  let(:view) { Google::Cloud::Bigquery::Table.from_gapi view_gapi,
                                                bigquery.service }

  it "knows its attributes" do
    view.name.must_equal table_name
    view.description.must_equal description
    view.etag.must_equal etag
    view.api_url.must_equal api_url
    view.query.must_equal "SELECT name, age, score, active FROM `external.publicdata.users`"
    view.wont_be :query_standard_sql?
    view.must_be :query_legacy_sql?
    view.query_udfs.must_be :empty?
    view.view?.must_equal true
    view.table?.must_equal false
    view.location.must_equal location_code
  end

  it "knows its creation and modification and expiration times" do
    now = ::Time.now
    view_hash["creationTime"] = time_millis
    view_hash["lastModifiedTime"] = time_millis
    view_hash["expirationTime"] = time_millis


    view.created_at.must_be_close_to now, 1
    view.modified_at.must_be_close_to now, 1
    view.expires_at.must_be_close_to now, 1
  end

  it "knows schema, fields, and headers" do
    view.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    view.schema.must_be :frozen?
    view.fields.map(&:name).must_equal view.schema.fields.map(&:name)
    view.headers.must_equal [:name, :age, :score, :pi, :active, :avatar, :started_at, :duration, :target_end, :birthday]
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_table, nil,
      [project, dataset, table_id]
    view.service.mocked_service = mock

    view.delete

    mock.verify
  end

  it "can reload itself" do
    new_description = "New description of the view."

    mock = Minitest::Mock.new
    view_hash = random_view_hash dataset, table_id, table_name, new_description
    mock.expect :get_table, Google::Apis::BigqueryV2::Table.from_json(view_hash.to_json),
      [project, dataset, table_id]
    view.service.mocked_service = mock

    view.description.must_equal description
    view.reload!

    mock.verify

    view.description.must_equal new_description
  end
end
