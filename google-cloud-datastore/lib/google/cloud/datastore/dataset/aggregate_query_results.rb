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

module Google
  module Cloud
    module Datastore
      class Dataset
        ##
        # # AggregateQueryResults
        #
        # An AggregateQueryResult object is a representation for
        # a result of an AggregateQuery or a GqlQuery.
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
        class AggregateQueryResults
          ##
          # @private Object of type [Hash{String => Object}].
          #
          # String can have the following values:
          #   - an aggregate literal "sum", "avg", or "count"
          #   - a custom aggregate alias
          # Object can have the following types:
          #   - Integer
          #   - Float
          attr_reader :aggregate_fields

          ##
          # Read timestamp the query was done on the database at.
          #
          # @return Google::Protobuf::Timestamp
          attr_reader :read_time

          ##
          # Retrieves the aggregate data.
          #
          # @param aggregate_alias [String] The alias used to access
          #   the aggregate value. For an AggregateQuery with a
          #   single aggregate field, this parameter can be omitted.
          #
          # @return [Integer, Float, nil] The aggregate value. Returns `nil`
          # if the aggregate_alias does not exist.
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
          def get aggregate_alias = nil
            if @aggregate_fields.count > 1 && aggregate_alias.nil?
              raise ArgumentError, "Required param aggregate_alias for AggregateQuery with multiple aggregate fields"
            end
            aggregate_alias ||= @aggregate_fields.keys.first
            @aggregate_fields[aggregate_alias]
          end

          ##
          # @private New AggregateQueryResults from a
          # Google::Cloud::Datastore::V1::RunAggregationQueryResponse object.
          def self.from_grpc aggregate_query_response
            aggregate_fields = aggregate_query_response
                               .batch
                               .aggregation_results[0]
                               .aggregate_properties
                               .map do |aggregate_alias, value|
                                 if value.has_integer_value?
                                   [aggregate_alias, value.integer_value]
                                 else
                                   [aggregate_alias, value.double_value]
                                 end
                               end
                               .to_h

            new.tap do |s|
              s.instance_variable_set :@aggregate_fields, aggregate_fields
              s.instance_variable_set :@read_time, aggregate_query_response.batch.read_time
            end
          end
        end
      end
    end
  end
end
