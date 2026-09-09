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

describe Google::Cloud::Firestore::CollectionReference, :doc, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/alice/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  it "produces a Document reference for a document_id" do
    document_id = "abc123"

    document = collection.doc document_id

    _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(document.document_id).must_equal document_id
    _(document.document_path).must_equal "#{collection_path}/#{document_id}"
    _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123"

    _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(document.parent.collection_id).must_equal collection_id
    _(document.parent.collection_path).must_equal collection_path
    _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"
  end

  it "produces a Document reference for a document_path" do
    document_path = "abc123/likes/xyz789"

    document = collection.doc document_path

    _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
    _(document.document_id).must_equal "xyz789"
    _(document.document_path).must_equal "users/alice/messages/abc123/likes/xyz789"
    _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123/likes/xyz789"

    _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(document.parent.collection_id).must_equal "likes"
    _(document.parent.collection_path).must_equal "users/alice/messages/abc123/likes"
    _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123/likes"
  end

  it "creates a Document reference with a random id" do
    random_document_id = "helloiamarandomdocid"
    Google::Cloud::Firestore::Generate.stub :unique_id, random_document_id do
      document = collection.doc

      _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document.document_id).must_equal random_document_id
      _(document.document_path).must_equal "#{collection_path}/#{random_document_id}"
      _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/helloiamarandomdocid"

      _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(document.parent.collection_id).must_equal collection_id
      _(document.parent.collection_path).must_equal collection_path
      _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"
    end
  end

  it "does not allow a collection path" do
    error = expect do
      collection.doc "abc123/likes"
    end.must_raise ArgumentError
    _(error.message).must_equal "document_path must refer to a document."
  end

  describe "using document alias" do
    it "produces a Document reference for a document_id" do
      document_id = "abc123"

      document = collection.document document_id

      _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document.document_id).must_equal document_id
      _(document.document_path).must_equal "#{collection_path}/#{document_id}"
      _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123"

      _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(document.parent.collection_id).must_equal collection_id
      _(document.parent.collection_path).must_equal collection_path
      _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"
    end

    it "produces a Document reference for a document_path" do
      document_path = "abc123/likes/xyz789"

      document = collection.document document_path

      _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(document.document_id).must_equal "xyz789"
      _(document.document_path).must_equal "users/alice/messages/abc123/likes/xyz789"
      _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123/likes/xyz789"

      _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(document.parent.collection_id).must_equal "likes"
      _(document.parent.collection_path).must_equal "users/alice/messages/abc123/likes"
      _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/abc123/likes"
    end

    it "creates a Document reference with a random id" do
      random_document_id = "helloiamarandomdocid"
      Google::Cloud::Firestore::Generate.stub :unique_id, random_document_id do
        document = collection.document

        _(document).must_be_kind_of Google::Cloud::Firestore::DocumentReference
        _(document.document_id).must_equal random_document_id
        _(document.document_path).must_equal "#{collection_path}/#{random_document_id}"
        _(document.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages/helloiamarandomdocid"

        _(document.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
        _(document.parent.collection_id).must_equal collection_id
        _(document.parent.collection_path).must_equal collection_path
        _(document.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"
      end
    end

    it "does not allow a collection path" do
      error = expect do
        collection.document "abc123/likes"
      end.must_raise ArgumentError
      _(error.message).must_equal "document_path must refer to a document."
    end
  end
end
