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

describe Google::Cloud::Firestore::Document::Snapshot, :cols, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document_ref) { Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/#{document_path}", firestore }
  let(:document_time) { Time.now }
  let :document_grpc do
    Google::Firestore::V1beta1::Document.new(
      name: document_ref.path,
      fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(document_time)
    )
  end
  let(:document) do
    Google::Cloud::Firestore::Document::Snapshot.new.tap do |s|
      s.grpc = document_grpc
      s.instance_variable_set :@ref, document_ref
      s.instance_variable_set :@read_at, document_time
    end
  end

  it "retrieves collections from top-level document" do
    shallow_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike", firestore
    document.instance_variable_set :@ref, shallow_ref
    document.grpc.name = shallow_ref.path

    firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, [document.path, options: default_options]

    col_enum = document.cols
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"
      col.parent.document_id.must_equal document.document_id
      col.parent.document_path.must_equal document.document_path

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["messages", "follows", "followers"]
  end

  it "retrieves collections from nested document" do
    nested_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123", firestore
    document.instance_variable_set :@ref, nested_ref
    document.grpc.name = nested_ref.path

    firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, [document.path, options: default_options]

    col_enum = document.cols
    col_enum.must_be_kind_of Enumerator

    col_ids = col_enum.map do |col|
      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

      col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
      col.parent.project_id.must_equal project
      col.parent.database_id.must_equal "(default)"
      col.parent.document_id.must_equal document.document_id
      col.parent.document_path.must_equal document.document_path

      col.collection_id
    end
    col_ids.wont_be :empty?
    col_ids.must_equal ["likes", "saves", "hearts"]
  end

  it "retrieves collections from a document that does not exist" do
    missing_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore
    document.instance_variable_set :@ref, missing_ref
    document.grpc = nil

    firestore_mock.expect :list_collection_ids, [].to_enum, [document.path, options: default_options]

    col_enum = document.cols
    col_enum.must_be_kind_of Enumerator
    col_enum.to_a.must_be :empty?
  end

  describe "using collections alias" do
    it "retrieves collections from top-level document" do
      shallow_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike", firestore
      document.instance_variable_set :@ref, shallow_ref
      document.grpc.name = shallow_ref.path

      firestore_mock.expect :list_collection_ids, ["messages", "follows", "followers"].to_enum, [document.path, options: default_options]

      col_enum = document.collections
      col_enum.must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

        col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
        col.parent.project_id.must_equal project
        col.parent.database_id.must_equal "(default)"
        col.parent.document_id.must_equal document.document_id
        col.parent.document_path.must_equal document.document_path

        col.collection_id
      end
      col_ids.wont_be :empty?
      col_ids.must_equal ["messages", "follows", "followers"]
    end

    it "retrieves collections from nested document" do
      nested_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123", firestore
      document.instance_variable_set :@ref, nested_ref
      document.grpc.name = nested_ref.path

      firestore_mock.expect :list_collection_ids, ["likes", "saves", "hearts"].to_enum, [document.path, options: default_options]

      col_enum = document.collections
      col_enum.must_be_kind_of Enumerator

      col_ids = col_enum.map do |col|
        col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

        col.parent.must_be_kind_of Google::Cloud::Firestore::Document::Reference
        col.parent.project_id.must_equal project
        col.parent.database_id.must_equal "(default)"
        col.parent.document_id.must_equal document.document_id
        col.parent.document_path.must_equal document.document_path

        col.collection_id
      end
      col_ids.wont_be :empty?
      col_ids.must_equal ["likes", "saves", "hearts"]
    end

    it "retrieves collections from a document that does not exist" do
      missing_ref = Google::Cloud::Firestore::Document.from_path "projects/#{project}/databases/(default)/documents/users/doesnotexist", firestore
      document.instance_variable_set :@ref, missing_ref
      document.grpc = nil

      firestore_mock.expect :list_collection_ids, [].to_enum, [document.path, options: default_options]

      col_enum = document.collections
      col_enum.must_be_kind_of Enumerator
      col_enum.to_a.must_be :empty?
    end
  end
end
