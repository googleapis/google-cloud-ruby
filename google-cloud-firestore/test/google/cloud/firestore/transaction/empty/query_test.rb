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

describe Google::Cloud::Firestore::Transaction, :query, :empty, :mock_firestore do
  
  let(:transaction) { Google::Cloud::Firestore::Transaction.from_client firestore }
  let(:transaction_opt) do
    Google::Cloud::Firestore::V1::TransactionOptions.new(
      read_write: Google::Cloud::Firestore::V1::TransactionOptions::ReadWrite.new
    )
  end
  let(:read_time) { Time.now }
  let :query_results_enum do
    [
      Google::Cloud::Firestore::V1::RunQueryResponse.new(transaction: transaction_id),
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/alice",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/carol",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Bob") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum
  end

  it "runs a simple query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, new_transaction: transaction_opt)

    query = firestore.col(:users).select(:name)

    _(transaction.transaction_id).must_be :nil?

    results_enum = transaction.run query

    assert_results_enum results_enum

    _(transaction.transaction_id).must_equal transaction_id
  end

  it "runs a complex query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)],
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, new_transaction: transaction_opt)

    query = firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar)

    _(transaction.transaction_id).must_be :nil?

    results_enum = transaction.run query

    assert_results_enum results_enum

    _(transaction.transaction_id).must_equal transaction_id
  end

  def assert_results_enum enum
    _(enum).must_be_kind_of Enumerator

    results = enum.to_a
    _(results.count).must_equal 2

    results.each do |result|
      _(result).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      _(result.ref).must_be_kind_of Google::Cloud::Firestore::DocumentReference
      _(result.ref.client).must_equal firestore

      _(result.parent).must_be_kind_of Google::Cloud::Firestore::CollectionReference
      _(result.parent.collection_id).must_equal "users"
      _(result.parent.collection_path).must_equal "users"
      _(result.parent.path).must_equal "projects/projectID/databases/(default)/documents/users"
      _(result.parent.client).must_equal firestore
    end

    _(results.first.data).must_be_kind_of Hash
    _(results.first.data).must_equal({ name: "Alice" })
    _(results.first.created_at).must_equal read_time
    _(results.first.updated_at).must_equal read_time
    _(results.first.read_at).must_equal read_time

    _(results.last.data).must_be_kind_of Hash
    _(results.last.data).must_equal({ name: "Bob" })
    _(results.last.created_at).must_equal read_time
    _(results.last.updated_at).must_equal read_time
    _(results.last.read_at).must_equal read_time
  end
end
