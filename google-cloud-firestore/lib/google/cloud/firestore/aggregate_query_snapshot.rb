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
      #     puts aggregate_snapshot.get
      #   end
      # @return [Integer] The aggregate value.
      #
      # @example Alias an aggregate query
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   query = firestore.col "cities"
      #
      #   # Create an aggregate query
      #   aggregate_query = query.aggregate_query
      #                          .add_count aggregate_alias: 'total'
      #
      #   aggregate_query.get do |aggregate_snapshot|
      #     puts aggregate_snapshot.get('total')
      #   end
      class AggregateQuerySnapshot
        ##
        # Retrieves the aggregate data.
        #
        # @param aggregate_alias [String] The alias used to access
        #   the aggregate value. For an AggregateQuery with a
        #   single aggregate field, this parameter can be omitted.
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
        #     puts aggregate_snapshot.get
        #   end
        # @return [Integer] The aggregate value.
        #
        # @example Alias an aggregate query
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #                          .add_count aggregate_alias: 'total'
        #
        #   aggregate_query.get do |aggregate_snapshot|
        #     puts aggregate_snapshot.get('total')
        #   end
        def get aggregate_alias = nil
          if @aggregate_fields.count > 1 && aggregate_alias.nil?
            raise ArgumentError, "Required param aggregate_alias for AggregateQuery with multiple aggregate fields"
          end
          aggregate_alias ||= @aggregate_fields.keys.first
          @aggregate_fields[aggregate_alias]
        end

        ##
        # @private New AggregateQuerySnapshot from a
        # Google::Cloud::Firestore::V1::RunAggregationQueryResponse object.
        def self.from_run_aggregate_query_response response
          # pp response
          aggregate_fields = response
                             .result
                             .aggregate_fields
                             .map do |aggregate_alias, value|
                               # puts value
                               # puts value.double_value
                               if value.has_integer_value?
                                 [aggregate_alias, value.integer_value]
                               elsif value.has_double_value?
                                 [aggregate_alias, value.double_value]
                               elsif value.has_null_value?
                                 [aggregate_alias, nil]
                               end
                             end
                             .to_h # convert from protobuf to ruby map
                             # .transform_values { |v| v[:integer_value] }

          new.tap do |s|
            s.instance_variable_set :@aggregate_fields, aggregate_fields
          end
        end
      end
    end
  end
end
