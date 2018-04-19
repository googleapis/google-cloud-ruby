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

describe Google::Cloud::Firestore::Query, :mock_firestore do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }
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

  it "runs a query with a single select" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.select(:name).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple select values" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "status"),
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "activity")
        ])
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.select(:name, "status", :activity).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple select calls" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "status"),
          Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "activity")
        ])
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.select(:name).select("status").select(:activity).get

    assert_results_enum results_enum
  end

  it "runs a collection as a query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = firestore.col(:users).get

    assert_results_enum results_enum
  end

  it "runs a query with from with all_descendants" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: true)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = firestore.col(:users).all_descendants.get

    assert_results_enum results_enum
  end

  it "runs a query with from with direct_descendants" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = firestore.col(:users).direct_descendants.get

    assert_results_enum results_enum
  end

  it "runs a query with offset and limit" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.offset(3).limit(42).get

    assert_results_enum results_enum
  end

  it "runs a query with a single order" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.order(:name).get

    assert_results_enum results_enum
  end

  it "runs a query with a multiple order calls" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      order_by: [
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Firestore::V1beta1::StructuredQuery::Order.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.order(:name).order(firestore.document_id, :desc).get

    assert_results_enum results_enum
  end

  it "runs a query with start_after and end_before" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple start_after and end_before" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.start_after(:foo, :bar).end_before(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "runs a query with start_at and end_at" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: true),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.start_at(:foo).end_at(:bar).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple start_at and end_at" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      start_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true),
      end_at: Google::Firestore::V1beta1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: false)
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = query.start_at(:foo, :bar).end_at(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "runs a simple query" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      select: Google::Firestore::V1beta1::StructuredQuery::Projection.new(
        fields: [Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Firestore::V1beta1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = firestore.col(:users).select(:name).get

    assert_results_enum results_enum
  end

  it "runs a complex query" do
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
    firestore_mock.expect :run_query, query_results_enum, ["projects/#{project}/databases/(default)/documents", structured_query: expected_query, options: default_options]

    results_enum = firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  def assert_results_enum enum
    enum.must_be_kind_of Enumerator

    results = enum.to_a
    results.count.must_equal 2

    results.each do |result|
      result.must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

      result.ref.must_be_kind_of Google::Cloud::Firestore::DocumentReference
      result.ref.client.must_equal firestore

      result.parent.must_be_kind_of Google::Cloud::Firestore::CollectionReference
      result.parent.collection_id.must_equal "users"
      result.parent.collection_path.must_equal "users"
      result.parent.client.must_equal firestore
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
