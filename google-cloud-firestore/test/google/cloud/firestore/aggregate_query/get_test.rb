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
  let(:query) { Google::Cloud::Firestore::Query.start(nil, "#{firestore.path}/documents", firestore).select(:name) }
  let :expected_structured_query do
    Google::Cloud::Firestore::V1::StructuredQuery.new(
      select: Google::Cloud::Firestore::V1::StructuredQuery::Projection.new(
        fields: [Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "name")])
    )
  end

  focus; it "gets an aggregate query with a count" do
    expected_params = {
      :parent => parent,
      :structured_aggregation_query => Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
        structured_query: expected_structured_query,
        aggregations: [
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "count"
          )
        ]
      )
    }
    firestore_mock.expect :run_aggregation_query, [], [expected_params]

    aq = query.aggregate_query.add_count
    aq.get {}

    firestore_mock.verify
  end

  focus; it "gets an aggregate query with custom alias" do
    expected_params = {
      :parent => parent,
      :structured_aggregation_query => Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
        structured_query: expected_structured_query,
        aggregations: [
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "total_score"
          )
        ]
      )
    }
    firestore_mock.expect :run_aggregation_query, [], [expected_params]

    aq = query.aggregate_query.add_count aggregate_alias: "total_score"
    aq.get {}

    firestore_mock.verify
  end

  focus; it "gets multiple aggregates of query" do
    expected_params = {
      :parent => parent,
      :structured_aggregation_query => Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
        structured_query: expected_structured_query,
        aggregations: [
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "alias_1"
          ),
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "alias_2"
          ),
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "alias_3"
          ),
        ]
      )
    }
    firestore_mock.expect :run_aggregation_query, [], [expected_params]

    aq = query.aggregate_query.add_count(aggregate_alias: "alias_1")
                              .add_count(aggregate_alias: "alias_2")
                              .add_count(aggregate_alias: "alias_3")
    aq.get {}

    firestore_mock.verify
  end

  focus; it "gets multiple calls to run_aggregate_query" do
    expected_params = {
      :parent => parent,
      :structured_aggregation_query => Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
        structured_query: expected_structured_query,
        aggregations: [
          Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: "count"
          )
        ]
      )
    }
    firestore_mock.expect :run_aggregation_query, [], [expected_params]
    firestore_mock.expect :run_aggregation_query, [], [expected_params]

    aq = query.aggregate_query.add_count(aggregate_alias: "count")                      
    aq.get {}
    aq.get {}

    firestore_mock.verify
    firestore_mock.verify
  end
end