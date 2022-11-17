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

require 'debug'

module Google
  module Cloud
    module Firestore
      class AggregateQuery

        ##
        # @private The firestore client object.
        attr_accessor :client


        def initialize query, parent_path, client
          @query = query
          @parent_path = parent_path
          @aggregates = []
          @client = client
        end

        def add_count aggregate_alias: nil
          aggregate_alias ||= ALIASES[:count]
          @aggregates << StructuredAggregationQuery::Aggregation.new(
            count: StructuredAggregationQuery::Aggregation::Count.new,
            alias: aggregate_alias
          )
          self
        end

        # should run the passed block
        def get
          # ensure_service!

          # return enum_for :get unless block_given?

          structured_aggregation_query = StructuredAggregationQuery.new(
            structured_query: @query,
            aggregations: @aggregates
          )
          results = service.run_aggregate_query @parent_path, structured_aggregation_query
          snapshot = AggregateQuerySnapshot.from_run_aggregate_query_response results
          yield snapshot
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
        # @private Raise an error unless an database available.
        def ensure_client!
          raise "Must have active connection to service" unless client
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