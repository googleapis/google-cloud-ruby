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

describe Google::Cloud::Firestore::Database, :get_all, :using_snapshot, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:snapshot) do
    Google::Cloud::Firestore::Snapshot.from_database(firestore).tap do |b|
      b.instance_variable_set :@transaction_id, transaction_id
    end
  end
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/mike/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::Collection.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", snapshot }

  let(:read_time) { Time.now }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:full_doc_paths) {
    ["#{documents_path}/#{collection_path}/abc123", "#{documents_path}/#{collection_path}/doesnotexist", "#{documents_path}/#{collection_path}/xyz789"]
  }
  let :batch_docs_enum do
    [
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike/messages/abc123",
          fields: { "body" => Google::Firestore::V1beta1::Value.new(string_value: "LGTM") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        missing: "projects/#{project}/databases/(default)/documents/users/mike/messages/doesnotexist"),
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike/messages/xyz789",
          fields: { "body" => Google::Firestore::V1beta1::Value.new(string_value: "PTAL") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end
  let(:body_mask) { Google::Firestore::V1beta1::DocumentMask.new field_paths: ["body"] }

  it "gets multiple docs using splat (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all "abc123", "doesnotexist", "xyz789"

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all ["abc123", "doesnotexist", "xyz789"]

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using splat (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all collection.doc("abc123"), collection.doc("doesnotexist"), collection.doc("xyz789")

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all [collection.doc("abc123"), collection.doc("doesnotexist"), collection.doc("xyz789")]

    assert_docs_enum docs_enum
  end

  it "gets a single doc (string)" do
    firestore_mock.expect :batch_get_documents, [batch_docs_enum.to_a.first].to_enum, [database_path, [full_doc_paths.first], mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all "abc123"

    docs_enum.must_be_kind_of Enumerator

    docs = docs_enum.to_a
    docs.count.must_equal 1

    docs.first.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    docs.first.project_id.must_equal project
    docs.first.database_id.must_equal "(default)"

    docs.first.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    docs.first.parent.project_id.must_equal project
    docs.first.parent.database_id.must_equal "(default)"
    docs.first.parent.collection_id.must_equal "messages"
    docs.first.parent.collection_path.must_equal "users/mike/messages"
    docs.first.parent.path.must_equal "projects/test/databases/(default)/documents/users/mike/messages"

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ body: "LGTM" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.first.ref.context.must_equal snapshot
    docs.first.parent.context.must_equal snapshot
  end

  it "gets a single doc (doc ref)" do
    firestore_mock.expect :batch_get_documents, [batch_docs_enum.to_a.first].to_enum, [database_path, [full_doc_paths.first], mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all collection.doc("abc123")

    docs_enum.must_be_kind_of Enumerator

    docs = docs_enum.to_a
    docs.count.must_equal 1

    docs.first.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    docs.first.project_id.must_equal project
    docs.first.database_id.must_equal "(default)"

    docs.first.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    docs.first.parent.project_id.must_equal project
    docs.first.parent.database_id.must_equal "(default)"
    docs.first.parent.collection_id.must_equal "messages"
    docs.first.parent.collection_path.must_equal "users/mike/messages"
    docs.first.parent.path.must_equal "projects/test/databases/(default)/documents/users/mike/messages"

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ body: "LGTM" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.first.ref.context.must_equal snapshot
    docs.first.parent.context.must_equal snapshot
  end

  it "gets multiple docs using splat (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: body_mask, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all "abc123", "doesnotexist", "xyz789", mask: :body

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: body_mask, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all ["abc123", "doesnotexist", "xyz789"], mask: "body"

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using splat (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: body_mask, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all collection.doc("abc123"), collection.doc("doesnotexist"), collection.doc("xyz789"), mask: :body

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: body_mask, transaction: transaction_id, options: default_options]

    docs_enum = collection.get_all [collection.doc("abc123"), collection.doc("doesnotexist"), collection.doc("xyz789")], mask: "body"

    assert_docs_enum docs_enum
  end

  def assert_docs_enum enum
    enum.must_be_kind_of Enumerator

    docs = enum.to_a
    docs.count.must_equal 3

    docs.each do |doc|
      doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
      doc.project_id.must_equal project
      doc.database_id.must_equal "(default)"

      doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      doc.parent.project_id.must_equal project
      doc.parent.database_id.must_equal "(default)"
      doc.parent.collection_id.must_equal "messages"
      doc.parent.collection_path.must_equal "users/mike/messages"
      doc.parent.path.must_equal "projects/test/databases/(default)/documents/users/mike/messages"

      doc.ref.context.must_equal snapshot
      doc.parent.context.must_equal snapshot
    end

    docs[0].must_be :exists?
    docs[0].data.must_be_kind_of Hash
    docs[0].data.must_equal({ body: "LGTM" })
    docs[0].created_at.must_equal read_time
    docs[0].updated_at.must_equal read_time
    docs[0].read_at.must_equal read_time

    docs[1].must_be :missing?
    docs[1].data.must_be :nil?
    docs[1].created_at.must_be :nil?
    docs[1].updated_at.must_be :nil?
    docs[1].read_at.must_equal read_time

    docs[2].must_be :exists?
    docs[2].data.must_be_kind_of Hash
    docs[2].data.must_equal({ body: "PTAL" })
    docs[2].created_at.must_equal read_time
    docs[2].updated_at.must_equal read_time
    docs[2].read_at.must_equal read_time
  end
end
