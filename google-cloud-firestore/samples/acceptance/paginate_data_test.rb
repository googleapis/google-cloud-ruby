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
require_relative "../paginate_data.rb"

describe "Google Cloud Firestore API samples - Paginate Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
    retrieve_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  it "start_at_field_query_cursor" do
    out, _err = capture_io do
      start_at_field_query_cursor project_id: @firestore_project
    end
    assert_includes out, "Document LA returned by start at population 1000000 field query cursor."
    assert_includes out, "Document TOK returned by start at population 1000000 field query cursor."
    assert_includes out, "Document BJ returned by start at population 1000000 field query cursor."
    refute_includes out, "Document SF returned by start at population 1000000 field query cursor."
    refute_includes out, "Document DC returned by start at population 1000000 field query cursor."
  end

  it "end_at_field_query_cursor" do
    out, _err = capture_io do
      end_at_field_query_cursor project_id: @firestore_project
    end
    assert_includes out, "Document DC returned by end at population 1000000 field query cursor."
    assert_includes out, "Document SF returned by end at population 1000000 field query cursor."
    refute_includes out, "Document LA returned by end at population 1000000 field query cursor."
    refute_includes out, "Document TOK returned by end at population 1000000 field query cursor."
    refute_includes out, "Document BJ returned by end at population 1000000 field query cursor."
  end

  it "paginated_query_cursor" do
    out, _err = capture_io do
      paginated_query_cursor project_id: @firestore_project
    end
    refute_includes out, "Document DC returned by paginated query cursor."
    refute_includes out, "Document SF returned by paginated query cursor."
    refute_includes out, "Document LA returned by paginated query cursor."
    assert_includes out, "Document TOK returned by paginated query cursor."
    assert_includes out, "Document BJ returned by paginated query cursor."
  end

  it "multiple_cursor_conditions" do
    skip "The query requires an index."
    out, _err = capture_io do
      multiple_cursor_conditions project_id: @firestore_project
    end
    refute_includes out, "Document BJ returned by start at Springfield query."
    refute_includes out, "Document LA returned by start at Springfield query."
    refute_includes out, "Document SF returned by start at Springfield query."
    assert_includes out, "Document TOK returned by start at Springfield query."
    assert_includes out, "Document DC returned by start at Springfield query."
  end
end
