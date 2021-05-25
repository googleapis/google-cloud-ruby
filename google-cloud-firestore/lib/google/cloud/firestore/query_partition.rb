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


require "google/cloud/firestore/query_partition/list"

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
      # See {CollectionGroup#partitions}.
      #
      # @!attribute [r] start_at
      #   The cursor that defines the first result for this partition, or `nil` if this is the first partition.
      #   @return [Array] a cursor value that can be used with {Query#start_at} or `nil` if this is the first partition.
      # @!attribute [r] end_before
      #   The cursor that defines the first result after this partition, or `nil` if this is the last partition.
      #   @return [Array] a cursor value that can be used with {Query#end_before} or `nil` if this is the last
      #     partition.
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
      #   queries = partitions.map(&:create_query)
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
        # Creates a query that only returns the documents for this partition.
        #
        # @return [Query] query.
        #
        def create_query
          base_query = @query
          base_query = base_query.start_at start_at if start_at
          base_query = base_query.end_before end_before if end_before
          base_query
        end
      end
    end
  end
end
