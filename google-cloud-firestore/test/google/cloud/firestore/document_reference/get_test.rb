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

describe Google::Cloud::Firestore::DocumentReference, :get, :mock_firestore do
  let(:read_time) { Time.now }


  let :found_doc_enum do
    [
      Google::Cloud::Firestore::V1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/alice",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end
  let :missing_doc_enum do
    [
      Google::Cloud::Firestore::V1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        missing: "projects/#{project}/databases/(default)/documents/users/bob")
    ].to_enum
  end

  it "gets a found snapshot" do
    firestore_mock.expect :batch_get_documents, found_doc_enum, batch_get_documents_args(documents: ["#{documents_path}/users/alice"])

    doc_ref = firestore.doc "users/alice"
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    doc = doc_ref.get

    _(doc).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
    _(doc.document_id).must_equal doc_ref.document_id
    _(doc.document_path).must_equal doc_ref.document_path

    _(doc.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(doc.parent.collection_id).must_equal "users"
    _(doc.parent.collection_path).must_equal "users"

    _(doc).must_be :exists?
    _(doc.data).must_be_kind_of Hash
    _(doc.data).must_equal({ name: "Alice" })
    _(doc.created_at).must_equal read_time
    _(doc.updated_at).must_equal read_time
    _(doc.read_at).must_equal read_time
  end

  it "gets a missing snapshot" do
    firestore_mock.expect :batch_get_documents, missing_doc_enum, batch_get_documents_args(documents: ["#{documents_path}/users/bob"])

    doc_ref = firestore.doc "users/bob"
    _(doc_ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference

    doc = doc_ref.get

    _(doc).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
    _(doc.document_id).must_equal doc_ref.document_id
    _(doc.document_path).must_equal doc_ref.document_path

    _(doc.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(doc.parent.collection_id).must_equal "users"
    _(doc.parent.collection_path).must_equal "users"

    _(doc).must_be :missing?
    _(doc.data).must_be :nil?
    _(doc.created_at).must_be :nil?
    _(doc.updated_at).must_be :nil?
    _(doc.read_at).must_equal read_time
  end
end
