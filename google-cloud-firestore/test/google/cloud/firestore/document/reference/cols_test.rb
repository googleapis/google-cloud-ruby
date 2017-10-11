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

describe Google::Cloud::Firestore::Document::Reference, :col, :mock_firestore do
  it "retrieves collections from top-level document" do
    shallow_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike", firestore

    firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, [shallow_doc.path, options: default_options]

    col_enum = shallow_doc.cols
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"
      col.parent.document_id.must_equal shallow_doc.document_id
      col.parent.document_path.must_equal shallow_doc.document_path

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["messages", "follows", "followers"]
  end

  it "retrieves collections from nested document" do
    nested_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123", firestore

    firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, [nested_doc.path, options: default_options]

    col_enum = nested_doc.cols
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"
      col.parent.document_id.must_equal nested_doc.document_id
      col.parent.document_path.must_equal nested_doc.document_path

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["likes", "saves", "hearts"]
  end

  it "retrieves collections from a document that does not exist" do
    missing_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

    firestore_mock.expect :list_collection_ids, [].to_enum, [missing_doc.path, options: default_options]

    col_enum = missing_doc.cols
    col_enum.must_be_kind_of Enumerator
    col_enum.to_a.must_be :empty?
  end

  describe "using collections alias" do
    it "retrieves collections from top-level document" do
      shallow_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike", firestore

      firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, [shallow_doc.path, options: default_options]

      col_enum = shallow_doc.collections
      col_enum.must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

        col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
        col.parent.project_id.must_equal project
        col.parent.database_id.must_equal "(default)"
        col.parent.document_id.must_equal shallow_doc.document_id
        col.parent.document_path.must_equal shallow_doc.document_path

        col.collection_id
      end
      col_ids.wont_be :empty?
      col_ids.must_equal ["messages", "follows", "followers"]
    end

    it "retrieves collections from nested document" do
      nested_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123", firestore

      firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, [nested_doc.path, options: default_options]

      col_enum = nested_doc.collections
      col_enum.must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

        col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
        col.parent.project_id.must_equal project
        col.parent.database_id.must_equal "(default)"
        col.parent.document_id.must_equal nested_doc.document_id
        col.parent.document_path.must_equal nested_doc.document_path

        col.collection_id
      end
      col_ids.wont_be :empty?
      col_ids.must_equal ["likes", "saves", "hearts"]
    end

    it "retrieves collections from a document that does not exist" do
      missing_doc = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore

      firestore_mock.expect :list_collection_ids, [].to_enum, [missing_doc.path, options: default_options]

      col_enum = missing_doc.collections
      col_enum.must_be_kind_of Enumerator
      col_enum.to_a.must_be :empty?
    end
  end
end
