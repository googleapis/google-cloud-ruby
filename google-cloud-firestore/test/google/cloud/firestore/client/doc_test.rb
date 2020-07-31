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

describe Google::Cloud::Firestore::Client, :doc, :mock_firestore do
  it "produces a Document reference for a document_path" do
    document_path = "users/alice"

    document = firestore.doc document_path

    _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(document.document_id).must_equal "alice"
    _(document.document_path).must_equal document_path
    _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice"

    _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(document.parent.collection_id).must_equal "users"
    _(document.parent.collection_path).must_equal "users"
    _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"
  end

  it "does not allow a collection_id" do
    error = expect do
      firestore.doc "users"
    end.must_raise ArgumentError
    _(error.message).must_equal "document_path must refer to a document."
  end

  it "does not allow a collection_path" do
    error = expect do
      firestore.doc "users/alice/messages"
    end.must_raise ArgumentError
    _(error.message).must_equal "document_path must refer to a document."
  end
end
