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


module Google
  module Cloud
    module Firestore
      ##
      # # AggregateQuerySnapshot
      #
      # An aggregate query snapshot object is an immutable representation for
      # an aggregate query result.
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
      #     puts aggregate_snapshot.get('count')
      #   end
      #
      class AggregateQuerySnapshot
        ##
        # Retrieves the aggregate data.
        #
        # @param [String] aggregate_alias The alias used
        #   to access the aggregate value. For count, the
        #   default value is "count".
        #
        # @return [Integer] The aggregate value.
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
        #     puts aggregate_snapshot.get('count')
        #   end
        def get aggregate_alias
          return unless @results.key? aggregate_alias
          @results[aggregate_alias][:integer_value]
        end

        ##
        # @private New AggregateQuerySnapshot from a
        # Google::Cloud::Firestore::V1::RunAggregationQueryResponse object.
        def self.from_run_aggregate_query_response response
          # convert from protobuf to ruby map
          aggregate_fields = response.result.aggregate_fields.to_h
          # { |k, v| [String(k), String(v)] }

          new.tap do |s|
            s.instance_variable_set :@results, aggregate_fields
          end
        end
      end
    end
  end
end
