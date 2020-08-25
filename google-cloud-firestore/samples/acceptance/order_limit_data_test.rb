# Copyright 2020 Google LLC
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

require_relative "helper.rb"
require_relative "../get_data.rb"
require_relative "../order_limit_data.rb"

describe "Google Cloud Firestore API samples - Order Limit Data" do
  before :all do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    @collection_path = random_name "cities"
    retrieve_create_examples project_id: @firestore_project, collection_path: @collection_path
  end

  after :all do
    delete_collection_test collection_name: @collection_path, project_id: ENV["FIRESTORE_PROJECT"]
  end

  it "order_by_name_limit_query" do
    out, _err = capture_io do
      order_by_name_limit_query project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Document BJ returned by order by name with limit query."
    assert_includes out, "Document LA returned by order by name with limit query."
    assert_includes out, "Document SF returned by order by name with limit query."
    refute_includes out, "Document TOK returned by order by name with limit query."
    refute_includes out, "Document DC returned by order by name with limit query."
  end

  it "order_by_name_desc_limit_query" do
    out, _err = capture_io do
      order_by_name_desc_limit_query project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Document DC returned by order by name descending with limit query."
    assert_includes out, "Document TOK returned by order by name descending with limit query."
    assert_includes out, "Document SF returned by order by name descending with limit query."
    refute_includes out, "Document LA returned by order by name descending with limit query."
    refute_includes out, "Document BJ returned by order by name descending with limit query."
  end

  it "order_by_state_and_population_query" do
    skip "The query requires an index."
    out, _err = capture_io do
      order_by_state_and_population_query project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Document LA returned by order by state and descending population query."
    assert_includes out, "Document SF returned by order by state and descending population query."
    assert_includes out, "Document BJ returned by order by state and descending population query."
    assert_includes out, "Document TOK returned by order by state and descending population query."
    assert_includes out, "Document DC returned by order by state and descending population query."
  end

  it "where_order_by_limit_query" do
    out, _err = capture_io do
      where_order_by_limit_query project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Document LA returned by where order by limit query."
    assert_includes out, "Document TOK returned by where order by limit query."
    refute_includes out, "Document BJ returned by where order by limit query."
    refute_includes out, "Document SF returned by where order by limit query."
    refute_includes out, "Document DC returned by where order by limit query."
  end

  it "range_order_by_query" do
    out, _err = capture_io do
      range_order_by_query project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Document LA returned by range with order by query."
    assert_includes out, "Document TOK returned by range with order by query."
    assert_includes out, "Document BJ returned by range with order by query."
    refute_includes out, "Document SF returned by range with order by query."
    refute_includes out, "Document DC returned by range with order by query."
  end

  it "invalid_range_order_by_query" do
    invalid_range_order_by_query project_id: @firestore_project, collection_path: @collection_path
  end
end
