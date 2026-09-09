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

require_relative "helper"
require_relative "../add_data"

describe "Google Cloud Firestore API samples - Add Data" do
  before :all do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    @collection_path = random_name "cities"
  end

  after :all do
    delete_collection_test collection_name: @collection_path, project_id: @firestore_project
  end

  it "set_document" do
    out, _err = capture_io do
      set_document project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Set data for the LA document in the cities collection."
  end

  it "update_create_if_missing" do
    out, _err = capture_io do
      update_create_if_missing project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Merged data into the LA document in the cities collection."
  end

  it "set_document_data_types" do
    out, _err = capture_io do
      set_document_data_types project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Set multiple data-type data for the one document in the data collection."
  end

  it "set_requires_id" do
    out, _err = capture_io do
      set_requires_id project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Added document with ID: new-city-id."
  end

  it "add_doc_data_with_auto_id" do
    out, _err = capture_io do
      add_doc_data_with_auto_id project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Added document with ID:"
  end

  it "add_doc_data_after_auto_id" do
    out, _err = capture_io do
      add_doc_data_after_auto_id project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Added document with ID:"
    assert_includes out, "Added data to the"
    assert_includes out, "document in the cities collection."
  end

  it "update_doc" do
    out, _err = capture_io do
      update_doc project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Updated the capital field of the DC document in the cities collection."
  end

  it "update_doc_array" do
    out, _err = capture_io do
      update_doc_array project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Updated the regions field of the DC document in the cities collection."
  end

  it "update_nested_fields" do
    out, _err = capture_io do
      update_nested_fields project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Updated the age and favorite color fields of the frank document in the users collection."
  end

  it "update_server_timestamp" do
    out, _err = capture_io do
      set_requires_id project_id: @firestore_project, collection_path: @collection_path
      update_server_timestamp project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Updated the timestamp field of the new-city-id document in the cities collection."
  end

  it "update_document_increment" do
    out, _err = capture_io do
      set_requires_id project_id: @firestore_project, collection_path: @collection_path
      update_document_increment project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Updated the population of the DC document in the cities collection."
  end
end
