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
        # @private
        DEFAULT_COUNT_AGGREGATE_ALIAS = "count".freeze

        # @private
        DEFAULT_SUM_AGGREGATE_ALIAS = "sum".freeze

        # @private
        DEFAULT_AVG_AGGREGATE_ALIAS = "avg".freeze

        ##
        # @private The Google::Cloud::Datastore::V1::AggregationQuery object.
        attr_reader :grpc

        ##
        # @private
        #
        # Returns a new AggregateQuery object
        #
        # @param query [Google::Cloud::Datastore::V1::Query]
        def initialize query
          @grpc = Google::Cloud::Datastore::V1::AggregationQuery.new(
            nested_query: query,
            aggregations: []
          )
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
          aggregate_alias ||= DEFAULT_COUNT_AGGREGATE_ALIAS
          @grpc.aggregations << Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
            count: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Count.new,
            alias: aggregate_alias
          )

          self
        end

        ##
        # Adds a sum aggregate.
        #
        # @param name [String] The property to sum by.
        # @param aggregate_alias [String] Alias to refer to the aggregate. Optional
        #
        # @return [AggregateQuery] The modified aggregate query object with the added SUM aggregate.
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
        #                          .add_sum("score")
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get
        #
        # @example Alias an aggregate SUM query
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task")
        #        .where("done", "=", false)
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_sum("score", aggregate_alias: 'total_score')
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get('total_score')
        #
        def add_sum name, aggregate_alias: nil
          aggregate_alias ||= DEFAULT_SUM_AGGREGATE_ALIAS
          @grpc.aggregations << Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
            sum: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Sum.new(
              property: Google::Cloud::Datastore::V1::PropertyReference.new(
                name: name
              )
            ),
            alias: aggregate_alias
          )

          self
        end

        ##
        # Adds an average aggregate.
        #
        # @param name [String] The property to apply average on.
        # @param aggregate_alias [String] Alias to refer to the aggregate. Optional
        #
        # @return [AggregateQuery] The modified aggregate query object with the added AVG aggregate.
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
        #                          .add_avg("score")
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get
        #
        # @example Alias an aggregate AVG query
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task")
        #        .where("done", "=", false)
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_avg("score", aggregate_alias: 'avg_score')
        #
        #   aggregate_query_results = dataset.run_aggregation aggregate_query
        #   puts aggregate_query_results.get('avg_score')
        #
        def add_avg name, aggregate_alias: nil
          aggregate_alias ||= DEFAULT_AVG_AGGREGATE_ALIAS
          @grpc.aggregations << Google::Cloud::Datastore::V1::AggregationQuery::Aggregation.new(
            avg: Google::Cloud::Datastore::V1::AggregationQuery::Aggregation::Avg.new(
              property: Google::Cloud::Datastore::V1::PropertyReference.new(
                name: name
              )
            ),
            alias: aggregate_alias
          )

          self
        end

        # @private
        def to_grpc
          @grpc
        end
      end
    end
  end
end
