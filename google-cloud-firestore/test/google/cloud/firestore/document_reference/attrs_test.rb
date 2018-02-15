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

describe Google::Cloud::Firestore::DocumentReference, :attrs, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }

  it "represents a document reference" do
    document.must_be_kind_of Google::Cloud::Firestore::DocumentReference
    document.document_id.must_equal "mike"
    document.document_path.must_equal document_path
    document.path.must_equal "projects/projectID/databases/(default)/documents/users/mike"

    document.parent.must_be_kind_of Google::Cloud::Firestore::CollectionReference
    document.parent.collection_id.must_equal "users"
    document.parent.collection_path.must_equal "users"
    document.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"
  end
end
