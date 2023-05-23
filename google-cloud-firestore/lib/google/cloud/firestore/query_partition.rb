# Copyright 2021 Google LLC
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
      # # QueryPartition
      #
      # Represents a split point that can be used in a query as a starting and/or end point for the query results.
      #
      # The cursors returned by {#start_at} and {#end_before} can only be used in a query that matches the constraint of
      # the query that produced this partition.
      #
      # See {CollectionGroup#partitions} and {Query}.
      #
      # @!attribute [r] start_at
      #   The cursor values that define the first result for this partition, or `nil` if this is the first partition.
      #   Returns an array of values that represent a position, in the order they appear in the order by clause of the
      #   query. Can contain fewer values than specified in the order by clause. Will be used in the query returned by
      #   {#to_query}.
      #   @return [Array<Object>, nil] Typically, the values are {DocumentReference} objects.
      # @!attribute [r] end_before
      #   The cursor values that define the first result after this partition, or `nil` if this is the last partition.
      #   Returns an array of values that represent a position, in the order they appear in the order by clause of the
      #   query.  Can contain fewer values than specified in the order by clause. Will be used in the query returned by
      #   {#to_query}.
      #   @return [Array<Object>, nil] Typically, the values are {DocumentReference} objects.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   col_group = firestore.col_group "cities"
      #
      #   partitions = col_group.partitions 3
      #
      #   queries = partitions.map(&:to_query)
      #
      class QueryPartition
        attr_reader :start_at
        attr_reader :end_before

        ##
        # @private New QueryPartition from query and Cursor
        def initialize query, start_at, end_before
          @query = query
          @start_at = start_at
          @end_before = end_before
        end

        ##
        # Creates a new query that only returns the documents for this partition, using the cursor values from
        # {#start_at} and {#end_before}.
        #
        # @return [Query] The query for the partition.
        #
        def to_query
          base_query = @query
          base_query = base_query.start_at start_at if start_at
          base_query = base_query.end_before end_before if end_before
          base_query
        end
      end
    end
  end
end
