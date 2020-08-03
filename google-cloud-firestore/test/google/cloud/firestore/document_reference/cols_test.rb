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

describe Google::Cloud::Firestore::DocumentReference, :col, :mock_firestore do
  let(:parent) { "projects/#{project}/databases/(default)/documents/users/alice" }
  let(:first_page) { list_collection_ids_resp "users", "lists", "todos", next_page_token: "next_page_token" }
  let(:second_page) { list_collection_ids_resp "users2", "lists2", "todos2", next_page_token: "next_page_token" }
  let(:last_page) { list_collection_ids_resp "users3", "lists3" }

  it "iterates collections with pagination" do
    shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path parent, firestore
    firestore_mock.expect :list_collection_ids, first_page, list_collection_ids_args(parent: parent)
    firestore_mock.expect :list_collection_ids, second_page, list_collection_ids_args(parent: parent, page_token: "next_page_token")
    firestore_mock.expect :list_collection_ids, last_page, list_collection_ids_args(parent: parent, page_token: "next_page_token")

    collections = shallow_doc.collections.to_a

    _(collections.size).must_equal 8
  end

  it "iterates collections from top-level document" do
    shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path parent, firestore

    firestore_mock.expect :list_collection_ids, list_collection_ids_resp("messages", "follows", "followers"), list_collection_ids_args(parent: shallow_doc.path)

    col_enum = shallow_doc.cols
    _(col_enum).must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(col.parent.document_id).must_equal shallow_doc.document_id
      _(col.parent.document_path).must_equal shallow_doc.document_path

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["messages", "follows", "followers"]
  end

  it "iterates collections from top-level document with a block" do
    shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path parent, firestore

    firestore_mock.expect :list_collection_ids, list_collection_ids_resp("messages", "follows", "followers"), list_collection_ids_args(parent: shallow_doc.path)

    col_ids = []
    col_enum = shallow_doc.cols do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(col.parent.document_id).must_equal shallow_doc.document_id
      _(col.parent.document_path).must_equal shallow_doc.document_path

      col_ids << col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["messages", "follows", "followers"]
  end

  it "iterates collections from nested document" do
    nested_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice/messages/abc123", firestore

    firestore_mock.expect :list_collection_ids, list_collection_ids_resp("likes", "saves", "hearts"), list_collection_ids_args(parent: nested_doc.path)

    col_enum = nested_doc.cols
    _(col_enum).must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

      _(col.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(col.parent.document_id).must_equal nested_doc.document_id
      _(col.parent.document_path).must_equal nested_doc.document_path

      col.collection_id
    end
    _(col_ids).wont_be :empty?
    _(col_ids).must_equal ["likes", "saves", "hearts"]
  end

  it "iterates collections from a document that does not exist" do
    missing_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

    firestore_mock.expect :list_collection_ids, list_collection_ids_resp, list_collection_ids_args(parent: missing_doc.path)

    col_enum = missing_doc.cols
    _(col_enum).must_be_kind_of Enumerator
    _(col_enum.to_a).must_be :empty?
  end

  describe "using collections alias" do
    it "iterates collections from top-level document" do
      shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path parent, firestore

      firestore_mock.expect :list_collection_ids, list_collection_ids_resp("messages", "follows", "followers"), list_collection_ids_args(parent: shallow_doc.path)

      col_enum = shallow_doc.collections
      _(col_enum).must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

        _(col.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
        _(col.parent.document_id).must_equal shallow_doc.document_id
        _(col.parent.document_path).must_equal shallow_doc.document_path

        col.collection_id
      end
      _(col_ids).wont_be :empty?
      _(col_ids).must_equal ["messages", "follows", "followers"]
    end

    it "iterates collections from nested document" do
      nested_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice/messages/abc123", firestore

      firestore_mock.expect :list_collection_ids, list_collection_ids_resp("likes", "saves", "hearts"), list_collection_ids_args(parent: nested_doc.path)

      col_enum = nested_doc.collections
      _(col_enum).must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        _(col).must_be_kind_of Google::Cloud::Firestore::CollectionReference

        _(col.parent).must_be_kind_of Google::Cloud::Firestore::DocumentReference
        _(col.parent.document_id).must_equal nested_doc.document_id
        _(col.parent.document_path).must_equal nested_doc.document_path

        col.collection_id
      end
      _(col_ids).wont_be :empty?
      _(col_ids).must_equal ["likes", "saves", "hearts"]
    end

    it "iterates collections from a document that does not exist" do
      missing_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

      firestore_mock.expect :list_collection_ids, list_collection_ids_resp, list_collection_ids_args(parent: missing_doc.path)

      col_enum = missing_doc.collections
      _(col_enum).must_be_kind_of Enumerator
      _(col_enum.to_a).must_be :empty?
    end
  end
end
