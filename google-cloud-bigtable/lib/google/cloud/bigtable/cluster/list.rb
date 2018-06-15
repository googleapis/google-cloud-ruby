# frozen_string_literal: true

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


require "delegate"

module Google
  module Cloud
    module Bigtable
      class Cluster
        # Cluster::List is a special case Array with additional
        # values.
        class List < DelegateClass(::Array)
          # @private
          # The gRPC Service object.
          attr_accessor :service

          # @private
          # Instance id
          attr_accessor :instance_id

          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          # Locations from which Cluster information could not be retrieved,
          # due to an outage or some other transient condition.
          # Clusters from these locations may be missing from `clusters`,
          # or may only have partial information returned.
          attr_accessor :failed_locations

          # @private
          # Create a new Cluster::List with an array of
          # Cluster instances.
          def initialize arr = []
            super(arr)
          end

          # Whether there is a next page of instances.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   clusters = bigtable.clusters("instance-id")
          #   if clusters.next?
          #     next_clusters = clusters.next
          #   end
          def next?
            !token.nil?
          end

          # Retrieve the next page of clusters.
          #
          # @return [Cluster::List] The list of clusters.
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   clusters = bigtable.clusters("instance-id")
          #   if instances.next?
          #     next_clusters = clusters.next
          #   end
          def next
            return nil unless next?
            ensure_service!
            grpc = service.list_clusters(instance_id, token: token)
            next_list = self.class.from_grpc(
              grpc,
              service,
              instance_id: instance_id
            )
            if failed_locations
              next_list.failed_locations.concat(failed_locations.map(&:to_s))
            end
            next_list
          end

          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @yield [cluster] The block for accessing each cluster.
          # @yieldparam [Cluster] cluster The cluster object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each cluster by passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   bigtable.clusters("instance-id").all do |cluster|
          #     puts cluster.cluster_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/bigtable"
          #
          #   bigtable = Google::Cloud::Bigtable.new
          #
          #   all_cluster_ids = bigtable.clusters("instance-id").all.map do |cluster|
          #     puts cluster.instance_id
          #   end
          #
          def all
            return enum_for(:all) unless block_given?

            results = self
            loop do
              results.each { |r| yield r }
              break unless results.next?
              results = results.next
            end
          end

          # @private
          #
          # New Cluster::List from a Google::Bigtable::Admin::V2::ListClustersResponse object.
          def self.from_grpc grpc, service, instance_id: nil
            clusters = List.new(Array(grpc.clusters).map do |cluster|
              Cluster.from_grpc(cluster, service)
            end)
            token = grpc.next_page_token
            token = nil if token == ""
            clusters.token = token
            clusters.instance_id = instance_id
            clusters.service = service
            clusters.failed_locations = grpc.failed_locations.map(&:to_s)
            clusters
          end

          protected

          # @private
          #
          # Raise an error unless an active service is available.
          def ensure_service!
            raise "Must have active connection" unless service
          end
        end
      end
    end
  end
end
