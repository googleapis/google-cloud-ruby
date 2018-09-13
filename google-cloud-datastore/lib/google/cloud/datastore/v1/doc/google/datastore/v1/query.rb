# Copyright 2018 Google LLC
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
  module Datastore
    module V1
      # The result of fetching an entity from Datastore.
      # @!attribute [rw] entity
      #   @return [Google::Datastore::V1::Entity]
      #     The resulting entity.
      # @!attribute [rw] version
      #   @return [Integer]
      #     The version of the entity, a strictly positive number that monotonically
      #     increases with changes to the entity.
      #
      #     This field is set for {Google::Datastore::V1::EntityResult::ResultType::FULL `FULL`} entity
      #     results.
      #
      #     For {Google::Datastore::V1::LookupResponse#missing missing} entities in `LookupResponse`, this
      #     is the version of the snapshot that was used to look up the entity, and it
      #     is always set except for eventually consistent reads.
      # @!attribute [rw] cursor
      #   @return [String]
      #     A cursor that points to the position after the result entity.
      #     Set only when the `EntityResult` is part of a `QueryResultBatch` message.
      class EntityResult
        # Specifies what data the 'entity' field contains.
        # A `ResultType` is either implied (for example, in `LookupResponse.missing`
        # from `datastore.proto`, it is always `KEY_ONLY`) or specified by context
        # (for example, in message `QueryResultBatch`, field `entity_result_type`
        # specifies a `ResultType` for all the values in field `entity_results`).
        module ResultType
          # Unspecified. This value is never used.
          RESULT_TYPE_UNSPECIFIED = 0

          # The key and properties.
          FULL = 1

          # A projected subset of properties. The entity may have no key.
          PROJECTION = 2

          # Only the key.
          KEY_ONLY = 3
        end
      end

      # A query for entities.
      # @!attribute [rw] projection
      #   @return [Array<Google::Datastore::V1::Projection>]
      #     The projection to return. Defaults to returning all properties.
      # @!attribute [rw] kind
      #   @return [Array<Google::Datastore::V1::KindExpression>]
      #     The kinds to query (if empty, returns entities of all kinds).
      #     Currently at most 1 kind may be specified.
      # @!attribute [rw] filter
      #   @return [Google::Datastore::V1::Filter]
      #     The filter to apply.
      # @!attribute [rw] order
      #   @return [Array<Google::Datastore::V1::PropertyOrder>]
      #     The order to apply to the query results (if empty, order is unspecified).
      # @!attribute [rw] distinct_on
      #   @return [Array<Google::Datastore::V1::PropertyReference>]
      #     The properties to make distinct. The query results will contain the first
      #     result for each distinct combination of values for the given properties
      #     (if empty, all results are returned).
      # @!attribute [rw] start_cursor
      #   @return [String]
      #     A starting point for the query results. Query cursors are
      #     returned in query result batches and
      #     [can only be used to continue the same query](https://cloud.google.com/datastore/docs/concepts/queries#cursors_limits_and_offsets).
      # @!attribute [rw] end_cursor
      #   @return [String]
      #     An ending point for the query results. Query cursors are
      #     returned in query result batches and
      #     [can only be used to limit the same query](https://cloud.google.com/datastore/docs/concepts/queries#cursors_limits_and_offsets).
      # @!attribute [rw] offset
      #   @return [Integer]
      #     The number of results to skip. Applies before limit, but after all other
      #     constraints. Optional. Must be >= 0 if specified.
      # @!attribute [rw] limit
      #   @return [Google::Protobuf::Int32Value]
      #     The maximum number of results to return. Applies after all other
      #     constraints. Optional.
      #     Unspecified is interpreted as no limit.
      #     Must be >= 0 if specified.
      class Query; end

      # A representation of a kind.
      # @!attribute [rw] name
      #   @return [String]
      #     The name of the kind.
      class KindExpression; end

      # A reference to a property relative to the kind expressions.
      # @!attribute [rw] name
      #   @return [String]
      #     The name of the property.
      #     If name includes "."s, it may be interpreted as a property name path.
      class PropertyReference; end

      # A representation of a property in a projection.
      # @!attribute [rw] property
      #   @return [Google::Datastore::V1::PropertyReference]
      #     The property to project.
      class Projection; end

      # The desired order for a specific property.
      # @!attribute [rw] property
      #   @return [Google::Datastore::V1::PropertyReference]
      #     The property to order by.
      # @!attribute [rw] direction
      #   @return [Google::Datastore::V1::PropertyOrder::Direction]
      #     The direction to order by. Defaults to `ASCENDING`.
      class PropertyOrder
        # The sort direction.
        module Direction
          # Unspecified. This value must not be used.
          DIRECTION_UNSPECIFIED = 0

          # Ascending.
          ASCENDING = 1

          # Descending.
          DESCENDING = 2
        end
      end

      # A holder for any type of filter.
      # @!attribute [rw] composite_filter
      #   @return [Google::Datastore::V1::CompositeFilter]
      #     A composite filter.
      # @!attribute [rw] property_filter
      #   @return [Google::Datastore::V1::PropertyFilter]
      #     A filter on a property.
      class Filter; end

      # A filter that merges multiple other filters using the given operator.
      # @!attribute [rw] op
      #   @return [Google::Datastore::V1::CompositeFilter::Operator]
      #     The operator for combining multiple filters.
      # @!attribute [rw] filters
      #   @return [Array<Google::Datastore::V1::Filter>]
      #     The list of filters to combine.
      #     Must contain at least one filter.
      class CompositeFilter
        # A composite filter operator.
        module Operator
          # Unspecified. This value must not be used.
          OPERATOR_UNSPECIFIED = 0

          # The results are required to satisfy each of the combined filters.
          AND = 1
        end
      end

      # A filter on a specific property.
      # @!attribute [rw] property
      #   @return [Google::Datastore::V1::PropertyReference]
      #     The property to filter by.
      # @!attribute [rw] op
      #   @return [Google::Datastore::V1::PropertyFilter::Operator]
      #     The operator to filter by.
      # @!attribute [rw] value
      #   @return [Google::Datastore::V1::Value]
      #     The value to compare the property to.
      class PropertyFilter
        # A property filter operator.
        module Operator
          # Unspecified. This value must not be used.
          OPERATOR_UNSPECIFIED = 0

          # Less than.
          LESS_THAN = 1

          # Less than or equal.
          LESS_THAN_OR_EQUAL = 2

          # Greater than.
          GREATER_THAN = 3

          # Greater than or equal.
          GREATER_THAN_OR_EQUAL = 4

          # Equal.
          EQUAL = 5

          # Has ancestor.
          HAS_ANCESTOR = 11
        end
      end

      # A [GQL query](https://cloud.google.com/datastore/docs/apis/gql/gql_reference).
      # @!attribute [rw] query_string
      #   @return [String]
      #     A string of the format described
      #     [here](https://cloud.google.com/datastore/docs/apis/gql/gql_reference).
      # @!attribute [rw] allow_literals
      #   @return [true, false]
      #     When false, the query string must not contain any literals and instead must
      #     bind all values. For example,
      #     `SELECT * FROM Kind WHERE a = 'string literal'` is not allowed, while
      #     `SELECT * FROM Kind WHERE a = @value` is.
      # @!attribute [rw] named_bindings
      #   @return [Hash{String => Google::Datastore::V1::GqlQueryParameter}]
      #     For each non-reserved named binding site in the query string, there must be
      #     a named parameter with that name, but not necessarily the inverse.
      #
      #     Key must match regex `[A-Za-z_$][A-Za-z_$0-9]*`, must not match regex
      #     `__.*__`, and must not be `""`.
      # @!attribute [rw] positional_bindings
      #   @return [Array<Google::Datastore::V1::GqlQueryParameter>]
      #     Numbered binding site @1 references the first numbered parameter,
      #     effectively using 1-based indexing, rather than the usual 0.
      #
      #     For each binding site numbered i in `query_string`, there must be an i-th
      #     numbered parameter. The inverse must also be true.
      class GqlQuery; end

      # A binding parameter for a GQL query.
      # @!attribute [rw] value
      #   @return [Google::Datastore::V1::Value]
      #     A value parameter.
      # @!attribute [rw] cursor
      #   @return [String]
      #     A query cursor. Query cursors are returned in query
      #     result batches.
      class GqlQueryParameter; end

      # A batch of results produced by a query.
      # @!attribute [rw] skipped_results
      #   @return [Integer]
      #     The number of results skipped, typically because of an offset.
      # @!attribute [rw] skipped_cursor
      #   @return [String]
      #     A cursor that points to the position after the last skipped result.
      #     Will be set when `skipped_results` != 0.
      # @!attribute [rw] entity_result_type
      #   @return [Google::Datastore::V1::EntityResult::ResultType]
      #     The result type for every entity in `entity_results`.
      # @!attribute [rw] entity_results
      #   @return [Array<Google::Datastore::V1::EntityResult>]
      #     The results for this batch.
      # @!attribute [rw] end_cursor
      #   @return [String]
      #     A cursor that points to the position after the last result in the batch.
      # @!attribute [rw] more_results
      #   @return [Google::Datastore::V1::QueryResultBatch::MoreResultsType]
      #     The state of the query after the current batch.
      # @!attribute [rw] snapshot_version
      #   @return [Integer]
      #     The version number of the snapshot this batch was returned from.
      #     This applies to the range of results from the query's `start_cursor` (or
      #     the beginning of the query if no cursor was given) to this batch's
      #     `end_cursor` (not the query's `end_cursor`).
      #
      #     In a single transaction, subsequent query result batches for the same query
      #     can have a greater snapshot version number. Each batch's snapshot version
      #     is valid for all preceding batches.
      #     The value will be zero for eventually consistent queries.
      class QueryResultBatch
        # The possible values for the `more_results` field.
        module MoreResultsType
          # Unspecified. This value is never used.
          MORE_RESULTS_TYPE_UNSPECIFIED = 0

          # There may be additional batches to fetch from this query.
          NOT_FINISHED = 1

          # The query is finished, but there may be more results after the limit.
          MORE_RESULTS_AFTER_LIMIT = 2

          # The query is finished, but there may be more results after the end
          # cursor.
          MORE_RESULTS_AFTER_CURSOR = 4

          # The query is finished, and there are no more results.
          NO_MORE_RESULTS = 3
        end
      end
    end
  end
end