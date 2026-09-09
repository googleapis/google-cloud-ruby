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


require "google/cloud/bigtable/app_profile/list"
require "google/cloud/bigtable/app_profile/job"
require "google/cloud/bigtable/routing_policy"

module Google
  module Cloud
    module Bigtable
      ##
      # # AppProfile
      #
      # A configuration object describing how Cloud Bigtable should treat traffic
      # from a particular end user application.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance "my-instance"
      #
      #   app_profile = instance.app_profile "my-app-profile"
      #
      #   # Update
      #   app_profile.description = "User data instance app profile"
      #   app_profile.routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
      #   job = app_profile.save
      #   job.wait_until_done!
      #
      #   # Delete
      #   app_profile.delete
      #
      class AppProfile
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        #
        # Creates a new AppProfile instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
          @changed_fields = {}
        end

        ##
        # The unique identifier for the project to which the app profile belongs.
        #
        # @return [String]
        #
        def project_id
          @grpc.name.split("/")[1]
        end

        ##
        # The unique identifier for the instance to which the app profile belongs.
        #
        # @return [String]
        #
        def instance_id
          @grpc.name.split("/")[3]
        end

        ##
        # The unique identifier for the app profile.
        #
        # @return [String]
        #
        def name
          @grpc.name.split("/")[5]
        end

        ##
        # The full path for the app profile resource. Values are of the form:
        # `projects/<project_id>/instances/<instance_id>/appProfiles/<app_profile_name>`.
        #
        # @return [String]
        #
        def path
          @grpc.name
        end

        ##
        # Etag for optimistic concurrency control.
        #
        # @return [String]
        #
        def etag
          @grpc.etag
        end

        ##
        # Description of the app profile.
        #
        # @return [String]
        #
        def description
          @grpc.description
        end

        ##
        # Sets the description of the app profile.
        #
        # @param text [String] Description text
        #
        def description= text
          @grpc.description = text
          @changed_fields["description"] = "description"
        end

        ##
        # Gets the multi-cluster routing policy, if present.
        #
        # @return [Google::Cloud::Bigtable::MultiClusterRoutingUseAny, nil]
        #
        def multi_cluster_routing
          return nil unless @grpc.multi_cluster_routing_use_any

          Google::Cloud::Bigtable::MultiClusterRoutingUseAny.new
        end

        ##
        # Gets the single cluster routing policy, if present.
        #
        # @return [Google::Cloud::Bigtable::SingleClusterRouting, nil]
        #
        def single_cluster_routing
          return nil unless @grpc.single_cluster_routing

          Google::Cloud::Bigtable::SingleClusterRouting.new(
            @grpc.single_cluster_routing.cluster_id,
            @grpc.single_cluster_routing.allow_transactional_writes
          )
        end

        ##
        # Sets the routing policy for the app profile.
        #
        # @param policy [Google::Cloud::Bigtable::RoutingPolicy]
        #   The routing policy for all read/write requests that use this app profile. A value must be explicitly set.
        #
        #   Routing Policies:
        #   * {Google::Cloud::Bigtable::MultiClusterRoutingUseAny} - Read/write
        #     requests may be routed to any cluster in the instance and will
        #     fail over to another cluster in the event of transient errors or
        #     delays. Choosing this option sacrifices read-your-writes
        #     consistency to improve availability.
        #   * {Google::Cloud::Bigtable::SingleClusterRouting} - Unconditionally
        #     routes all read/write requests to a specific cluster. This option
        #     preserves read-your-writes consistency but does not improve
        #     availability. Value contains `cluster_id` and optional field
        #     `allow_transactional_writes`.
        #
        # @example Set multi cluster routing policy.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
        #   app_profile.routing_policy = routing_policy
        #
        # @example Set single cluster routing policy.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #   instance = bigtable.instance "my-instance"
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
        #     "my-cluster",
        #     allow_transactional_writes: true
        #   )
        #   app_profile.routing_policy = routing_policy
        #
        def routing_policy= policy
          routing_policy_grpc = policy.to_grpc
          if routing_policy_grpc.is_a? Google::Cloud::Bigtable::Admin::V2::AppProfile::SingleClusterRouting
            @grpc.single_cluster_routing = routing_policy_grpc
            @changed_fields["routing_policy"] = "single_cluster_routing"
          else
            @grpc.multi_cluster_routing_use_any = routing_policy_grpc
            @changed_fields["routing_policy"] = "multi_cluster_routing_use_any"
          end
        end

        ##
        # Gets the routing policy for all read/write requests that use the app
        # profile.
        #
        # Routing Policies:
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
        # @return [Google::Cloud::Bigtable::RoutingPolicy]
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
        def routing_policy
          single_cluster_routing || multi_cluster_routing
        end

        ##
        # Deletes the app profile.
        #
        # @param ignore_warnings [Boolean]
        #   Default value is false. If true, ignore safety checks when deleting
        #   the app profile.
        # @return [Boolean] Returns `true` if the app profile was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   app_profile.delete ignore_warnings: true # Ignore warnings.
        #
        #   # OR : Not ignoring warnings
        #   app_profile.delete
        #
        def delete ignore_warnings: false
          ensure_service!
          service.delete_app_profile instance_id, name, ignore_warnings: ignore_warnings
          true
        end

        ##
        # Updates the app profile.
        #
        # @param ignore_warnings [Boolean]
        #   Default value is false. If true, ignore safety checks when updating
        #   the app profile.
        # @return [Google::Cloud::Bigtable::AppProfile::Job]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   app_profile.description = "User data instance app profile"
        #   app_profile.routing_policy = Google::Cloud::Bigtable::AppProfile.multi_cluster_routing
        #
        #   job = app_profile.save
        #   job.wait_until_done!
        #   if job.error?
        #     puts job.error
        #   else
        #     puts "App profile successfully updated."
        #     app_profile = job.app_profile
        #   end
        #
        # @example Update with single cluster routing.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance "my-instance"
        #   app_profile = instance.app_profile "my-app-profile"
        #
        #   app_profile.description = "User data instance app profile"
        #   routing_policy = Google::Cloud::Bigtable::AppProfile.single_cluster_routing(
        #     "my-cluster",
        #     allow_transactional_writes: true
        #   )
        #   app_profile.routing_policy = routing_policy
        #
        #   job = app_profile.save
        #
        #   job.done? #=> false
        #   job.reload!
        #   job.done? #=> true
        #
        #   if job.error?
        #     puts job.error
        #   else
        #     app_profile = job.app_profile
        #     puts app_profile.name
        #   end
        #
        def save ignore_warnings: false
          ensure_service!
          update_mask = Google::Protobuf::FieldMask.new paths: @changed_fields.values
          grpc = service.update_app_profile @grpc, update_mask, ignore_warnings: ignore_warnings
          @changed_fields.clear
          AppProfile::Job.from_grpc grpc, service
        end
        alias update save

        ##
        # Reloads the app profile data.
        #
        # @return [Google::Cloud::Bigtable::AppProfile]
        #
        def reload!
          @grpc = service.get_app_profile instance_id, name
          self
        end

        ##
        # Creates an instance of the multi cluster routing policy.
        #
        # Read/write requests may be routed to any cluster in the instance and
        # will fail over to another cluster in the event of transient errors or
        # delays. Choosing this option sacrifices read-your-writes consistency
        # to improve availability.
        #
        # @return [Google::Cloud::Bigtable::MultiClusterRoutingUseAny]
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
        def self.multi_cluster_routing
          Google::Cloud::Bigtable::MultiClusterRoutingUseAny.new
        end

        ##
        # Creates an instance of the single cluster routing policy.
        #
        # Unconditionally routes all read/write requests to a specific cluster.
        # This option preserves read-your-writes consistency but does not
        # improve availability.
        #
        # @param cluster_id [String]
        #   The cluster to which read/write requests should be routed.
        # @param allow_transactional_writes [Boolean]
        #   If true, `CheckAndMutateRow` and `ReadModifyWriteRow` requests are
        #   allowed by this app profile. It is unsafe to send these requests to
        #   the same table/row/column in multiple clusters.
        #   Default value is false.
        # @return [Google::Cloud::Bigtable::SingleClusterRouting]
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
        def self.single_cluster_routing cluster_id, allow_transactional_writes: false
          Google::Cloud::Bigtable::SingleClusterRouting.new cluster_id, allow_transactional_writes
        end

        # @private
        #
        # Creates a new Instance instance from a
        # Google::Cloud::Bigtable::Admin::V2::Table.
        # @param grpc [Google::Cloud::Bigtable::Admin::V2::Table]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Table]
        def self.from_grpc grpc, service
          new grpc, service
        end

        protected

        # @private
        # Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
