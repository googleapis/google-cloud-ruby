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
require_relative "../data_model.rb"

describe "Google Cloud Firestore API samples - Data Model" do
  before :all do
    @firestore_project = ENV["FIRESTORE_PROJECT"]
  end

  it "document_ref" do
    document_ref project_id: @firestore_project
  end

  it "collection_ref" do
    collection_ref project_id: @firestore_project
  end

  it "document_path_ref" do
    document_path_ref project_id: @firestore_project
  end

  it "subcollection_ref" do
    subcollection_ref project_id: @firestore_project
  end
end
