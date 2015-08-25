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
require "json"
require "uri"

describe Gcloud::Bigquery::View, :mock_bigquery do
  # Create a view object with the project's mocked connection object
  let(:dataset) { "my_dataset" }
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:view_hash) { random_view_hash dataset, table_id, table_name, description }
  let(:view) { Gcloud::Bigquery::View.from_gapi view_hash,
                                                bigquery.connection }

  it "knows its attributes" do
    view.name.must_equal table_name
    view.description.must_equal description
    view.etag.must_equal etag
    view.url.must_equal url
    view.view?.must_equal true
    view.table?.must_equal false
    view.location.must_equal location_code
  end

  it "knows its creation and modification and expiration times" do
    now = Time.now

    view.gapi["creationTime"] = (now.to_f * 1000).floor
    view.created_at.must_be_close_to now

    view.gapi["lastModifiedTime"] = (now.to_f * 1000).floor
    view.modified_at.must_be_close_to now

    view.gapi["expirationTime"] = nil
    view.expires_at.must_be :nil?

    view.gapi["expirationTime"] = (now.to_f * 1000).floor
    view.expires_at.must_be_close_to now
  end

  it "knows schema, fields, and headers" do
    view.schema.must_be_kind_of Hash
    view.schema.keys.must_include "fields"
    view.fields.must_equal view.schema["fields"]
    view.headers.must_equal ["name", "age", "score", "active"]
  end

  it "can delete itself" do
    mock_connection.delete "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    view.delete
  end

  it "can reload itself" do
    new_description = "New description of the view."
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_view_hash(dataset, table_id, table_name, new_description).to_json]
    end

    view.description.must_equal description
    view.reload!
    view.description.must_equal new_description
  end
end
