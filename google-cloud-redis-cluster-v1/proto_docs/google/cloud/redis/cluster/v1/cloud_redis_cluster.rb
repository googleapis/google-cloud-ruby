# frozen_string_literal: true

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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module Redis
      module Cluster
        module V1
          # Request for [CreateCluster][CloudRedis.CreateCluster].
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. The resource name of the cluster location using the form:
          #         `projects/{project_id}/locations/{location_id}`
          #     where `location_id` refers to a GCP region.
          # @!attribute [rw] cluster_id
          #   @return [::String]
          #     Required. The logical name of the Redis cluster in the customer project
          #     with the following restrictions:
          #
          #     * Must contain only lowercase letters, numbers, and hyphens.
          #     * Must start with a letter.
          #     * Must be between 1-63 characters.
          #     * Must end with a number or a letter.
          #     * Must be unique within the customer project / location
          # @!attribute [rw] cluster
          #   @return [::Google::Cloud::Redis::Cluster::V1::Cluster]
          #     Required. The cluster that is to be created.
          # @!attribute [rw] request_id
          #   @return [::String]
          #     Idempotent request UUID.
          class CreateClusterRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for [ListClusters][CloudRedis.ListClusters].
          # @!attribute [rw] parent
          #   @return [::String]
          #     Required. The resource name of the cluster location using the form:
          #         `projects/{project_id}/locations/{location_id}`
          #     where `location_id` refers to a GCP region.
          # @!attribute [rw] page_size
          #   @return [::Integer]
          #     The maximum number of items to return.
          #
          #     If not specified, a default value of 1000 will be used by the service.
          #     Regardless of the page_size value, the response may include a partial list
          #     and a caller should only rely on response's
          #     {::Google::Cloud::Redis::Cluster::V1::ListClustersResponse#next_page_token `next_page_token`}
          #     to determine if there are more clusters left to be queried.
          # @!attribute [rw] page_token
          #   @return [::String]
          #     The `next_page_token` value returned from a previous
          #     [ListClusters][CloudRedis.ListClusters] request, if any.
          class ListClustersRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Response for [ListClusters][CloudRedis.ListClusters].
          # @!attribute [rw] clusters
          #   @return [::Array<::Google::Cloud::Redis::Cluster::V1::Cluster>]
          #     A list of Redis clusters in the project in the specified location,
          #     or across all locations.
          #
          #     If the `location_id` in the parent field of the request is "-", all regions
          #     available to the project are queried, and the results aggregated.
          #     If in such an aggregated query a location is unavailable, a placeholder
          #     Redis entry is included in the response with the `name` field set to a
          #     value of the form
          #     `projects/{project_id}/locations/{location_id}/clusters/`- and the
          #     `status` field set to ERROR and `status_message` field set to "location not
          #     available for ListClusters".
          # @!attribute [rw] next_page_token
          #   @return [::String]
          #     Token to retrieve the next page of results, or empty if there are no more
          #     results in the list.
          # @!attribute [rw] unreachable
          #   @return [::Array<::String>]
          #     Locations that could not be reached.
          class ListClustersResponse
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for [UpdateCluster][CloudRedis.UpdateCluster].
          # @!attribute [rw] update_mask
          #   @return [::Google::Protobuf::FieldMask]
          #     Required. Mask of fields to update. At least one path must be supplied in
          #     this field. The elements of the repeated paths field may only include these
          #     fields from {::Google::Cloud::Redis::Cluster::V1::Cluster Cluster}:
          #
          #      *   `size_gb`
          #      *   `replica_count`
          # @!attribute [rw] cluster
          #   @return [::Google::Cloud::Redis::Cluster::V1::Cluster]
          #     Required. Update description.
          #     Only fields specified in update_mask are updated.
          # @!attribute [rw] request_id
          #   @return [::String]
          #     Idempotent request UUID.
          class UpdateClusterRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for [GetCluster][CloudRedis.GetCluster].
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Redis cluster resource name using the form:
          #         `projects/{project_id}/locations/{location_id}/clusters/{cluster_id}`
          #     where `location_id` refers to a GCP region.
          class GetClusterRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request for [DeleteCluster][CloudRedis.DeleteCluster].
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Redis cluster resource name using the form:
          #         `projects/{project_id}/locations/{location_id}/clusters/{cluster_id}`
          #     where `location_id` refers to a GCP region.
          # @!attribute [rw] request_id
          #   @return [::String]
          #     Idempotent request UUID.
          class DeleteClusterRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # A cluster instance.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. Unique name of the resource in this scope including project and
          #     location using the form:
          #         `projects/{project_id}/locations/{location_id}/clusters/{cluster_id}`
          # @!attribute [r] create_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. The timestamp associated with the cluster creation request.
          # @!attribute [r] state
          #   @return [::Google::Cloud::Redis::Cluster::V1::Cluster::State]
          #     Output only. The current state of this cluster.
          #     Can be CREATING, READY, UPDATING, DELETING and SUSPENDED
          # @!attribute [r] uid
          #   @return [::String]
          #     Output only. System assigned, unique identifier for the cluster.
          # @!attribute [rw] replica_count
          #   @return [::Integer]
          #     Optional. The number of replica nodes per shard.
          # @!attribute [rw] authorization_mode
          #   @return [::Google::Cloud::Redis::Cluster::V1::AuthorizationMode]
          #     Optional. The authorization mode of the Redis cluster.
          #     If not provided, auth feature is disabled for the cluster.
          # @!attribute [rw] transit_encryption_mode
          #   @return [::Google::Cloud::Redis::Cluster::V1::TransitEncryptionMode]
          #     Optional. The in-transit encryption for the Redis cluster.
          #     If not provided, encryption  is disabled for the cluster.
          # @!attribute [r] size_gb
          #   @return [::Integer]
          #     Output only. Redis memory size in GB for the entire cluster.
          # @!attribute [rw] shard_count
          #   @return [::Integer]
          #     Required. Number of shards for the Redis cluster.
          # @!attribute [rw] psc_configs
          #   @return [::Array<::Google::Cloud::Redis::Cluster::V1::PscConfig>]
          #     Required. Each PscConfig configures the consumer network where IPs will
          #     be designated to the cluster for client access through Private Service
          #     Connect Automation. Currently, only one PscConfig is supported.
          # @!attribute [r] discovery_endpoints
          #   @return [::Array<::Google::Cloud::Redis::Cluster::V1::DiscoveryEndpoint>]
          #     Output only. Endpoints created on each given network, for Redis clients to
          #     connect to the cluster. Currently only one discovery endpoint is supported.
          # @!attribute [r] psc_connections
          #   @return [::Array<::Google::Cloud::Redis::Cluster::V1::PscConnection>]
          #     Output only. PSC connections for discovery of the cluster topology and
          #     accessing the cluster.
          # @!attribute [r] state_info
          #   @return [::Google::Cloud::Redis::Cluster::V1::Cluster::StateInfo]
          #     Output only. Additional information about the current state of the cluster.
          class Cluster
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Represents additional information about the state of the cluster.
            # @!attribute [rw] update_info
            #   @return [::Google::Cloud::Redis::Cluster::V1::Cluster::StateInfo::UpdateInfo]
            #     Describes ongoing update on the cluster when cluster state is UPDATING.
            class StateInfo
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Represents information about an updating cluster.
              # @!attribute [rw] target_shard_count
              #   @return [::Integer]
              #     Target number of shards for redis cluster
              # @!attribute [rw] target_replica_count
              #   @return [::Integer]
              #     Target number of replica nodes per shard.
              class UpdateInfo
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end
            end

            # Represents the different states of a Redis cluster.
            module State
              # Not set.
              STATE_UNSPECIFIED = 0

              # Redis cluster is being created.
              CREATING = 1

              # Redis cluster has been created and is fully usable.
              ACTIVE = 2

              # Redis cluster configuration is being updated.
              UPDATING = 3

              # Redis cluster is being deleted.
              DELETING = 4
            end
          end

          # @!attribute [rw] network
          #   @return [::String]
          #     Required. The network where the IP address of the discovery endpoint will
          #     be reserved, in the form of
          #     projects/\\{network_project}/global/networks/\\{network_id}.
          class PscConfig
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Endpoints on each network, for Redis clients to connect to the cluster.
          # @!attribute [r] address
          #   @return [::String]
          #     Output only. Address of the exposed Redis endpoint used by clients to
          #     connect to the service. The address could be either IP or hostname.
          # @!attribute [r] port
          #   @return [::Integer]
          #     Output only. The port number of the exposed Redis endpoint.
          # @!attribute [r] psc_config
          #   @return [::Google::Cloud::Redis::Cluster::V1::PscConfig]
          #     Output only. Customer configuration for where the endpoint is created and
          #     accessed from.
          class DiscoveryEndpoint
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Details of consumer resources in a PSC connection.
          # @!attribute [r] psc_connection_id
          #   @return [::String]
          #     Output only. The PSC connection id of the forwarding rule connected to the
          #     service attachment.
          # @!attribute [r] address
          #   @return [::String]
          #     Output only. The IP allocated on the consumer network for the PSC
          #     forwarding rule.
          # @!attribute [r] forwarding_rule
          #   @return [::String]
          #     Output only. The URI of the consumer side forwarding rule.
          #     Example:
          #     projects/\\{projectNumOrId}/regions/us-east1/forwardingRules/\\{resourceId}.
          # @!attribute [r] project_id
          #   @return [::String]
          #     Output only. The consumer project_id where the forwarding rule is created
          #     from.
          # @!attribute [rw] network
          #   @return [::String]
          #     The consumer network where the IP address resides, in the form of
          #     projects/\\{project_id}/global/networks/\\{network_id}.
          class PscConnection
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Pre-defined metadata fields.
          # @!attribute [r] create_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. The time the operation was created.
          # @!attribute [r] end_time
          #   @return [::Google::Protobuf::Timestamp]
          #     Output only. The time the operation finished running.
          # @!attribute [r] target
          #   @return [::String]
          #     Output only. Server-defined resource path for the target of the operation.
          # @!attribute [r] verb
          #   @return [::String]
          #     Output only. Name of the verb executed by the operation.
          # @!attribute [r] status_message
          #   @return [::String]
          #     Output only. Human-readable status of the operation, if any.
          # @!attribute [r] requested_cancellation
          #   @return [::Boolean]
          #     Output only. Identifies whether the user has requested cancellation
          #     of the operation. Operations that have successfully been cancelled
          #     have [Operation.error][] value with a
          #     {::Google::Rpc::Status#code google.rpc.Status.code} of 1, corresponding to
          #     `Code.CANCELLED`.
          # @!attribute [r] api_version
          #   @return [::String]
          #     Output only. API version used to start the operation.
          class OperationMetadata
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Available authorization mode of a Redis cluster.
          module AuthorizationMode
            # Not set.
            AUTH_MODE_UNSPECIFIED = 0

            # IAM basic authorization mode
            AUTH_MODE_IAM_AUTH = 1

            # Authorization disabled mode
            AUTH_MODE_DISABLED = 2
          end

          # Available mode of in-transit encryption.
          module TransitEncryptionMode
            # In-transit encryption not set.
            TRANSIT_ENCRYPTION_MODE_UNSPECIFIED = 0

            # In-transit encryption disabled.
            TRANSIT_ENCRYPTION_MODE_DISABLED = 1

            # Use server managed encryption for in-transit encryption.
            TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION = 2
          end
        end
      end
    end
  end
end
