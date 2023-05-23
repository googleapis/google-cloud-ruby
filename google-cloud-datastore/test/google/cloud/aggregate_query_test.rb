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
