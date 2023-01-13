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

  protected

  ##
  # @private
  ALIASES = {
    count: "count"
  }.freeze
end