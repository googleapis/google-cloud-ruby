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

describe Gcloud::Bigquery::View, :attributes, :mock_bigquery do
  # Create a view object with the project's mocked connection object
  let(:table_id) { "my_view" }
  let(:table_name) { "My View" }
  let(:description) { "This is my view" }
  let(:view_hash) { random_view_small_hash "my_view", table_id, table_name }
  let(:view_full_json) { random_view_hash("my_view", table_id, table_name, description).to_json }
  let(:view) { Gcloud::Bigquery::View.from_gapi view_hash,
                                                bigquery.connection }

  it "gets full data for created_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       view_full_json]
    end

    view.created_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    view.created_at
  end

  it "gets full data for expires_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       view_full_json]
    end

    view.expires_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    view.expires_at
  end

  it "gets full data for modified_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       view_full_json]
    end

    view.modified_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    view.modified_at
  end

  it "gets full data for schema" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       view_full_json]
    end

    view.schema.must_be_kind_of Hash
    view.schema.keys.must_include "fields"
    view.fields.must_equal view.schema["fields"]
    view.headers.must_equal ["name", "age", "score", "active"]

    # A second call to attribute does not make a second HTTP API call
    view.schema
  end

  def self.attr_test attr, val
    define_method "test_#{attr}" do
      mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{view.dataset_id}/tables/#{view.table_id}" do |env|
        [200, {"Content-Type"=>"application/json"},
         view_full_json]
      end

      view.send(attr).must_equal val

      # A second call to attribute does not make a second HTTP API call
      view.send(attr)
    end
  end

  attr_test :description, "This is my view"
  attr_test :etag, "etag123456789"
  attr_test :url, "http://googleapi/bigquery/v2/projects/test/datasets/my_view/tables/my_view"
  attr_test :location, "US"

end
