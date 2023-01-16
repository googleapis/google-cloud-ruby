# Copyright 2014 Google LLC
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

describe "Aggregate Query", :mock_datastore do
  let(:project_id) { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset) { Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new(project_id, credentials)) }
  let(:query) { Google::Cloud::Datastore::Query.new.kind("User") }
  let(:expected_query) do
    Google::Cloud::Datastore::V1::Query.new(
      projection: [],
      kind: [Google::Cloud::Datastore::V1::KindExpression.new(name: "User")],
      order: [],
      distinct_on: [],
      start_cursor: "",
      end_cursor: "",
      offset: 0
    )
  end

  before do
    dataset.service.mocked_service = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_service.verify
  end

  focus
  it "creates an aggregate query with default alias" do
    expected_aggregation_query = aggregation_query_factory('count')
    mocked_response = aggregation_query_response_factory({'count' => 4})
    dataset.service.mocked_service.expect :run_aggregation_query,
      mocked_response,
      **aggregate_query_args(project_id: project_id, aggregation_query: expected_aggregation_query)
    aq = query.aggregate_query
              .add_count
    res = dataset.run_aggregation aq
    _(res.get('count')).must_equal 4
  end

  focus
  it "creates an aggregate query with custom alias" do
    expected_aggregation_query = aggregation_query_factory('total')
    mocked_response = aggregation_query_response_factory({'total' => 4})
    dataset.service.mocked_service.expect :run_aggregation_query,
      mocked_response,
      **aggregate_query_args(project_id: project_id, aggregation_query: expected_aggregation_query)
    aq = query.aggregate_query
              .add_count(aggregate_alias: 'total')
    res = dataset.run_aggregation aq
    _(res.get('total')).must_equal 4
  end

  focus
  it "creates an aggregate query with multiple aliases" do
    expected_aggregation_query = aggregation_query_factory('total_1', 'total_2')
    mocked_response = aggregation_query_response_factory({'total_1' => 4, 'total_2' => 4})
    dataset.service.mocked_service.expect :run_aggregation_query,
    mocked_response,
      **aggregate_query_args(project_id: project_id, aggregation_query: expected_aggregation_query)
    aq = query.aggregate_query
              .add_count(aggregate_alias: 'total_1')
              .add_count(aggregate_alias: 'total_2')
    res = dataset.run_aggregation aq
    _(res.get('total_1')).must_equal 4
    _(res.get('total_2')).must_equal 4
  end

  def aggregation_query_factory *aliases
    Google::Cloud::Datastore::V1::AggregationQuery.new(
      nested_query: expected_query,
      aggregations: aliases.map do |a|
        Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
          alias: a,
          count: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count.new
        )
      end
    )
  end

  def aggregation_query_response_factory props
    Google::Cloud::Datastore::V1::RunAggregationQueryResponse.new(
      batch: Google::Cloud::Datastore::V1::AggregationResultBatch.new(
        read_time: Google::Protobuf::Timestamp.new(seconds: 1673852227, nanos: 370563000),
        more_results: :NO_MORE_RESULTS,
        aggregation_results: [
          Google::Cloud::Datastore::V1::AggregationResult.new(
            aggregate_properties: props.transform_values { |v| Google::Cloud::Datastore::V1::Value.new(meaning: 0, exclude_from_indexes: false, integer_value: v) }
          )
        ]
      )
    )
  end

  def aggregate_query_args project_id: nil,
                           partition_id: nil,
                           read_options: nil,
                           aggregation_query: nil,
                           gql_query: nil
    {
      project_id: project_id,
      partition_id: partition_id,
      read_options: read_options,
      aggregation_query: aggregation_query,
      gql_query: gql_query
    }
  end
end
