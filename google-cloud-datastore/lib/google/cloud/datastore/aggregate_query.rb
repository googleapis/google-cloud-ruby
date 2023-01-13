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


require "google/cloud/datastore/v1"

class AggregateQuery
  ##
  # @private The Google::Cloud::Datastore::V1::Query object.
  attr_reader :query

  ##
  # @private Array of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation objects
  attr_reader :aggregates

  def initialize query, aggregates: []
    @query = query
    @aggregates = aggregates
  end

  def add_count aggregate_alias: nil
    aggregate_alias ||= ALIASES[:count]
    new_aggregates = @aggregates.dup
    new_aggregates << Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
      count: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count.new,
      alias: aggregate_alias
    )
    AggregateQuery.start query, new_aggregates
  end

  ##
  # @private Start a new AggregateQuery.
  def self.start query, aggregates
    new query, aggregates: aggregates
  end

  # @private
  def to_grpc
    Google::Cloud::Datastore::V1::AggregationQuery.new(
      nested_query: query,
      aggregations: aggregates
    )
  end

  ##
  # @private
  ALIASES = {
    count: "count"
  }.freeze
end
