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

require "google/cloud/firestore/v1"
require "google/cloud/firestore/aggregate_query_snapshot"
require "google/cloud/firestore/aggregate_query_explain_result"

module Google
  module Cloud
    module Firestore
      ##
      # # AggregateQuery
      #
      # An aggregate query can be used to fetch aggregate values (ex: count) for a query
      #
      # Instances of this class are immutable. All methods that refine the aggregate query
      # return new instances.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   query = firestore.col "cities"
      #
      #   # Create an aggregate query
      #   aggregate_query = query.aggregate_query
      #                          .add_count
      #
      #   aggregate_query.get do |aggregate_snapshot|
      #     puts aggregate_snapshot.get
      #   end
      #
      # @example Alias an aggregate query
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Create a query
      #   query = firestore.col "cities"
      #
      #   # Create an aggregate query
      #   aggregate_query = query.aggregate_query
      #                          .add_count aggregate_alias: 'total_cities'
      #
      #   aggregate_query.get do |aggregate_snapshot|
      #     puts aggregate_snapshot.get('total_cities')
      #   end
      #
      class AggregateQuery
        ##
        # @private The firestore client object.
        attr_accessor :client

        ##
        # @private The type for limit queries.
        attr_reader :parent_path

        ##
        # @private The Google::Cloud::Firestore::Query object.
        attr_reader :query

        ##
        # @private Object of type
        # Google::Cloud::Firestore::V1::StructuredAggregationQuery
        attr_reader :grpc

        # @private
        DEFAULT_COUNT_ALIAS = "count".freeze

        # @private
        DEFAULT_SUM_ALIAS = "sum".freeze

        # @private
        DEFAULT_AVG_ALIAS = "avg".freeze

        ##
        # @private Creates a new AggregateQuery
        def initialize query, parent_path, client
          @query = query
          @parent_path = parent_path
          @client = client
          @grpc = Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
            structured_query: @query.query,
            aggregations: []
          )
        end

        ##
        # Adds a count aggregate.
        #
        # @param aggregate_alias [String] Alias to refer to the aggregate. Optional
        #
        # @return [AggregateQuery] A new aggregate query with the added count aggregate.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_count
        #
        #   aggregate_query.get do |aggregate_snapshot|
        #     puts aggregate_snapshot.get
        #   end
        #
        def add_count aggregate_alias: nil
          aggregate_alias ||= DEFAULT_COUNT_ALIAS
          new_aggregate = Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            count: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Count.new,
            alias: aggregate_alias
          )

          start new_aggregate
        end

        ##
        # Adds a sum aggregate.
        #
        # @param field [String] The field to sum by
        # @param aggregate_alias [String] Alias to refer to the aggregate
        #
        # @return [AggregateQuery] A new aggregate query with the added sum aggregate.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_sum("population")
        #
        #   aggregate_query.get do |aggregate_snapshot|
        #     puts aggregate_snapshot.get
        #   end
        #
        def add_sum field, aggregate_alias: nil
          aggregate_alias ||= DEFAULT_SUM_ALIAS
          field = FieldPath.parse field unless field.is_a? FieldPath
          new_aggregate = Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            sum: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Sum.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(
                field_path: field.formatted_string
              )
            ),
            alias: aggregate_alias
          )

          start new_aggregate
        end

        ##
        # Adds an average aggregate.
        #
        # @param field [String] The field to apply average on
        # @param aggregate_alias [String] Alias to refer to the aggregate
        #
        # @return [AggregateQuery] A new aggregate query with the added average aggregate.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_avg("population")
        #
        #   aggregate_query.get do |aggregate_snapshot|
        #     puts aggregate_snapshot.get
        #   end
        #
        def add_avg field, aggregate_alias: nil
          aggregate_alias ||= DEFAULT_AVG_ALIAS
          field = FieldPath.parse field unless field.is_a? FieldPath
          new_aggregate = Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation.new(
            avg: Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation::Avg.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(
                field_path: field.formatted_string
              )
            ),
            alias: aggregate_alias
          )

          start new_aggregate
        end

        ##
        # @private
        def start new_aggregate
          combined_aggregates = [].concat(grpc.aggregations).push(new_aggregate)
          new_grpc = Google::Cloud::Firestore::V1::StructuredAggregationQuery.new(
            structured_query: @query.query,
            aggregations: combined_aggregates
          )
          self.class.new(@query, @parent_path, @client).tap do |aq|
            aq.instance_variable_set :@grpc, new_grpc
          end
        end

        ##
        # Retrieves aggregate snapshot for the query.
        #
        # @yield [snapshot] The block for accessing the aggregate query snapshots.
        # @yieldparam [AggregateQuerySnapshot] An aggregate query snapshot.
        #
        # @return [Enumerator<AggregateQuerySnapshot>] A list of aggregate query snapshots.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_count
        #
        #   aggregate_query.get do |aggregate_snapshot|
        #     puts aggregate_snapshot.get
        #   end
        #
        def get
          ensure_service!

          return enum_for :get unless block_given?

          responses = service.run_aggregate_query @parent_path, @grpc
          responses.each do |response|
            next if response.result.nil?
            yield AggregateQuerySnapshot.from_run_aggregate_query_response response
          end
        end

        ##
        # Retrieves the query explanation for the aggregate query.
        # By default, the query is only planned, not executed, returning only metrics from the
        # planning stages. If `analyze` is set to `true` the query will be planned and executed,
        # returning the `AggregateQuerySnapshot` alongside both planning and execution stage metrics.
        #
        # Unlike the enumerator returned from `AggregateQuery#get`, the `AggregateQueryExplainResult`
        # caches its snapshot and metrics after the first access.
        #
        # @param [Boolean] analyze
        #   Whether to execute the query and return the execution stage metrics
        #     in addition to planning metrics.
        #   If set to `false` the query will be planned only and will return planning
        #      stage metrics without results.
        #   If set to `true` the query will be executed, and will return the query results,
        #     planning stage metrics, and execution stage metrics.
        #   Defaults to `false`.
        #
        # @return [AggregateQueryExplainResult]
        #
        # @example Getting only the planning stage metrics for the aggregate query
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   query = firestore.col(:cities).aggregate_query.add_count
        #
        #   explain_result = query.explain
        #   metrics = explain_result.explain_metrics
        #   puts "Plan summary: #{metrics.plan_summary}" if metrics&.plan_summary
        #
        # @example Getting planning and execution stage metrics, as well as aggregate query results
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   query = firestore.col(:cities).aggregate_query.add_count
        #
        #   explain_result = query.explain analyze: true
        #   metrics = explain_result.explain_metrics
        #   puts "Plan summary: #{metrics.plan_summary}" if metrics&.plan_summary
        #   puts "Results returned: #{metrics.execution_stats.results_returned}" if metrics&.execution_stats
        #   snapshot = explain_result.snapshot
        #   puts "Count: #{snapshot.get}" if snapshot
        #
        def explain analyze: false
          ensure_service!
          validate_analyze_option! analyze

          explain_options = ::Google::Cloud::Firestore::V1::ExplainOptions.new analyze: analyze

          responses_enum = service.run_aggregate_query @parent_path, @grpc, explain_options: explain_options

          AggregateQueryExplainResult.new responses_enum
        end

        ##
        # @private
        def to_grpc
          @grpc
        end

        protected

        ##
        # @private Raise an error unless a database is available.
        def ensure_client!
          raise "Must have active connection to service" unless client
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # @private The Service object.
        def service
          ensure_client!
          client.service
        end

        # @private
        # Validates the analyze option.
        def validate_analyze_option! analyze_value
          return if [true, false].include? analyze_value
          raise ArgumentError, "analyze must be a boolean"
        end
      end
    end
  end
end
