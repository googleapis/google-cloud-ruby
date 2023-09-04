# Copyright 2023 Google LLC
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

describe Google::Cloud::Datastore::AggregateQuery, :mock_datastore do
  let(:query) { Google::Cloud::Datastore::Query.new.kind("User") }

  describe "Common tests for aggregates" do
    it "creates empty AggregateQuery object" do
      aggregate_query = query.aggregate_query
  
      _(aggregate_query).must_be_kind_of Google::Cloud::Datastore::AggregateQuery
  
      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery
  
      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc
  
      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 0
    end    
  end

  describe "COUNT aggregate" do
    it "creates COUNT aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_count
  
      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery
  
      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc
  
      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1
  
      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'count'
      _(grpc.aggregations.first.count).wont_be :nil?
      _(grpc.aggregations.first.count).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count
    end
  
    it "creates COUNT aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_count aggregate_alias: 'total'
  
      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery
  
      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc
  
      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1
  
      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'total'
      _(grpc.aggregations.first.count).wont_be :nil?
      _(grpc.aggregations.first.count).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count
    end
  
    it "creates multiple COUNT aggregates" do
      aggregate_query = query.aggregate_query
                             .add_count(aggregate_alias: 'total_1')
                             .add_count(aggregate_alias: 'total_2')
                             .add_count(aggregate_alias: 'total_3')
  
      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery
  
      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc
  
      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3
  
      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'total_1'
      _(grpc.aggregations[0].count).wont_be :nil?
      _(grpc.aggregations[0].count).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count
  
      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'total_2'
      _(grpc.aggregations[1].count).wont_be :nil?
      _(grpc.aggregations[1].count).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count
  
      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'total_3'
      _(grpc.aggregations[2].count).wont_be :nil?
      _(grpc.aggregations[2].count).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count
    end
  end

  describe "SUM aggregate" do
    it "creates SUM aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_sum 'score'

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'sum' # default alias
      _(grpc.aggregations.first.sum).wont_be :nil?
      _(grpc.aggregations.first.sum).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum
      _(grpc.aggregations.first.sum.property).wont_be :nil?
      _(grpc.aggregations.first.sum.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations.first.sum.property.name).wont_be :nil?
      _(grpc.aggregations.first.sum.property.name).must_equal 'score'
    end

    it "creates SUM aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_sum 'score', aggregate_alias: 'total'

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'total' # custom alias
      _(grpc.aggregations.first.sum).wont_be :nil?
      _(grpc.aggregations.first.sum).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum
      _(grpc.aggregations.first.sum.property).wont_be :nil?
      _(grpc.aggregations.first.sum.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations.first.sum.property.name).wont_be :nil?
      _(grpc.aggregations.first.sum.property.name).must_equal 'score'
    end

    it "creates multiple SUM aggregates" do
      aggregate_query = query.aggregate_query
                             .add_sum('score', aggregate_alias: 'total_1')
                             .add_sum('score', aggregate_alias: 'total_2')
                             .add_sum('score', aggregate_alias: 'total_3')

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3

      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'total_1' # custom alias
      _(grpc.aggregations[0].sum).wont_be :nil?
      _(grpc.aggregations[0].sum).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum
      _(grpc.aggregations[0].sum.property).wont_be :nil?
      _(grpc.aggregations[0].sum.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[0].sum.property.name).wont_be :nil?
      _(grpc.aggregations[0].sum.property.name).must_equal 'score'

      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'total_2' # custom alias
      _(grpc.aggregations[1].sum).wont_be :nil?
      _(grpc.aggregations[1].sum).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum
      _(grpc.aggregations[1].sum.property).wont_be :nil?
      _(grpc.aggregations[1].sum.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[1].sum.property.name).wont_be :nil?
      _(grpc.aggregations[1].sum.property.name).must_equal 'score'

      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'total_3' # custom alias
      _(grpc.aggregations[2].sum).wont_be :nil?
      _(grpc.aggregations[2].sum).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum
      _(grpc.aggregations[2].sum.property).wont_be :nil?
      _(grpc.aggregations[2].sum.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[2].sum.property.name).wont_be :nil?
      _(grpc.aggregations[2].sum.property.name).must_equal 'score'
    end
  end

  describe "AVG aggregate" do
    it "creates AVG aggregate with default alias" do
      aggregate_query = query.aggregate_query
                             .add_avg 'score'

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'avg' # default alias
      _(grpc.aggregations.first.avg).wont_be :nil?
      _(grpc.aggregations.first.avg).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg
      _(grpc.aggregations.first.avg.property).wont_be :nil?
      _(grpc.aggregations.first.avg.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations.first.avg.property.name).wont_be :nil?
      _(grpc.aggregations.first.avg.property.name).must_equal 'score'
    end

    it "creates AVG aggregate with custom alias" do
      aggregate_query = query.aggregate_query
                             .add_avg 'score', aggregate_alias: 'avg_score'

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 1

      _(grpc.aggregations.first.alias).wont_be :nil?
      _(grpc.aggregations.first.alias).must_equal 'avg_score' # custom alias
      _(grpc.aggregations.first.avg).wont_be :nil?
      _(grpc.aggregations.first.avg).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg
      _(grpc.aggregations.first.avg.property).wont_be :nil?
      _(grpc.aggregations.first.avg.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations.first.avg.property.name).wont_be :nil?
      _(grpc.aggregations.first.avg.property.name).must_equal 'score'
    end

    it "creates multiple AVG aggregates" do
      aggregate_query = query.aggregate_query
                             .add_avg('score', aggregate_alias: 'avg_score_1')
                             .add_avg('score', aggregate_alias: 'avg_score_2')
                             .add_avg('score', aggregate_alias: 'avg_score_3')

      grpc = aggregate_query.to_grpc
      _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery

      _(grpc.nested_query).wont_be :nil?
      _(grpc.nested_query).must_be_kind_of Google::Cloud::Datastore::V1::Query
      _(grpc.nested_query).must_equal query.to_grpc

      _(grpc.aggregations).wont_be :nil?
      _(grpc.aggregations).must_be_kind_of Google::Protobuf::RepeatedField
      _(grpc.aggregations.size).must_equal 3

      _(grpc.aggregations[0].alias).wont_be :nil?
      _(grpc.aggregations[0].alias).must_equal 'avg_score_1' # custom alias
      _(grpc.aggregations[0].avg).wont_be :nil?
      _(grpc.aggregations[0].avg).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg
      _(grpc.aggregations[0].avg.property).wont_be :nil?
      _(grpc.aggregations[0].avg.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[0].avg.property.name).wont_be :nil?
      _(grpc.aggregations[0].avg.property.name).must_equal 'score'

      _(grpc.aggregations[1].alias).wont_be :nil?
      _(grpc.aggregations[1].alias).must_equal 'avg_score_2' # custom alias
      _(grpc.aggregations[1].avg).wont_be :nil?
      _(grpc.aggregations[1].avg).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg
      _(grpc.aggregations[1].avg.property).wont_be :nil?
      _(grpc.aggregations[1].avg.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[1].avg.property.name).wont_be :nil?
      _(grpc.aggregations[1].avg.property.name).must_equal 'score'

      _(grpc.aggregations[2].alias).wont_be :nil?
      _(grpc.aggregations[2].alias).must_equal 'avg_score_3' # custom alias
      _(grpc.aggregations[2].avg).wont_be :nil?
      _(grpc.aggregations[2].avg).must_be_kind_of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg
      _(grpc.aggregations[2].avg.property).wont_be :nil?
      _(grpc.aggregations[2].avg.property).must_be_kind_of Google::Cloud::Datastore::V1::PropertyReference
      _(grpc.aggregations[2].avg.property.name).wont_be :nil?
      _(grpc.aggregations[2].avg.property.name).must_equal 'score'
    end
  end
end
