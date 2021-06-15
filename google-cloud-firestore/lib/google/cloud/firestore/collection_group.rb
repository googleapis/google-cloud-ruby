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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/query"
require "google/cloud/firestore/query_partition"

module Google
  module Cloud
    module Firestore
      ##
      # # CollectionGroup
      #
      # A collection group object is used for adding documents, getting
      # document references, and querying for documents, including with partitions.
      #
      # See {Client#col_group} and {Query}.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Get a collection group
      #   col_group = firestore.col_group "cities"
      #
      #   # Get and print all city documents
      #   col_group.get do |city|
      #     puts "#{city.document_id} has #{city[:population]} residents."
      #   end
      #
      class CollectionGroup < Query
        ##
        # Partitions a query by returning partition cursors that can be used to run the query in parallel. The returned
        # partition cursors are split points that can be used as starting/end points for the query results.
        #
        # @param [Integer] partition_count The desired maximum number of partition points. The number must be strictly
        #   positive. The actual number of partitions returned may be fewer.
        #
        # @return [Array<QueryPartition>] An ordered array of query partitions.
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
        def partitions partition_count
          ensure_service!

          raise ArgumentError, "partition_count must be > 0" unless partition_count.positive?

          # Partition queries require explicit ordering by __name__.
          query_with_default_order = order "__name__"
          # Since we are always returning an extra partition (with en empty endBefore cursor), we reduce the desired
          # partition count by one.
          partition_count -= 1

          grpc_partitions = if partition_count.positive?
                              # Retrieve all pages, since cursor order is not guaranteed and they must be sorted.
                              list_all partition_count, query_with_default_order
                            else
                              [] # Ensure that a single, empty QueryPartition is returned.
                            end
          cursor_values = grpc_partitions.map do |cursor|
            # Convert each cursor to a (single-element) array of Google::Cloud::Firestore::DocumentReference.
            cursor.values.map do |value|
              Convert.value_to_raw value, client
            end
          end
          # Sort the values of the returned cursor, which right now should only contain a single reference value (which
          # needs to be sorted one component at a time).
          cursor_values.sort! do |a, b|
            a.first <=> b.first
          end

          start_at = nil
          results = cursor_values.map do |end_before|
            partition = QueryPartition.new query_with_default_order, start_at, end_before
            start_at = end_before
            partition
          end
          # Always add a final QueryPartition with an empty end_before value.
          results << QueryPartition.new(query_with_default_order, start_at, nil)
          results
        end

        ##
        # @private New Collection group object from a path.
        def self.from_collection_id parent_path, collection_id, client
          query = Google::Cloud::Firestore::V1::StructuredQuery.new(
            from: [
              Google::Cloud::Firestore::V1::StructuredQuery::CollectionSelector.new(
                collection_id: collection_id,
                all_descendants: true
              )
            ]
          )
          CollectionGroup.new query, parent_path, client
        end

        protected

        def list_all partition_count, query_with_default_order
          grpc_partitions = []
          token = nil
          loop do
            grpc = service.partition_query parent_path, query_with_default_order.query, partition_count, token: token
            grpc_partitions += Array(grpc.partitions)
            token = grpc.next_page_token
            token = nil if token == ""
            break unless token
          end
          grpc_partitions
        end
      end
    end
  end
end
