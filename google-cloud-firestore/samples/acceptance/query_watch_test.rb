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
require_relative "../query_watch"

describe "Google Cloud Firestore API samples - Query Data" do
  before do
    skip if Google::Cloud.configure.firestore.transport == :rest
    @firestore_project = ENV["FIRESTORE_PROJECT"]
    @collection_path = random_name "cities"
  end

  after do
    delete_collection_test collection_name: @collection_path, project_id: @firestore_project
  end

  it "listen_document" do
    document_path = random_name "SF"

    out, _err = capture_io do
      listen_document project_id: @firestore_project, collection_path: @collection_path, document_path: document_path
    end

    assert_includes out, "Received document snapshot: #{document_path}"
  end

  it "listen_changes" do
    out, _err = capture_io do
      listen_changes project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Callback received query snapshot."
    assert_includes out, "Current cities in California:"
    assert_includes out, "New city: MTV"
    assert_includes out, "Modified city: MTV"
    assert_includes out, "Removed city: MTV"
  end

  it "listen_errors" do
    out, err = capture_io do
      listen_errors project_id: @firestore_project, collection_path: @collection_path
    end
    assert_empty out
    assert_empty err
  end

  it "listen_multiple" do
    out, _err = capture_io do
      listen_multiple project_id: @firestore_project, collection_path: @collection_path
    end
    assert_includes out, "Callback received query snapshot."
    assert_includes out, "Current cities in California:"
    assert_includes out, "SF"
  end
end
