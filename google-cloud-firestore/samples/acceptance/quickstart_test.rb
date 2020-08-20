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
require_relative "../quickstart.rb"

describe "Google Cloud Firestore API samples - Quickstart" do
  before do
    @firestore_project = ENV["FIRESTORE_PROJECT_ID"]
  end

  after do
    delete_collection_test collection_name: "users", project_id: ENV["FIRESTORE_PROJECT_ID"]
  end

  it "initialize_firestore_client" do
    out, _err = capture_io do
      initialize_firestore_client project_id: @firestore_project
    end
    assert_includes out, "Created Cloud Firestore client with given project ID."
  end

  it "add_data_1" do
    out, _err = capture_io do
      add_data_1 project_id: @firestore_project
    end
    assert_includes out, "Added data to the alovelace document in the users collection."
  end

  it "add_data_2" do
    out, _err = capture_io do
      add_data_2 project_id: @firestore_project
    end
    assert_includes out, "Added data to the aturing document in the users collection."
  end

  it "get_all" do
    add_data_1 project_id: @firestore_project
    add_data_2 project_id: @firestore_project
    out, _err = capture_io do
      get_all project_id: @firestore_project
    end
    assert_includes out, "alovelace data:"
    assert_includes out, ':first=>"Ada"'
    assert_includes out, ':last=>"Lovelace"'
    assert_includes out, ":born=>1815"
    assert_includes out, "aturing data:"
    assert_includes out, ':first=>"Alan"'
    assert_includes out, ':middle=>"Mathison"'
    assert_includes out, ':last=>"Turing"'
    assert_includes out, ":born=>1912"
  end
end
