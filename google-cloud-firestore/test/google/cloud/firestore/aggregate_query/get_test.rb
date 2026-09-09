# Copyright 2022 Google LLC
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

describe Google::Cloud::Firestore::AggregateQuery, :add_count, :mock_firestore do
  let (:parent) { "projects/projectID/databases/(default)/documents" }
  let(:query) { Google::Cloud::Firestore::Query.start(nil, "#{firestore.path}/documents", firestore).select(:score) }

  describe "Common" do
    it "creates empty AggregateQuery object" do
      aggregate_query = query.aggregate_query

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 0
    end
  end

  describe "COUNT" do
    it "creates COUNT aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_count

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'count' # default alias
      _(grpc.aggregations.first.count).wont_be :nil?
      _(grpc.aggregations.first.count).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count
    end

    it "creates COUNT aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_count aggregate_alias: 'total'

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'total' # custom alias
      _(grpc.aggregations.first.count).wont_be :nil?
      _(grpc.aggregations.first.count).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count
    end

    it "creates multiple COUNT aggregates" do
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: 'total_1')
                             .add_count(aggregate_alias: 'total_2')
                             .add_count(aggregate_alias: 'total_3')

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3

      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'total_1'
      _(grpc.aggregations[0].count).wont_be :nil?
      _(grpc.aggregations[0].count).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count

      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'total_2'
      _(grpc.aggregations[1].count).wont_be :nil?
      _(grpc.aggregations[1].count).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count

      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'total_3'
      _(grpc.aggregations[2].count).wont_be :nil?
      _(grpc.aggregations[2].count).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count
    end

    it "does not mutate existing AggregateQuery object on adding more aggregates" do
      aggregate_query_1 = query.aggregate_query
                               .add_count(aggregate_alias: 'total_1')
      aggregate_query_2 = aggregate_query_1
                               .add_count(aggregate_alias: 'total_2')
      refute aggregate_query_1.to_grpc == aggregate_query_2.to_grpc
      _(aggregate_query_1.to_grpc).must_equal(query.aggregate_query
                                              .add_count(aggregate_alias: 'total_1')
                                              .to_grpc)
      _(aggregate_query_2.to_grpc).must_equal(query.aggregate_query
                                             .add_count(aggregate_alias: 'total_1')
                                             .add_count(aggregate_alias: 'total_2')
                                             .to_grpc)
    end

    it "gets an aggregate query with custom alias" do
      expected_params = Google::Cloud::Firestore::V1::RunAggregationQueryRequest.new(
        parent: parent,
        structured_aggregation_query: Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
          structured_query: Google::Cloud::Firestore::V1::StructuredQuery.new(
            select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
              fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "score")])
          ),
          aggregations: [
            Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
              count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
              alias: "total_score" # custom alias
            )
          ]
        )
      )
      mocked_response = [
        Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
          result: Google::Cloud::Firestore::V1::AggregationResult.new(
            aggregate_fields: {
              "total_score": Google::Cloud::Firestore::V1::Value.new(integer_value: 3)
            }
          )
        )
      ].to_enum
      firestore_mock.expect :run_aggregation_query, mocked_response, [expected_params]

      aggregate_query = query.aggregate_query.add_count aggregate_alias: "total_score" # custom alias
      results_enum = aggregate_query.get

      _(results_enum).must_be_kind_of Enumerator
      results = results_enum.to_a
      _(results.count).must_equal 1
      results.each do |result|
        _(result).must_be_kind_of Google::Cloud::Firestore::AggregateQuerySnapshot
        _(result.get).must_equal 3
        _(result.get('total_score')).must_equal 3
      end
    end
  end

  describe "SUM" do
    it "creates SUM aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_sum('score')

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'sum' # default alias
      _(grpc.aggregations.first.sum).wont_be :nil?
      _(grpc.aggregations.first.sum).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum
    end

    it "creates SUM aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_sum 'score', aggregate_alias: 'total'

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'total' # custom alias
      _(grpc.aggregations.first.sum).wont_be :nil?
      _(grpc.aggregations.first.sum).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum
    end

    it "creates multiple SUM aggregates" do
      aggregate_query = query.aggregate_query
                             .add_sum('score', aggregate_alias: 'total_1')
                             .add_sum('score', aggregate_alias: 'total_2')
                             .add_sum('score', aggregate_alias: 'total_3')

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3

      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'total_1'
      _(grpc.aggregations[0].sum).wont_be :nil?
      _(grpc.aggregations[0].sum).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum

      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'total_2'
      _(grpc.aggregations[1].sum).wont_be :nil?
      _(grpc.aggregations[1].sum).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum

      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'total_3'
      _(grpc.aggregations[2].sum).wont_be :nil?
      _(grpc.aggregations[2].sum).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum
    end

    it "does not mutate existing AggregateQuery object on adding more aggregates" do
      aggregate_query_1 = query.aggregate_query
                               .add_sum('score', aggregate_alias: 'total_1')
      aggregate_query_2 = aggregate_query_1
                               .add_sum('score', aggregate_alias: 'total_2')
      refute aggregate_query_1.to_grpc == aggregate_query_2.to_grpc
      _(aggregate_query_1.to_grpc).must_equal(query.aggregate_query
                                              .add_sum('score', aggregate_alias: 'total_1')
                                              .to_grpc)
      _(aggregate_query_2.to_grpc).must_equal(query.aggregate_query
                                             .add_sum('score', aggregate_alias: 'total_1')
                                             .add_sum('score', aggregate_alias: 'total_2')
                                             .to_grpc)
    end

    it "gets an aggregate query with custom alias" do
      expected_params = Google::Cloud::Firestore::V1::RunAggregationQueryRequest.new(
        parent: parent,
        structured_aggregation_query: Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
          structured_query: Google::Cloud::Firestore::V1::StructuredQuery.new(
            select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
              fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "score")])
          ),
          aggregations: [
            Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
              sum: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum.new(
                field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "score")
              ),
              alias: "total_score" # custom alias
            )
          ]
        )
      )
      mocked_response = [
        Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
          result: Google::Cloud::Firestore::V1::AggregationResult.new(
            aggregate_fields: {
              "total_score": Google::Cloud::Firestore::V1::Value.new(integer_value: 3)
            }
          )
        )
      ].to_enum
      firestore_mock.expect :run_aggregation_query, mocked_response, [expected_params]

      aggregate_query = query.aggregate_query.add_sum 'score', aggregate_alias: "total_score" # custom alias
      results_enum = aggregate_query.get

      _(results_enum).must_be_kind_of Enumerator
      results = results_enum.to_a
      _(results.count).must_equal 1
      results.each do |result|
        _(result).must_be_kind_of Google::Cloud::Firestore::AggregateQuerySnapshot
        _(result.get).must_equal 3
        _(result.get('total_score')).must_equal 3
      end
    end
  end

  describe "AVG" do
    it "creates AVG aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_avg('score')

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'avg' # default alias
      _(grpc.aggregations.first.avg).wont_be :nil?
      _(grpc.aggregations.first.avg).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg
    end

    it "creates AVG aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_avg 'score', aggregate_alias: 'avg_score'

      _(aggregate_query).must_be_kind_of Google::Cloud::Firestore::AggregateQuery

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'avg_score' # custom alias
      _(grpc.aggregations.first.avg).wont_be :nil?
      _(grpc.aggregations.first.avg).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg
    end

    it "creates multiple AVG aggregates" do
      aggregate_query = query.aggregate_query
                             .add_avg('score', aggregate_alias: 'score_1')
                             .add_avg('score', aggregate_alias: 'score_2')
                             .add_avg('score', aggregate_alias: 'score_3')

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery

      _(grpc.structured_query).wont_be :nil?
      _(grpc.structured_query).must_be_kind_of Google::Cloud::Firestore::V1::StructuredQuery
      _(grpc.structured_query).must_equal query.query

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3

      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'score_1'
      _(grpc.aggregations[0].avg).wont_be :nil?
      _(grpc.aggregations[0].avg).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg

      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'score_2'
      _(grpc.aggregations[1].avg).wont_be :nil?
      _(grpc.aggregations[1].avg).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg

      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'score_3'
      _(grpc.aggregations[2].avg).wont_be :nil?
      _(grpc.aggregations[2].avg).must_be_kind_of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg
    end

    it "does not mutate existing AggregateQuery object on adding more aggregates" do
      aggregate_query_1 = query.aggregate_query
                               .add_avg('score', aggregate_alias: 'score_1')
      aggregate_query_2 = aggregate_query_1
                               .add_avg('score', aggregate_alias: 'score_2')
      refute aggregate_query_1.to_grpc == aggregate_query_2.to_grpc
      _(aggregate_query_1.to_grpc).must_equal(query.aggregate_query
                                              .add_avg('score', aggregate_alias: 'score_1')
                                              .to_grpc)
      _(aggregate_query_2.to_grpc).must_equal(query.aggregate_query
                                             .add_avg('score', aggregate_alias: 'score_1')
                                             .add_avg('score', aggregate_alias: 'score_2')
                                             .to_grpc)
    end

    it "gets an aggregate query with custom alias" do
      expected_params = Google::Cloud::Firestore::V1::RunAggregationQueryRequest.new(
        parent: parent,
        structured_aggregation_query: Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
          structured_query: Google::Cloud::Firestore::V1::StructuredQuery.new(
            select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
              fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "score")])
          ),
          aggregations: [
            Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
              avg: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg.new(
                field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "score")
              ),
              alias: "total_score" # custom alias
            )
          ]
        )
      )
      mocked_response = [
        Google::Cloud::Firestore::V1::RunAggregationQueryResponse.new(
          result: Google::Cloud::Firestore::V1::AggregationResult.new(
            aggregate_fields: {
              "total_score": Google::Cloud::Firestore::V1::Value.new(integer_value: 3)
            }
          )
        )
      ].to_enum
      firestore_mock.expect :run_aggregation_query, mocked_response, [expected_params]

      aggregate_query = query.aggregate_query.add_avg 'score', aggregate_alias: "total_score" # custom alias
      results_enum = aggregate_query.get

      _(results_enum).must_be_kind_of Enumerator
      results = results_enum.to_a
      _(results.count).must_equal 1
      results.each do |result|
        _(result).must_be_kind_of Google::Cloud::Firestore::AggregateQuerySnapshot
        _(result.get).must_equal 3
        _(result.get('total_score')).must_equal 3
      end
    end
  end
end
