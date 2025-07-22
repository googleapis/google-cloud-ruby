# Copyright 2018 Google LLC
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

describe Google::Cloud::Firestore::Query, :get, :mock_firestore do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }
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

  it "gets a query with a single select" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.select(:name).get

    assert_results_enum results_enum
  end

  it "re-queries Firestore every time the get results are enumerated" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.select(:name).get
    assert_results_enum results_enum

    # second iteration through enum results in a second call to firestore_mock
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)
    assert_results_enum results_enum 
  end

  it "gets a query with a single select and read time set" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, read_time: read_time)

    results_enum = query.select(:name).get read_time: read_time

    assert_results_enum results_enum
  end

  it "gets a query with multiple select values" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "status"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "activity")
        ])
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.select(:name, "status", :activity).get

    assert_results_enum results_enum
  end

  it "gets a query with multiple select calls" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "status"),
          Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "activity")
        ])
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.select(:name, "status", :activity).get

    assert_results_enum results_enum
  end

  it "gets a collection as a query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = firestore.col(:users).get

    assert_results_enum results_enum
  end

  it "gets a query with from with all_descendants" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: true)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = firestore.col(:users).all_descendants.get

    assert_results_enum results_enum
  end

  it "gets a query with from with direct_descendants" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = firestore.col(:users).direct_descendants.get

    assert_results_enum results_enum
  end

  it "gets a query with offset and limit" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      offset: 3,
      limit: Google::Protobuf::Int32Value.new(value: 42)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.offset(3).limit(42).get

    assert_results_enum results_enum
  end

  it "gets a query with a single order" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:name).get

    assert_results_enum results_enum
  end

  it "gets a query with a multiple order calls" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:name).order(firestore.document_id, :desc).get

    assert_results_enum results_enum
  end

  it "gets a query with start_after and end_before" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING)],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:a).start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  it "gets a query with multiple start_after and end_before" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"), direction: :ASCENDING)
      ],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: true)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:a).order(:b).start_after(:foo, :bar).end_before(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "gets a query with start_at and end_at" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING)],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo")], before: true),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: false)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:a).start_at(:foo).end_at(:bar).get

    assert_results_enum results_enum
  end

  it "gets a query with multiple start_at and end_at" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"), direction: :ASCENDING),
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"), direction: :ASCENDING)
      ],
      start_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("foo"), Google::Cloud::Firestore::Convert.raw_to_value("bar")], before: true),
      end_at: Google::Cloud::Firestore::V1::Cursor.new(values: [Google::Cloud::Firestore::Convert.raw_to_value("baz"), Google::Cloud::Firestore::Convert.raw_to_value("bif")], before: false)
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.order(:a).order(:b).start_at(:foo, :bar).end_at(:baz, :bif).get

    assert_results_enum results_enum
  end

  it "gets a simple query" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      from: [Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(collection_id: "users", all_descendants: false)]
    )
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = firestore.col(:users).select(:name).get

    assert_results_enum results_enum
  end

  it "gets a complex query" do
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
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar).get

    assert_results_enum results_enum
  end

  it "gets a complex query after serialization and deserialization" do
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
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    original_query = firestore.col(:users).select(:name).offset(3).limit(42).order(:name).order(firestore.document_id, :desc).start_after(:foo).end_before(:bar)

    json = original_query.to_json
    _(json).must_be_instance_of String

    deserialized_query = Google::Cloud::Firestore::Query.from_json json, firestore
    _(deserialized_query).must_be_instance_of Google::Cloud::Firestore::Query

    _(deserialized_query.query).must_equal expected_query # Private field
    _(deserialized_query.parent_path).must_equal original_query.parent_path # Private field
    _(deserialized_query.limit_type).must_equal original_query.limit_type # Private field
    _(deserialized_query.client).must_equal original_query.client # Private field

    results_enum = deserialized_query.get

    assert_results_enum results_enum
  end
 
  it "gets a query with limit_last" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :DESCENDING)],
      limit: Google::Protobuf::Int32Value.new(value: 2)
    )
    
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)
    # Later calls to `first` and `to_a` will result in separate firestore mock reads
    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query)

    results_enum = query.select(:name).order_by(:name).limit_to_last(2).get
    _(results_enum).must_be_kind_of Enumerator

    # The results are reverted with limit_last, so "Bob" becomes the first result
    first = results_enum.first
    _(first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
    _(first.data).must_equal({ name: "Bob" })
        
    results = results_enum.to_a
    _(results.last).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot
    _(results.last.data).must_equal({ name: "Alice" })
  end

  it "does not eagerly read without `limit_last`" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    firestore_mock.expect(:run_query, ExplodingEnum.new(query_results_enum), run_query_args(expected_query))
    # Later calls to `first` and `to_a` will result in separate firestore mock reads
    firestore_mock.expect(:run_query, ExplodingEnum.new(query_results_enum), run_query_args(expected_query))

    results_enum = query.select(:name).get
    _(results_enum).must_be_kind_of Enumerator

    first = results_enum.first
    _(first).must_be_kind_of Google::Cloud::Firestore::DocumentSnapshot

    assert_raises(RuntimeError) { results_enum.to_a }
  end

  it "does eagerly read the whole enum with `limit_last` when first entry is read" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")]),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :DESCENDING)],
      limit: Google::Protobuf::Int32Value.new(value: 2)
    )
    
    firestore_mock.expect :run_query, ExplodingEnum.new(query_results_enum), run_query_args(expected_query)

    results_enum = query.select(:name).order_by(:name).limit_to_last(2).get
    _(results_enum).must_be_kind_of Enumerator
    
    assert_raises(RuntimeError) { results_enum.first }
  end

  it "gets a query with explanation" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    expected_explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)

    query_result_metrics = Google::Cloud::Firestore::V1::ExplainMetrics.new(
      plan_summary: Google::Cloud::Firestore::V1::PlanSummary.new(
        indexes_used: [

        ]
      ),
      execution_stats: Google::Cloud::Firestore::V1::ExecutionStats.new(
        results_returned: 2
      )
    )

    query_results_with_explanation = [
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/alice",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Alice") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        )),
      Google::Cloud::Firestore::V1::RunQueryResponse.new(
        explain_metrics: query_result_metrics,
        read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/users/bob",
          fields: { "name" => Google::Cloud::Firestore::V1::Value.new(string_value: "Bob") },
          create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time),
          update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(read_time)
        ))
    ].to_enum

    firestore_mock.expect :run_query, query_results_with_explanation, run_query_args(expected_query, explain_options: expected_explain_options)

    explain_result = query.select(:name).explain(analyze: true)

    _(explain_result).must_be_kind_of Google::Cloud::Firestore::QueryExplainResult

    _(explain_result.metrics_fetched?).must_equal false
    _(explain_result.explain_metrics).must_equal query_result_metrics
    _(explain_result.metrics_fetched?).must_equal true 

    assert_results_enum explain_result.to_enum
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
