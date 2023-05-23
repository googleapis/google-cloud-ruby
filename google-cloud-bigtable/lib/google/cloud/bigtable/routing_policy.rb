# Copyright 2019 Google LLC
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
    module Bigtable
      ##
      # # RoutingPolicy
      #
      # An abstract routing policy.
      #
      # See subclasses for concrete implementations:
      # * {Google::Cloud::Bigtable::MultiClusterRoutingUseAny} - Read/write
      #   requests may be routed to any cluster in the instance and will
      #   fail over to another cluster in the event of transient errors or
      #   delays. Choosing this option sacrifices read-your-writes
      #   consistency to improve availability.
      # * {Google::Cloud::Bigtable::SingleClusterRouting} - Unconditionally
      #   routes all read/write requests to a specific cluster. This option
      #   preserves read-your-writes consistency but does not improve
      #   availability. Value contains `cluster_id` and optional field
      #   `allow_transactional_writes`.
      #
      # @example Create an app profile with a single cluster routing policy.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #
      #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      #     "my-cluster",
      #     allow_transactional_writes: true
      #   )
      #
      #   app_profile = instance.create_app_profile(
      #     "my-app-profile",
      #     routing_policy,
      #     description: "App profile for user data instance"
      #   )
      #   puts app_profile.routing_policy
      #
      # @example Create an app profile with multi-cluster routing policy.
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #
      #   routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
      #
      #   app_profile = instance.create_app_profile(
      #     "my-app-profile",
      #     routing_policy,
      #     description: "App profile for user data instance"
      #   )
      #   puts app_profile.routing_policy
      #
      class RoutingPolicy
      end

      ##
      # A multi-cluster routing policy for all read/write requests that use the
      # associated app profile.
      #
      # Read/write requests may be routed to any cluster in the instance, and will
      # fail over to another cluster in the event of transient errors or delays.
      # Choosing this option sacrifices read-your-writes consistency to improve
      # availability.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #
      #   routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
      #
      #   app_profile = instance.create_app_profile(
      #     "my-app-profile",
      #     routing_policy,
      #     description: "App profile for user data instance"
      #   )
      #   puts app_profile.routing_policy
      #
      class MultiClusterRoutingUseAny < RoutingPolicy
        # @private
        def to_grpc
          Google::Cloud::Bigtable::Admin::V2::AppProfile::MultiClusterRoutingUseAny.new
        end
      end

      ##
      # A single-cluster routing policy for all read/write requests that use the
      # associated app profile.
      #
      # Unconditionally routes all read/write requests to a specific cluster.
      # This option preserves read-your-writes consistency, but does not improve
      # availability.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #
      #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
      #     "my-cluster",
      #     allow_transactional_writes: true
      #   )
      #
      #   app_profile = instance.create_app_profile(
      #     "my-app-profile",
      #     routing_policy,
      #     description: "App profile for user data instance"
      #   )
      #   puts app_profile.routing_policy
      #
      # @!attribute [rw] cluster_id
      #   @return [String]
      #     The cluster to which read/write requests should be routed.
      # @!attribute [rw] allow_transactional_writes
      #   @return [true, false]
      #     If true, `CheckAndMutateRow` and `ReadModifyWriteRow` requests are
      #     allowed by this app profile. It is unsafe to send these requests to
      #     the same table/row/column in multiple clusters.
      #     Default value is false.
      #
      class SingleClusterRouting < RoutingPolicy
        attr_reader :cluster_id
        attr_reader :allow_transactional_writes

        ##
        # Creates a new single-cluster routing policy.
        #
        # @param cluster_id [String] The cluster to which read/write requests
        #   should be routed.
        # @param allow_transactional_writes [Boolean]
        #   If true, `CheckAndMutateRow` and `ReadModifyWriteRow` requests are
        #   allowed by this app profile. It is unsafe to send these requests to
        #   the same table/row/column in multiple clusters.
        #   Default value is false.
        #
        def initialize cluster_id, allow_transactional_writes
          super()
          @cluster_id = cluster_id
          @allow_transactional_writes = allow_transactional_writes
        end

        # @private
        def to_grpc
          Google::Cloud::Bigtable::Admin::V2::AppProfile::SingleClusterRouting.new(
            cluster_id:                 cluster_id,
            allow_transactional_writes: allow_transactional_writes
          )
        end
      end
    end
  end
end
