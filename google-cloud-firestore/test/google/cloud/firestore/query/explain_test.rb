# Copyright 2025 Google LLC
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

describe Google::Cloud::Firestore::Query, :explain_options, :mock_firestore do
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
        ),
        explain_metrics: Google::Cloud::Firestore::V1::ExplainMetrics.new()
      )
    ].to_enum
  end

  it "runs query with explain options (analyze: false)" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results = query.select(:name).explain
    # Results and metrics are not fetched at first
    refute results.metrics_fetched?
    
    results_enum = results.to_enum
    assert_results_enum results_enum
    
    # Enumerating the results fetches the metrics
    assert results.metrics_fetched?
  end

  it "runs query with explain options (analyze: false)" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results = query.select(:name).explain

    # Results and metrics are not fetched at first
    refute results.metrics_fetched?

    # accessing metrics fetches metrics and results
    metrics = results.explain_metrics
    refute_nil metrics
    assert results.metrics_fetched?

    assert_results_enum results.to_enum
  end

  it "runs query with explain options (analyze: true)" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results_enum = query.select(:name).explain(analyze: true).to_enum
    assert_results_enum results_enum
  end

  it "returns same results without re-querying" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results = query.select(:name).explain(analyze: true)
    
    assert_results_enum results.to_a.to_enum
    assert_results_enum results.to_a.to_enum # second call to to_a does not result in a second call to mock
  end

  it "runs query with explain and order_by" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "age"),
          direction: :ASCENDING
        )
      ]
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results_enum = query.order(:age).explain.to_enum
    assert_results_enum results_enum
  end

  # Test explain with limit
  it "runs query with explain and limit" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      limit: Google::Protobuf::Int32Value.new(value: 5)
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results_enum = query.limit(5).explain.to_enum
    assert_results_enum results_enum
  end

  # Test explain with limit_to_last
  it "runs query with explain and limit_to_last" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      limit: Google::Protobuf::Int32Value.new(value: 5),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING
        )
      ]
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    # Need to start with an order for limit_to_last to work
    results_enum = query.order("__name__").limit_to_last(5).explain.to_enum
    
    # The query enumerator will reverse the results for limit_to_last so we have to undo that for verification
    reversed_results_enum = results_enum.to_a.reverse.to_enum
    assert_results_enum reversed_results_enum
  end

  it "runs query with explain and start_at field value" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      start_at: Google::Cloud::Firestore::V1::Cursor.new(
        values: [Google::Cloud::Firestore::Convert.raw_to_value("Alice")], 
        before: true
      ),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING
        )
      ]
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results_enum = query.order("name").start_at("Alice").explain.to_enum
    assert_results_enum results_enum
  end

  # Test explain with end_at cursor using field values instead of document snapshot
  it "runs query with explain and end_at field value" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      end_at: Google::Cloud::Firestore::V1::Cursor.new(
        values: [Google::Cloud::Firestore::Convert.raw_to_value("Bob")], 
        before: false
      ),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name"),
          direction: :ASCENDING
        )
      ]
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: false)

    firestore_mock.expect :run_query, query_results_enum, run_query_args(expected_query, explain_options: explain_options)

    results_enum = query.order("name").end_at("Bob").explain.to_enum
    assert_results_enum results_enum
  end


  it "raises an error when explain is called with invalid analyze parameter" do
    # Test with a non-boolean parameter
    error = assert_raises ArgumentError do
      query.select(:name).explain(analyze: "true")
    end
    _(error.message).must_match(/analyze must be a boolean/)
    
    # Test with nil parameter
    error = assert_raises ArgumentError do
      query.select(:name).explain(analyze: nil)
    end
    _(error.message).must_match(/analyze must be a boolean/)
    
    # Test with something other than analyze parameter
    error = assert_raises ArgumentError do
      query.select(:name).explain(invalid_param: true)
    end
    _(error.message).must_match(/unknown keyword/)
  end

  it "does eagerly read all documents when analyze: true and taking one" do
    exploding_enum = ExplodingEnum.new query_results_enum

    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)

    firestore_mock.expect :run_query, exploding_enum, run_query_args(expected_query, explain_options: explain_options)

    assert_raises RuntimeError do 
      results_enum = query.select(:name).explain(analyze: true).to_enum
      first_doc = results_enum.first
    end
  end

  it "does eagerly read all documents when analyze: true and taking one with limit_to_last" do
    exploding_enum = ExplodingEnum.new query_results_enum

    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      limit: Google::Protobuf::Int32Value.new(value: 5),
      order_by: [
        Google::Cloud::Firestore::V1::StructuredQuery::Order.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "__name__"),
          direction: :DESCENDING
        )
      ]
    )
    explain_options = Google::Cloud::Firestore::V1::ExplainOptions.new(analyze: true)

    firestore_mock.expect :run_query, exploding_enum, run_query_args(expected_query, explain_options: explain_options)

    # Need to start with an order for limit_to_last to work
    assert_raises RuntimeError do 
      results_enum = query.order("__name__").limit_to_last(5).explain(analyze: true).to_enum
      first_doc = results_enum.first
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
