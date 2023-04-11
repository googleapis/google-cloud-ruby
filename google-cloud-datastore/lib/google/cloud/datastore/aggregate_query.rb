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

module Google
  module Cloud
    module Datastore
      ##
      # # AggregateQuery
      #
      # An aggregate query can be used to fetch aggregate values (ex: count) for a query
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task")
      #        .where("done", "=", false)
      #
      #   Create an aggregate query
      #   aggregate_query = query.aggregate_query
      #                          .add_count
      #
      #   aggregate_query_results = dataset.run_aggregation aggregate_query
      #   puts aggregate_query_results.get
      #
      # @example Alias an aggregate query
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task")
      #        .where("done", "=", false)
      #
      #   Create an aggregate query
      #   aggregate_query = query.aggregate_query
      #                          .add_count aggregate_alias: 'total'
      #
      #   aggregate_query_results = dataset.run_aggregation aggregate_query
      #   puts aggregate_query_results.get('total')
      #
      class AggregateQuery
        ##
        # @private The Google::Cloud::Datastore::V1::Query object.
        attr_reader :query

        ##
        # @private Array of Google::Cloud::Datastore::V1::AggregationQuery::Aggregation objects
        attr_reader :aggregates

        ##
        # @private Creates a new AggregateQuery
        def initialize query
          @query = query
          @aggregates = []
        end

        ##
        # Adds a count aggregate.
        #
        # @param aggregate_alias [String] Alias to refer to the aggregate. Optional
        #
        # @return [AggregateQuery] The modified aggregate query object with the added count aggregate.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task")
        #        .where("done", "=", false)
        #
        #   Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_count
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get
        #
        # @example Alias an aggregate query
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task")
        #        .where("done", "=", false)
        #
        #   Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_count aggregate_alias: 'total'
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get('total')
        #
        def add_count aggregate_alias: nil
          aggregate_alias ||= ALIASES[:count]
          aggregates << Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
            count: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count.new,
            alias: aggregate_alias
          )

          self
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
    end
  end
end
