# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Firestore::CollectionReference, :parent, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/alice/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  it "represents a nested collection reference" do
    _(collection).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(collection.collection_id).must_equal collection_id
    _(collection.collection_path).must_equal collection_path
    _(collection.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"

    _(collection.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(collection.parent.document_id).must_equal "alice"
    _(collection.parent.document_path).must_equal "users/alice"
    _(collection.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice"
  end

  it "represents a top-level collection reference" do
    collection = Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_id}", firestore

    _(collection).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(collection.collection_id).must_equal collection_id
    _(collection.collection_path).must_equal collection_id
    _(collection.path).must_equal "projects/projectID/databases/(default)/documents/messages"

    _(collection.parent).must_be_kind_of Google::Cloud::Firestore::Client
    _(collection.parent.path).must_equal "projects/projectID/databases/(default)"
  end
end
