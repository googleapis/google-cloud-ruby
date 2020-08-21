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

describe "Google Cloud Firestore API samples - Get Data" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    retrieve_create_examples project_id: @firestore_project
  end

  after do
    delete_collection_test collection_name: "cities/SF/neighborhoods", project_id: ENV["FIRESTORE_PROJECT"]
    delete_collection_test collection_name: "cities", project_id: ENV["FIRESTORE_PROJECT"]
  end

  it "retrieve_create_examples" do
    out, _err = capture_io do
      retrieve_create_examples project_id: @firestore_project
    end
    assert_includes out, "Added example cities data to the cities collection."
  end

  it "get_document" do
    out, _err = capture_io do
      get_document project_id: @firestore_project
    end
    assert_includes out, "SF data:"
    assert_includes out, ':name=>"San Francisco"'
    assert_includes out, ':state=>"CA"'
    assert_includes out, ':country=>"USA"'
    assert_includes out, ":capital=>false"
    assert_includes out, ":population=>860000"
  end

  it "get_multiple_docs" do
    out, _err = capture_io do
      get_multiple_docs project_id: @firestore_project
    end
    assert_includes out, "DC data:"
    assert_includes out, "TOK data:"
    assert_includes out, "BJ data:"
    refute_includes out, "SF data:"
    refute_includes out, "LA data:"
    assert_includes out, ':name=>"Tokyo"'
    assert_includes out, ":state=>nil"
    assert_includes out, ':country=>"Japan"'
    assert_includes out, ":capital=>true"
    assert_includes out, ":population=>9000000"
  end

  it "get_all_docs" do
    out, _err = capture_io do
      get_all_docs project_id: @firestore_project
    end
    assert_includes out, "DC data:"
    assert_includes out, "TOK data:"
    assert_includes out, "BJ data:"
    assert_includes out, "SF data:"
    assert_includes out, "LA data:"
    assert_includes out, ':name=>"Los Angeles"'
    assert_includes out, ':state=>"CA"'
    assert_includes out, ':country=>"USA"'
    assert_includes out, ":capital=>false"
    assert_includes out, ":population=>3900000"
  end

  it "add_subcollection" do
    out, _err = capture_io do
      add_subcollection project_id: @firestore_project
    end
    assert_includes out, "Added document with ID:"
  end

  it "list_subcollections" do
    add_subcollection project_id: @firestore_project
    out, _err = capture_io do
      list_subcollections project_id: @firestore_project
    end
    assert_includes out, "neighborhoods"
  end
end
