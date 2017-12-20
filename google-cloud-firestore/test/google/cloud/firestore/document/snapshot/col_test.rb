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

describe Google::Cloud::Firestore::Document::Snapshot, :col, :mock_firestore do
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

  it "gets a collection by a collection_id" do
    col = document.col "messages"

    col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    col.collection_id.must_equal "messages"
    col.collection_path.must_equal "users/mike/messages"
    col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages"
  end

  it "gets a collection by a nested collection path" do
    col = document.col "messages/abc123/likes"

    col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    col.collection_id.must_equal "likes"
    col.collection_path.must_equal "users/mike/messages/abc123/likes"
    col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123/likes"
  end

  it "does not allow a document path" do
    error = expect do
      document.col "messages/abc123"
    end.must_raise ArgumentError
    error.message.must_equal "collection_path must refer to a collection."
  end

  describe "using collection alis" do
    it "gets a collection by a collection_id" do
      col = document.col "messages"

      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      col.collection_id.must_equal "messages"
      col.collection_path.must_equal "users/mike/messages"
      col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages"
    end

    it "gets a collection by a nested collection path" do
      col = document.collection "messages/abc123/likes"

      col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      col.collection_id.must_equal "likes"
      col.collection_path.must_equal "users/mike/messages/abc123/likes"
      col.path.must_equal "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123/likes"
    end

    it "does not allow a document path" do
      error = expect do
        document.collection "messages/abc123"
      end.must_raise ArgumentError
      error.message.must_equal "collection_path must refer to a collection."
    end
  end
end
