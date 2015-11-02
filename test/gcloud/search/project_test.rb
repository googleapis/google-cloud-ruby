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

describe Gcloud::Search::Project, :mock_search do
  it "exists" do
    search.must_be_kind_of Gcloud::Search::Project
  end

  it "gets an index" do
    index_id = "found_index"

    mock_connection.get "/v1/projects/#{project}/indexes" do |env|
      env.params.must_include "indexNamePrefix"
      env.params.wont_include "pageSize"
      env.params.wont_include "pageToken"
      env.params["indexNamePrefix"].must_equal index_id
      [200, {"Content-Type"=>"application/json"},
       get_index_json(index_id)]
    end

    index = search.index index_id
    index.must_be_kind_of Gcloud::Search::Index
    index.index_id.must_equal index_id
  end

  it "gets nil if an index is not found" do
    index_id = "not_found_index"
    mock_connection.get "/v1/projects/#{project}/indexes" do |env|
      env.params.must_include "indexNamePrefix"
      env.params.wont_include "pageSize"
      env.params.wont_include "pageToken"
      env.params["indexNamePrefix"].must_equal index_id
      [200, {"Content-Type"=>"application/json"},
       list_index_json(0)]
    end

    index = search.index index_id
    index.must_be :nil?
  end

  it "gets nil if the returned indexes do not match" do
    index_id = "not_found_index"
    mock_connection.get "/v1/projects/#{project}/indexes" do |env|
      env.params.must_include "indexNamePrefix"
      env.params.wont_include "pageSize"
      env.params.wont_include "pageToken"
      env.params["indexNamePrefix"].must_equal index_id
      [200, {"Content-Type"=>"application/json"},
       list_index_json(3)]
    end

    index = search.index index_id
    index.must_be :nil?
  end

  def random_index_hash index_id = nil
    index_id ||= "rnd_index_#{rand 999999}"
    {
      "projectId" => project,
      "indexId" => index_id,
      "indexedField" => {
        "textFields" => ["title", "body"],
        "htmlFields" => ["body"],
        "atomFields" => ["slug"],
        "dateFields" => ["published"],
        "numberFields" => ["likes"],
        "geoFields" => ["location"]
      }
    }
  end

  def get_index_json index_id
    { "indexes" => [random_index_hash(index_id)] }.to_json
  end

  def list_index_json index_count, token = nil
    {
      "indexes" => index_count.times.map { random_index_hash },
      "nextPageToken" => token,
    }.delete_if { |_, v| v.nil? }.to_json
  end
end
