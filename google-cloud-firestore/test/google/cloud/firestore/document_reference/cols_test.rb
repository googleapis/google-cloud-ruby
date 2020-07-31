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
  it "retrieves collections from top-level document" do
    shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice", firestore

    firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, list_collection_ids_args(parent: shallow_doc.path)

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

  it "retrieves collections from nested document" do
    nested_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice/messages/abc123", firestore

    firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, list_collection_ids_args(parent: nested_doc.path)

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

  it "retrieves collections from a document that does not exist" do
    missing_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

    firestore_mock.expect :list_collection_ids, [].to_enum, list_collection_ids_args(parent: missing_doc.path)

    col_enum = missing_doc.cols
    _(col_enum).must_be_kind_of Enumerator
    _(col_enum.to_a).must_be :empty?
  end

  describe "using collections alias" do
    it "retrieves collections from top-level document" do
      shallow_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice", firestore

      firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, list_collection_ids_args(parent: shallow_doc.path)

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

    it "retrieves collections from nested document" do
      nested_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/alice/messages/abc123", firestore

      firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, list_collection_ids_args(parent: nested_doc.path)

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

    it "retrieves collections from a document that does not exist" do
      missing_doc = Google::Cloud::Firestore::DocumentReference.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

      firestore_mock.expect :list_collection_ids, [].to_enum, list_collection_ids_args(parent: missing_doc.path)

      col_enum = missing_doc.collections
      _(col_enum).must_be_kind_of Enumerator
      _(col_enum.to_a).must_be :empty?
    end
  end
end
