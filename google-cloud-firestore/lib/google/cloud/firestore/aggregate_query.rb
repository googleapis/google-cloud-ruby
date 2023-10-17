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
          combined_aggregates = [].concat(grpc.aggregations).concat([new_aggregate])
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
      end
    end
  end
end
