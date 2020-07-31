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

describe Google::Cloud::Firestore::CollectionReference, :query, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/alice/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  let(:read_time) { Time.now }

  let :query_results_enum do
    [
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

  it "runs a query with a single select" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]
      ),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.select(:name).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple select values" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "status"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "activity")
        ]
      ),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.select(:name, "status", :activity).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple select calls only uses the last one" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "activity")
        ]
      ),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.select(:name).select("status").select(:activity).get

    assert_results_enum results_enum
  end

  it "runs a query with all_descendants" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: true)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.all_descendants.get

    assert_results_enum results_enum
  end

  it "runs a query with direct_descendants" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.direct_descendants.get

    assert_results_enum results_enum
  end

  it "runs a query with offset and limit" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.offset(3).limit(42).get

    assert_results_enum results_enum
  end

  it "runs a query with a single order" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING)],
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:name).get

    assert_results_enum results_enum
  end

  it "runs a query with a multiple order calls" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)],
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:name).order(firestore.document_id, :desc).get

    assert_results_enum results_enum
  end

  it "runs a query with start_after and end_before" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")],
      order_by: [Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:a).start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple start_after and end_before" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: true),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")],
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"), direction: :ASCENDING)
      ]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:a).order(:b).start_after(:foo, :bar).end_before(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "runs a query with start_at and end_at" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: true),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")],
      order_by: [Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:a).start_at(:foo).end_at(:bar).get

    assert_results_enum results_enum
  end

  it "runs a query with multiple start_at and end_at" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: false),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")],
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"), direction: :ASCENDING)
      ]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.order(:a).order(:b).start_at(:foo, :bar).end_at(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "runs a simple query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.select(:name).get

    assert_results_enum results_enum
  end

  it "runs a complex query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages")],
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
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: collection.parent_path)

    results_enum = collection.select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  describe "nested collection" do
    let :query_results_enum do
      [
        Google::Cloud::Firestore::V1::RunQueryResponse.new(
          read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          document: Google::Cloud::Firestore::V1::Document.new(
            name: "projects/#{project}/databases/(default)/documents/users/alice/messages/abc123",
            fields: { "body" => Google::Cloud::Firestore::V1::Value.new(string_value: "LGTM") },
            create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
          )),
        Google::Cloud::Firestore::V1::RunQueryResponse.new(
          read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          document: Google::Cloud::Firestore::V1::Document.new(
            name: "projects/#{project}/databases/(default)/documents/users/alice/messages/xyz789",
            fields: { "body" => Google::Cloud::Firestore::V1::Value.new(string_value: "PTAL") },
            create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
            update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
          ))
      ].to_enum
    end

    it "runs a simple query" do
      expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
        select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
          fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "body")]),
        from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: false)],
      )
      firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: "projects/#{project}/databases/(default)/documents/users/alice")

      results_enum = collection.select(:body).get

      assert_results_enum results_enum
    end

    it "runs a complex query" do
      expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
        select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
          fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "body")]),
        from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "messages", all_descendants: false)],
        offset: 3,
        limit: Google::Protobuf::Int32Value.new(value: 42),
        order_by: [
          Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
            field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "body"),
            direction: :ASCENDING),
          Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
            field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
            direction: :DESCENDING)],
        start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
        end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
      )
      firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, parent: "projects/#{project}/databases/(default)/documents/users/alice")

      results_enum = collection.select(:body).offset(3).limit(42).order(:body).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar).get

      assert_results_enum results_enum
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
        _(result.parent.collection_id).must_equal "messages"
        _(result.parent.collection_path).must_equal "users/alice/messages"
        _(result.parent.path).must_equal "projects/projectID/databases/(default)/documents/users/alice/messages"
        _(result.parent.client).must_equal firestore
      end

      _(results.first.data).must_be_kind_of Hash
      _(results.first.data).must_equal({ body: "LGTM" })
      _(results.first.created_at).must_equal read_time
      _(results.first.updated_at).must_equal read_time
      _(results.first.read_at).must_equal read_time

      _(results.last.data).must_be_kind_of Hash
      _(results.last.data).must_equal({ body: "PTAL" })
      _(results.last.created_at).must_equal read_time
      _(results.last.updated_at).must_equal read_time
      _(results.last.read_at).must_equal read_time
    end
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
