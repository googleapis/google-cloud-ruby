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
require_relative "../query_data.rb"

describe "Google Cloud Firestore API samples - Query Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    query_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  it "query_create_examples" do
    out, _err = capture_io do
      query_create_examples project_id: @firestore_project
    end
    assert_includes out, "Added example cities data to the cities collection."
  end

  it "create_query_state" do
    out, _err = capture_io do
      create_query_state project_id: @firestore_project
    end
    assert_includes out, "Document LA returned by query state=CA."
    assert_includes out, "Document SF returned by query state=CA."
    refute_includes out, "Document BJ returned by query state=CA."
    refute_includes out, "Document TOK returned by query state=CA."
    refute_includes out, "Document DC returned by query state=CA."
  end

  it "create_query_capital" do
    out, _err = capture_io do
      create_query_capital project_id: @firestore_project
    end
    assert_includes out, "Document BJ returned by query capital=true."
    assert_includes out, "Document TOK returned by query capital=true."
    assert_includes out, "Document DC returned by query capital=true."
    refute_includes out, "Document LA returned by query capital=true."
    refute_includes out, "Document SF returned by query capital=true."
  end

  it "simple_queries" do
    out, _err = capture_io do
      simple_queries project_id: @firestore_project
    end
    assert_includes out, "Document LA returned by query state=CA."
    assert_includes out, "Document SF returned by query state=CA."
    refute_includes out, "Document BJ returned by query state=CA."
    refute_includes out, "Document TOK returned by query state=CA."
    refute_includes out, "Document DC returned by query state=CA."
    assert_includes out, "Document LA returned by query population>1000000."
    assert_includes out, "Document TOK returned by query population>1000000."
    assert_includes out, "Document BJ returned by query population>1000000."
    refute_includes out, "Document SF returned by query population>1000000."
    refute_includes out, "Document DC returned by query population>1000000."
    assert_includes out, "Document SF returned by query name>=San Francisco."
    assert_includes out, "Document TOK returned by query name>=San Francisco."
    assert_includes out, "Document DC returned by query name>=San Francisco."
    refute_includes out, "Document BJ returned by query name>=San Francisco."
    refute_includes out, "Document LA returned by query name>=San Francisco."
  end

  it "chained_query" do
    out, _err = capture_io do
      chained_query project_id: @firestore_project
    end
    assert_includes out, "Document SF returned by query state=CA and name=San Francisco."
    refute_includes out, "Document LA returned by query state=CA and name=San Francisco."
    refute_includes out, "Document DC returned by query state=CA and name=San Francisco."
    refute_includes out, "Document TOK returned by query state=CA and name=San Francisco."
    refute_includes out, "Document BJ returned by query state=CA and name=San Francisco."
  end

  it "composite_index_chained_query" do
    skip "The query requires an index."
    out, _err = capture_io do
      composite_index_chained_query project_id: @firestore_project
    end
    assert_includes out, "Document SF returned by query state=CA and population<1000000."
    refute_includes out, "Document LA returned by query state=CA and population<1000000."
    refute_includes out, "Document DC returned by query state=CA and population<1000000."
    refute_includes out, "Document TOK returned by query state=CA and population<1000000."
    refute_includes out, "Document BJ returned by query state=CA and population<1000000."
  end

  it "range_query" do
    out, _err = capture_io do
      range_query project_id: @firestore_project
    end
    assert_includes out, "Document SF returned by query CA<=state<=IN."
    assert_includes out, "Document LA returned by query CA<=state<=IN."
    refute_includes out, "Document DC returned by query CA<=state<=IN."
    refute_includes out, "Document TOK returned by query CA<=state<=IN."
    refute_includes out, "Document BJ returned by query CA<=state<=IN."
  end

  it "invalid_range_query" do
    invalid_range_query project_id: @firestore_project
  end

  it "in_query_without_array" do
    out, _err = capture_io do
      in_query_without_array project_id: @firestore_project
    end

    assert_includes out, "Document SF returned by query in ['USA','Japan']."
    assert_includes out, "Document LA returned by query in ['USA','Japan']."
    assert_includes out, "Document DC returned by query in ['USA','Japan']."
    assert_includes out, "Document TOK returned by query in ['USA','Japan']."
    refute_includes out, "Document BJ returned by query in ['USA','Japan']."
  end

  it "in_query_with_array" do
    out, _err = capture_io do
      in_query_with_array project_id: @firestore_project
    end

    assert_includes out, "Document DC returned by query in [['west_coast'], ['east_coast']]."
    refute_includes out, "Document SF returned by query in [['west_coast'], ['east_coast']]."
    refute_includes out, "Document LA returned by query in [['west_coast'], ['east_coast']]."
    refute_includes out, "Document TOK returned by query in [['west_coast'], ['east_coast']]."
    refute_includes out, "Document BJ returned by query in [['west_coast'], ['east_coast']]."
  end

  it "array_contains_any_queries" do
    out, _err = capture_io do
      array_contains_any_queries project_id: @firestore_project
    end
    assert_includes out, "Document SF returned by query array-contains-any ['west_coast', 'east_coast']."
    assert_includes out, "Document LA returned by query array-contains-any ['west_coast', 'east_coast']."
    assert_includes out, "Document DC returned by query array-contains-any ['west_coast', 'east_coast']."
    refute_includes out, "Document TOK returned by query array-contains-any ['west_coast', 'east_coast']."
    refute_includes out, "Document BJ returned by query array-contains-any ['west_coast', 'east_coast']."
  end

  it "array_contains_filter" do
    out, _err = capture_io do
      array_contains_filter project_id: @firestore_project
    end
    assert_includes out, "Document SF returned by query array-contains 'west_coast'."
    assert_includes out, "Document LA returned by query array-contains 'west_coast'."
    refute_includes out, "Document DC returned by query array-contains 'west_coast'."
    refute_includes out, "Document TOK returned by query array-contains 'west_coast'."
    refute_includes out, "Document BJ returned by query array-contains 'west_coast'."
  end

  it "collection_group_query" do
    skip "The query requires an index."
    out, _err = capture_io do
      collection_group_query project_id: @firestore_project
    end
    assert_includes out, "museum name is The Getty."
    assert_includes out, "museum name is Legion of Honor."
    assert_includes out, "museum name is National Museum of Nature and Science."
    assert_includes out, "museum name is National Air and Space Museum."
    assert_includes out, "museum name is Beijing Ancient Observatory."
    refute_includes out, "park name is Griffith Park."
    refute_includes out, "memorial name is Lincoln Memorial."
    refute_includes out, "bridge name is Golden Gate Bridge."
  end
end
