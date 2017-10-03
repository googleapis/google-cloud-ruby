# Copyright 2017, Google Inc. All rights reserved.
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

describe Google::Cloud::Firestore::Collection, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/mike/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::Collection.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  it "represents a collection reference" do
    collection = Google::Cloud::Firestore::Collection.from_path "projects/#{project}/databases/(default)/documents/#{collection_id}", firestore

    collection.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    collection.project_id.must_equal project
    collection.database_id.must_equal "(default)"
    collection.collection_id.must_equal collection_id
    collection.collection_path.must_equal collection_id
    collection.path.must_equal "projects/test/databases/(default)/documents/messages"

    collection.parent.must_be_kind_of Google::Cloud::Firestore::Database
    collection.parent.project_id.must_equal project
    collection.parent.database_id.must_equal "(default)"
    collection.parent.path.must_equal "projects/test/databases/(default)"
  end
end
