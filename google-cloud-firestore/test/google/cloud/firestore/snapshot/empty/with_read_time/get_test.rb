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

describe Google::Cloud::Firestore::Snapshot, :get, :empty, :with_read_time, :mock_firestore do
  let(:transaction_id) { "transaction123" }
  let(:snapshot) { Google::Cloud::Firestore::Snapshot.from_database firestore, read_time: read_time }
  let(:transaction_opt) do
    Google::Firestore::V1beta1::TransactionOptions.new(
      read_only: \
        Google::Firestore::V1beta1::TransactionOptions::ReadOnly.new(
          read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )
    )
  end
  let(:read_time) { Time.now }
  let :query_results_enum do
    [
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/mike",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Firestore::V1beta1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/chris",
          fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Chris") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "gets a document (doc ref)" do
    get_doc_resp = Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
      read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
      found: Google::Firestore::V1beta1::Document.new(
        name: "projects/#{project}/databases/(default)/documents/users/mike",
        fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
        create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time))
    )
    firestore_mock.expect :batch_get_documents, [get_doc_resp].to_enum, ["projects/#{project}/databases/(default)", ["projects/#{project}/databases/(default)/documents/users/mike"], mask: nil, new_transaction: transaction_opt, options: default_options]

    col = firestore.col :users
    col.must_be_kind_of Google::Cloud::Firestore::Collection::Reference

    doc_ref = col.doc :mike
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc = snapshot.get doc_ref

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.project_id
    doc.parent.database_id.must_equal col.database_id
    doc.parent.collection_id.must_equal col.collection_id
    doc.parent.collection_path.must_equal col.collection_path

    doc.ref.context.must_equal snapshot
    doc.parent.context.must_equal snapshot

    doc.must_be :exists?
    doc.data.must_be_kind_of Hash
    doc.data.must_equal({ name: "Mike" })
    doc.created_at.must_equal read_time
    doc.updated_at.must_equal read_time
    doc.read_at.must_equal read_time
  end

  it "gets a document (string)" do
    get_doc_resp = Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
      read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
      found: Google::Firestore::V1beta1::Document.new(
        name: "projects/#{project}/databases/(default)/documents/users/mike",
        fields: { "name" => Google::Firestore::V1beta1::Value.new(string_value: "Mike") },
        create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time))
    )
    firestore_mock.expect :batch_get_documents, [get_doc_resp].to_enum, ["projects/#{project}/databases/(default)", ["projects/#{project}/databases/(default)/documents/users/mike"], mask: nil, new_transaction: transaction_opt, options: default_options]

    doc_ref = firestore.doc "users/mike"
    doc_ref.must_be_kind_of Google::Cloud::Firestore::Document::Reference

    doc = snapshot.get "users/mike"

    doc.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
    doc.project_id.must_equal doc_ref.project_id
    doc.database_id.must_equal doc_ref.database_id
    doc.document_id.must_equal doc_ref.document_id
    doc.document_path.must_equal doc_ref.document_path

    doc.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
    doc.parent.project_id.must_equal doc_ref.parent.project_id
    doc.parent.database_id.must_equal doc_ref.parent.database_id
    doc.parent.collection_id.must_equal doc_ref.parent.collection_id
    doc.parent.collection_path.must_equal doc_ref.parent.collection_path

    doc.ref.context.must_equal snapshot
    doc.parent.context.must_equal snapshot

    doc.must_be :exists?
    doc.data.must_be_kind_of Hash
    doc.data.must_equal({ name: "Mike" })
    doc.created_at.must_equal read_time
    doc.updated_at.must_equal read_time
    doc.read_at.must_equal read_time
  end

  it "gets a collection (ref)" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    col = firestore.col :users
    results_enum = snapshot.get col

    assert_results_enum results_enum
  end

  it "gets a collection (string)" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    results_enum = snapshot.get "users"

    assert_results_enum results_enum
  end

  it "gets a collection (symbol)" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    results_enum = snapshot.get :users

    assert_results_enum results_enum
  end

  it "gets a simple query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    query = firestore.select(:name).from(:users)
    results_enum = snapshot.get query

    assert_results_enum results_enum
  end

  it "gets a complex query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, new_transaction: transaction_opt, options: default_options]

    query = firestore.select(:name).from(:users).offset(3).limit(42).order(:name).order(:__name__, :desc).start_after(:foo).end_before(:bar)
    results_enum = snapshot.get query

    assert_results_enum results_enum
  end

  def assert_results_enum enum
    enum.must_be_kind_of Enumerator

    results = enum.to_a
    results.count.must_equal 2

    results.each do |result|
      result.must_be_kind_of Google::Cloud::Firestore::Document::Snapshot
      result.project_id.must_equal project
      result.database_id.must_equal "(default)"

      result.parent.must_be_kind_of Google::Cloud::Firestore::Collection::Reference
      result.parent.project_id.must_equal project
      result.parent.database_id.must_equal "(default)"
      result.parent.collection_id.must_equal "users"
      result.parent.collection_path.must_equal "users"
      result.parent.path.must_equal "projects/projectID/databases/(default)/documents/users"

      result.ref.context.must_equal snapshot
      result.parent.context.must_equal snapshot
    end

    results.first.data.must_be_kind_of Hash
    results.first.data.must_equal({ name: "Mike" })
    results.first.created_at.must_equal read_time
    results.first.updated_at.must_equal read_time
    results.first.read_at.must_equal read_time

    results.last.data.must_be_kind_of Hash
    results.last.data.must_equal({ name: "Chris" })
    results.last.created_at.must_equal read_time
    results.last.updated_at.must_equal read_time
    results.last.read_at.must_equal read_time
  end
end
