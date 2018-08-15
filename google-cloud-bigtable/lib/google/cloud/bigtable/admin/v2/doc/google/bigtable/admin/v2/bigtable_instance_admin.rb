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
  module Bigtable
    module Admin
      module V2
        # Request message for BigtableInstanceAdmin.CreateInstance.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the project in which to create the new instance.
        #     Values are of the form +projects/<project>+.
        # @!attribute [rw] instance_id
        #   @return [String]
        #     The ID to be used when referring to the new instance within its project,
        #     e.g., just +myinstance+ rather than
        #     +projects/myproject/instances/myinstance+.
        # @!attribute [rw] instance
        #   @return [Google::Bigtable::Admin::V2::Instance]
        #     The instance to create.
        #     Fields marked +OutputOnly+ must be left blank.
        # @!attribute [rw] clusters
        #   @return [Hash{String => Google::Bigtable::Admin::V2::Cluster}]
        #     The clusters to be created within the instance, mapped by desired
        #     cluster ID, e.g., just +mycluster+ rather than
        #     +projects/myproject/instances/myinstance/clusters/mycluster+.
        #     Fields marked +OutputOnly+ must be left blank.
        #     Currently exactly one cluster must be specified.
        class CreateInstanceRequest; end

        # Request message for BigtableInstanceAdmin.GetInstance.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the requested instance. Values are of the form
        #     +projects/<project>/instances/<instance>+.
        class GetInstanceRequest; end

        # Request message for BigtableInstanceAdmin.ListInstances.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the project for which a list of instances is requested.
        #     Values are of the form +projects/<project>+.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value of +next_page_token+ returned by a previous call.
        class ListInstancesRequest; end

        # Response message for BigtableInstanceAdmin.ListInstances.
        # @!attribute [rw] instances
        #   @return [Array<Google::Bigtable::Admin::V2::Instance>]
        #     The list of requested instances.
        # @!attribute [rw] failed_locations
        #   @return [Array<String>]
        #     Locations from which Instance information could not be retrieved,
        #     due to an outage or some other transient condition.
        #     Instances whose Clusters are all in one of the failed locations
        #     may be missing from +instances+, and Instances with at least one
        #     Cluster in a failed location may only have partial information returned.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Set if not all instances could be returned in a single response.
        #     Pass this value to +page_token+ in another request to get the next
        #     page of results.
        class ListInstancesResponse; end

        # Request message for BigtableInstanceAdmin.PartialUpdateInstance.
        # @!attribute [rw] instance
        #   @return [Google::Bigtable::Admin::V2::Instance]
        #     The Instance which will (partially) replace the current value.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     The subset of Instance fields which should be replaced.
        #     Must be explicitly set.
        class PartialUpdateInstanceRequest; end

        # Request message for BigtableInstanceAdmin.DeleteInstance.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the instance to be deleted.
        #     Values are of the form +projects/<project>/instances/<instance>+.
        class DeleteInstanceRequest; end

        # Request message for BigtableInstanceAdmin.CreateCluster.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance in which to create the new cluster.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>+.
        # @!attribute [rw] cluster_id
        #   @return [String]
        #     The ID to be used when referring to the new cluster within its instance,
        #     e.g., just +mycluster+ rather than
        #     +projects/myproject/instances/myinstance/clusters/mycluster+.
        # @!attribute [rw] cluster
        #   @return [Google::Bigtable::Admin::V2::Cluster]
        #     The cluster to be created.
        #     Fields marked +OutputOnly+ must be left blank.
        class CreateClusterRequest; end

        # Request message for BigtableInstanceAdmin.GetCluster.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the requested cluster. Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>+.
        class GetClusterRequest; end

        # Request message for BigtableInstanceAdmin.ListClusters.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance for which a list of clusters is requested.
        #     Values are of the form +projects/<project>/instances/<instance>+.
        #     Use +<instance> = '-'+ to list Clusters for all Instances in a project,
        #     e.g., +projects/myproject/instances/-+.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value of +next_page_token+ returned by a previous call.
        class ListClustersRequest; end

        # Response message for BigtableInstanceAdmin.ListClusters.
        # @!attribute [rw] clusters
        #   @return [Array<Google::Bigtable::Admin::V2::Cluster>]
        #     The list of requested clusters.
        # @!attribute [rw] failed_locations
        #   @return [Array<String>]
        #     Locations from which Cluster information could not be retrieved,
        #     due to an outage or some other transient condition.
        #     Clusters from these locations may be missing from +clusters+,
        #     or may only have partial information returned.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Set if not all clusters could be returned in a single response.
        #     Pass this value to +page_token+ in another request to get the next
        #     page of results.
        class ListClustersResponse; end

        # Request message for BigtableInstanceAdmin.DeleteCluster.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the cluster to be deleted. Values are of the form
        #     +projects/<project>/instances/<instance>/clusters/<cluster>+.
        class DeleteClusterRequest; end

        # The metadata for the Operation returned by CreateInstance.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::CreateInstanceRequest]
        #     The request that prompted the initiation of this CreateInstance operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class CreateInstanceMetadata; end

        # The metadata for the Operation returned by UpdateInstance.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::PartialUpdateInstanceRequest]
        #     The request that prompted the initiation of this UpdateInstance operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class UpdateInstanceMetadata; end

        # The metadata for the Operation returned by CreateCluster.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::CreateClusterRequest]
        #     The request that prompted the initiation of this CreateCluster operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class CreateClusterMetadata; end

        # The metadata for the Operation returned by UpdateCluster.
        # @!attribute [rw] original_request
        #   @return [Google::Bigtable::Admin::V2::Cluster]
        #     The request that prompted the initiation of this UpdateCluster operation.
        # @!attribute [rw] request_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the original request was received.
        # @!attribute [rw] finish_time
        #   @return [Google::Protobuf::Timestamp]
        #     The time at which the operation failed or was completed successfully.
        class UpdateClusterMetadata; end

        # Request message for BigtableInstanceAdmin.CreateAppProfile.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance in which to create the new app profile.
        #     Values are of the form
        #     +projects/<project>/instances/<instance>+.
        # @!attribute [rw] app_profile_id
        #   @return [String]
        #     The ID to be used when referring to the new app profile within its
        #     instance, e.g., just +myprofile+ rather than
        #     +projects/myproject/instances/myinstance/appProfiles/myprofile+.
        # @!attribute [rw] app_profile
        #   @return [Google::Bigtable::Admin::V2::AppProfile]
        #     The app profile to be created.
        #     Fields marked +OutputOnly+ will be ignored.
        # @!attribute [rw] ignore_warnings
        #   @return [true, false]
        #     If true, ignore safety checks when creating the app profile.
        class CreateAppProfileRequest; end

        # Request message for BigtableInstanceAdmin.GetAppProfile.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the requested app profile. Values are of the form
        #     +projects/<project>/instances/<instance>/appProfiles/<app_profile>+.
        class GetAppProfileRequest; end

        # Request message for BigtableInstanceAdmin.ListAppProfiles.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique name of the instance for which a list of app profiles is
        #     requested. Values are of the form
        #     +projects/<project>/instances/<instance>+.
        # @!attribute [rw] page_token
        #   @return [String]
        #     The value of +next_page_token+ returned by a previous call.
        class ListAppProfilesRequest; end

        # Response message for BigtableInstanceAdmin.ListAppProfiles.
        # @!attribute [rw] app_profiles
        #   @return [Array<Google::Bigtable::Admin::V2::AppProfile>]
        #     The list of requested app profiles.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Set if not all app profiles could be returned in a single response.
        #     Pass this value to +page_token+ in another request to get the next
        #     page of results.
        class ListAppProfilesResponse; end

        # Request message for BigtableInstanceAdmin.UpdateAppProfile.
        # @!attribute [rw] app_profile
        #   @return [Google::Bigtable::Admin::V2::AppProfile]
        #     The app profile which will (partially) replace the current value.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     The subset of app profile fields which should be replaced.
        #     If unset, all fields will be replaced.
        # @!attribute [rw] ignore_warnings
        #   @return [true, false]
        #     If true, ignore safety checks when updating the app profile.
        class UpdateAppProfileRequest; end

        # Request message for BigtableInstanceAdmin.DeleteAppProfile.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique name of the app profile to be deleted. Values are of the form
        #     +projects/<project>/instances/<instance>/appProfiles/<app_profile>+.
        # @!attribute [rw] ignore_warnings
        #   @return [true, false]
        #     If true, ignore safety checks when deleting the app profile.
        class DeleteAppProfileRequest; end

        # The metadata for the Operation returned by UpdateAppProfile.
        class UpdateAppProfileMetadata; end
      end
    end
  end
end