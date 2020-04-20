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

describe Google::Cloud::Firestore::Transaction, :get_all, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:transaction) do
    Google::Cloud::Firestore::Transaction.from_client(firestore).tap do |b|
      b.instance_variable_set :@transaction_id, transaction_id
    end
  end
  let(:read_time) { Time.now }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:full_doc_paths) {
    ["#{documents_path}/users/mike", "#{documents_path}/users/tad", "#{documents_path}/users/chris"]
  }
  let :transaction_docs_enum do
    [
      Google::Firestore::V1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        missing: "projects/#{project}/databases/(default)/documents/users/tad"),
      Google::Firestore::V1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/chris",
          fields: { "name" => Google::Firestore::V1::Value.new(string_value: "Chris") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "gets multiple docs using splat (string)" do
    firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all "users/mike", "users/tad", "users/chris"

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (string)" do
    firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all ["users/mike", "users/tad", "users/chris"]

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using splat (doc ref)" do
    firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all firestore.doc("users/mike"), firestore.doc("users/tad"), firestore.doc("users/chris")

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (doc ref)" do
    firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all [firestore.doc("users/mike"), firestore.doc("users/tad"), firestore.doc("users/chris")]

    assert_docs_enum docs_enum
  end

  it "gets a single doc (string)" do
    firestore_mock.expect :batch_get_documents, [transaction_docs_enum.to_a.first].to_enum, [database_path, documents: [full_doc_paths.first], mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all "users/mike"

    _(docs_enum).must_be_kind_of Enumerator

    docs = docs_enum.to_a
    _(docs.count).must_equal 1

    _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    _(docs.first.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(docs.first.parent.collection_id).must_equal "users"
    _(docs.first.parent.collection_path).must_equal "users"
    _(docs.first.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"

    _(docs.first.data).must_be_kind_of Hash
    _(docs.first.data).must_equal({ name: "Mike" })
    _(docs.first.created_at).must_equal read_time
    _(docs.first.updated_at).must_equal read_time
    _(docs.first.read_at).must_equal read_time
  end

  it "gets a single doc (doc ref)" do
    firestore_mock.expect :batch_get_documents, [transaction_docs_enum.to_a.first].to_enum, [database_path, documents: [full_doc_paths.first], mask: nil, transaction: transaction_id, options: default_options]

    docs_enum = transaction.get_all firestore.doc("users/mike")

    _(docs_enum).must_be_kind_of Enumerator

    docs = docs_enum.to_a
    _(docs.count).must_equal 1

    _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    _(docs.first.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
    _(docs.first.parent.collection_id).must_equal "users"
    _(docs.first.parent.collection_path).must_equal "users"
    _(docs.first.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"

    _(docs.first.data).must_be_kind_of Hash
    _(docs.first.data).must_equal({ name: "Mike" })
    _(docs.first.created_at).must_equal read_time
    _(docs.first.updated_at).must_equal read_time
    _(docs.first.read_at).must_equal read_time
  end

  describe :field_mask do
    let(:field_mask) { Google::Firestore::V1::DocumentMask.new(field_paths: ["name"]) }

    it "gets multiple docs using splat (string)" do
      firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all "users/mike", "users/tad", "users/chris", field_mask: [:name]

      assert_docs_enum docs_enum
    end

    it "gets multiple docs using array (string)" do
      firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all ["users/mike", "users/tad", "users/chris"], field_mask: :name

      assert_docs_enum docs_enum
    end

    it "gets multiple docs using splat (doc ref)" do
      firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all firestore.doc("users/mike"), firestore.doc("users/tad"), firestore.doc("users/chris"), field_mask: ["name"]

      assert_docs_enum docs_enum
    end

    it "gets multiple docs using array (doc ref)" do
      firestore_mock.expect :batch_get_documents, transaction_docs_enum, [database_path, documents: full_doc_paths, mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all [firestore.doc("users/mike"), firestore.doc("users/tad"), firestore.doc("users/chris")], field_mask: "name"

      assert_docs_enum docs_enum
    end

    it "gets a single doc (string)" do
      firestore_mock.expect :batch_get_documents, [transaction_docs_enum.to_a.first].to_enum, [database_path, documents: [full_doc_paths.first], mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all "users/mike", field_mask: firestore.field_path(:name)

      _(docs_enum).must_be_kind_of Enumerator

      docs = docs_enum.to_a
      _(docs.count).must_equal 1

      _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      _(docs.first.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(docs.first.parent.collection_id).must_equal "users"
      _(docs.first.parent.collection_path).must_equal "users"
      _(docs.first.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"

      _(docs.first.data).must_be_kind_of Hash
      _(docs.first.data).must_equal({ name: "Mike" })
      _(docs.first.created_at).must_equal read_time
      _(docs.first.updated_at).must_equal read_time
      _(docs.first.read_at).must_equal read_time
    end

    it "gets a single doc (doc ref)" do
      firestore_mock.expect :batch_get_documents, [transaction_docs_enum.to_a.first].to_enum, [database_path, documents: [full_doc_paths.first], mask: field_mask, transaction: transaction_id, options: default_options]

      docs_enum = transaction.get_all firestore.doc("users/mike"), field_mask: [firestore.field_path(:name)]

      _(docs_enum).must_be_kind_of Enumerator

      docs = docs_enum.to_a
      _(docs.count).must_equal 1

      _(docs.first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      _(docs.first.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(docs.first.parent.collection_id).must_equal "users"
      _(docs.first.parent.collection_path).must_equal "users"
      _(docs.first.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"

      _(docs.first.data).must_be_kind_of Hash
      _(docs.first.data).must_equal({ name: "Mike" })
      _(docs.first.created_at).must_equal read_time
      _(docs.first.updated_at).must_equal read_time
      _(docs.first.read_at).must_equal read_time
    end
  end

  def assert_docs_enum enum
    _(enum).must_be_kind_of Enumerator

    docs = enum.to_a
    _(docs.count).must_equal 3

    docs.each do |doc|
      _(doc).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      _(doc.ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(doc.ref.client).must_equal firestore

      _(doc.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(doc.parent.collection_id).must_equal "users"
      _(doc.parent.collection_path).must_equal "users"
      _(doc.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"
      _(doc.parent.client).must_equal firestore
    end

    _(docs[0]).must_be :exists?
    _(docs[0].data).must_be_kind_of Hash
    _(docs[0].data).must_equal({ name: "Mike" })
    _(docs[0].created_at).must_equal read_time
    _(docs[0].updated_at).must_equal read_time
    _(docs[0].read_at).must_equal read_time

    _(docs[1]).must_be :missing?
    _(docs[1].data).must_be :nil?
    _(docs[1].created_at).must_be :nil?
    _(docs[1].updated_at).must_be :nil?
    _(docs[1].read_at).must_equal read_time

    _(docs[2]).must_be :exists?
    _(docs[2].data).must_be_kind_of Hash
    _(docs[2].data).must_equal({ name: "Chris" })
    _(docs[2].created_at).must_equal read_time
    _(docs[2].updated_at).must_equal read_time
    _(docs[2].read_at).must_equal read_time
  end
end
