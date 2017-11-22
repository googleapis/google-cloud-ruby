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

describe Google::Cloud::Firestore::ReadOnlyTransaction, :get_all, :empty, :without_read_time, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:read_transaction) { Google::Cloud::Firestore::ReadOnlyTransaction.from_database firestore }
  let(:transaction_opt) do
    Google::Firestore::V1beta1::TransactionOptions.new(
      read_only: Google::Firestore::V1beta1::TransactionOptions::ReadOnly.new
    )
  end
  let(:read_time) { Time.now }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:full_doc_paths) {
    ["#{documents_path}/users/mike", "#{documents_path}/users/tad", "#{documents_path}/users/chris"]
  }
  let :batch_docs_enum do
    [
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        transaction: transaction_id,
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        missing: "projects/#{project}/databases/(default)/documents/users/tad"),
      Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        found: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/chris",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Chris") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end
  let(:name_mask) { Google::Firestore::V1beta1::DocumentMask.new field_paths: ["name"] }

  it "gets multiple docs using splat (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all "users/mike", "users/tad", "users/chris"

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all ["users/mike", "users/tad", "users/chris"]

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using splat (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all read_transaction.doc("users/mike"), read_transaction.doc("users/tad"), read_transaction.doc("users/chris")

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all [read_transaction.doc("users/mike"), read_transaction.doc("users/tad"), read_transaction.doc("users/chris")]

    assert_docs_enum docs_enum
  end

  it "gets a single doc (string)" do
    firestore_mock.expect :batch_get_documents, [batch_docs_enum.to_a.first].to_enum, [database_path, [full_doc_paths.first], mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all "users/mike"

    docs_enum.must_be_kind_of Enumerator

    docs = docs_enum.to_a
    docs.count.must_equal 1

    docs.first.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    docs.first.project_id.must_equal project
    docs.first.database_id.must_equal "(default)"

    docs.first.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    docs.first.parent.project_id.must_equal project
    docs.first.parent.database_id.must_equal "(default)"
    docs.first.parent.collection_id.must_equal "users"
    docs.first.parent.collection_path.must_equal "users"
    docs.first.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ name: "Mike" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.first.ref.context.must_equal read_transaction
    docs.first.parent.context.must_equal read_transaction
  end

  it "gets a single doc (doc ref)" do
    firestore_mock.expect :batch_get_documents, [batch_docs_enum.to_a.first].to_enum, [database_path, [full_doc_paths.first], mask: nil, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all read_transaction.doc("users/mike")

    docs_enum.must_be_kind_of Enumerator

    docs = docs_enum.to_a
    docs.count.must_equal 1

    docs.first.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    docs.first.project_id.must_equal project
    docs.first.database_id.must_equal "(default)"

    docs.first.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    docs.first.parent.project_id.must_equal project
    docs.first.parent.database_id.must_equal "(default)"
    docs.first.parent.collection_id.must_equal "users"
    docs.first.parent.collection_path.must_equal "users"
    docs.first.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

    docs.first.data.must_be_kind_of Hash
    docs.first.data.must_equal({ name: "Mike" })
    docs.first.created_at.must_equal read_time
    docs.first.updated_at.must_equal read_time
    docs.first.read_at.must_equal read_time

    docs.first.ref.context.must_equal read_transaction
    docs.first.parent.context.must_equal read_transaction
  end

  it "gets multiple docs using splat (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: name_mask, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all "users/mike", "users/tad", "users/chris", mask: :name

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (string)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: name_mask, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all ["users/mike", "users/tad", "users/chris"], mask: "name"

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using splat (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: name_mask, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all read_transaction.doc("users/mike"), read_transaction.doc("users/tad"), read_transaction.doc("users/chris"), mask: :name

    assert_docs_enum docs_enum
  end

  it "gets multiple docs using array (doc ref)" do
    firestore_mock.expect :batch_get_documents, batch_docs_enum, [database_path, full_doc_paths, mask: name_mask, new_transaction: transaction_opt, options: default_options]

    docs_enum = read_transaction.get_all [read_transaction.doc("users/mike"), read_transaction.doc("users/tad"), read_transaction.doc("users/chris")], mask: "name"

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
      doc.parent.collection_id.must_equal "users"
      doc.parent.collection_path.must_equal "users"
      doc.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

      doc.ref.context.must_equal read_transaction
      doc.parent.context.must_equal read_transaction
    end

    docs[0].must_be :exists?
    docs[0].data.must_be_kind_of Hash
    docs[0].data.must_equal({ name: "Mike" })
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
    docs[2].data.must_equal({ name: "Chris" })
    docs[2].created_at.must_equal read_time
    docs[2].updated_at.must_equal read_time
    docs[2].read_at.must_equal read_time
  end
end
