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
        # @private The Google::Cloud::Firestore::V1::StructuredQuery object.
        attr_reader :query

        ##
        # @private Array of Google::Cloud::Firestore::V1::StructuredAggregationQuery::Aggregation objects
        attr_reader :aggregates

        ##
        # @private Creates a new AggregateQuery
        def initialize query, parent_path, client, aggregates: []
          @query = query
          @parent_path = parent_path
          @aggregates = aggregates
          @client = client
        end

        ##
        # Adds a count aggregate.
        #
        # @param [aggregate_alias] Alias to refer to the aggregate. Optional
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
          aggregate_alias ||= ALIASES[:count]
          new_aggregates = @aggregates.dup
          new_aggregates << StructuredAggregationQuery::Aggregation.new(
            count: StructuredAggregationQuery::Aggregation::Count.new,
            alias: aggregate_alias
          )
          AggregateQuery.start query, new_aggregates, parent_path, client
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

          responses = service.run_aggregate_query @parent_path, structured_aggregation_query
          responses.each do |response|
            next if response.result.nil?
            yield AggregateQuerySnapshot.from_run_aggregate_query_response response
          end
        end

        ##
        # @private Creates a Google::Cloud::Firestore::V1::StructuredAggregationQuery object
        def structured_aggregation_query
          StructuredAggregationQuery.new(
            structured_query: @query,
            aggregations: @aggregates
          )
        end

        ##
        # @private Start a new AggregateQuery.
        def self.start query, aggregates, parent_path, client
          new query, parent_path, client, aggregates: aggregates
        end

        protected

        ##
        # @private
        StructuredAggregationQuery = Google::Cloud::Firestore::V1::StructuredAggregationQuery

        ##
        # @private
        ALIASES = {
          count: "count"
        }.freeze

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
      end
    end
  end
end
