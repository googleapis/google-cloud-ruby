# frozen_string_literal: true

# Copyright 2024 Google LLC
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
    module OracleDatabase
      module V1
        # The request for `CloudExadataInfrastructures.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for CloudExadataInfrastructure in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 Exadata infrastructures will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListCloudExadataInfrastructuresRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `CloudExadataInfrastructures.list`.
        # @!attribute [rw] cloud_exadata_infrastructures
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::CloudExadataInfrastructure>]
        #     The list of Exadata Infrastructures.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token for fetching next page of response.
        class ListCloudExadataInfrastructuresResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudExadataInfrastructure.Get`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Cloud Exadata Infrastructure in the following
        #     format:
        #     projects/\\{project}/locations/\\{location}/cloudExadataInfrastructures/\\{cloud_exadata_infrastructure}.
        class GetCloudExadataInfrastructureRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudExadataInfrastructure.Create`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for CloudExadataInfrastructure in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] cloud_exadata_infrastructure_id
        #   @return [::String]
        #     Required. The ID of the Exadata Infrastructure to create. This value is
        #     restricted to (^[a-z]([a-z0-9-]\\{0,61}[a-z0-9])?$) and must be a maximum of
        #     63 characters in length. The value must start with a letter and end with a
        #     letter or a number.
        # @!attribute [rw] cloud_exadata_infrastructure
        #   @return [::Google::Cloud::OracleDatabase::V1::CloudExadataInfrastructure]
        #     Required. Details of the Exadata Infrastructure instance to create.
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        class CreateCloudExadataInfrastructureRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudExadataInfrastructure.Delete`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Cloud Exadata Infrastructure in the following
        #     format:
        #     projects/\\{project}/locations/\\{location}/cloudExadataInfrastructures/\\{cloud_exadata_infrastructure}.
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        # @!attribute [rw] force
        #   @return [::Boolean]
        #     Optional. If set to true, all VM clusters for this Exadata Infrastructure
        #     will be deleted. An Exadata Infrastructure can only be deleted once all its
        #     VM clusters have been deleted.
        class DeleteCloudExadataInfrastructureRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudVmCluster.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The name of the parent in the following format:
        #     projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The number of VM clusters to return.
        #     If unspecified, at most 50 VM clusters will be returned.
        #     The maximum value is 1,000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying the page of results the server returns.
        # @!attribute [rw] filter
        #   @return [::String]
        #     Optional. An expression for filtering the results of the request.
        class ListCloudVmClustersRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `CloudVmCluster.List`.
        # @!attribute [rw] cloud_vm_clusters
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::CloudVmCluster>]
        #     The list of VM Clusters.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token to fetch the next page of results.
        class ListCloudVmClustersResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudVmCluster.Get`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Cloud VM Cluster in the following format:
        #     projects/\\{project}/locations/\\{location}/cloudVmClusters/\\{cloud_vm_cluster}.
        class GetCloudVmClusterRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudVmCluster.Create`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The name of the parent in the following format:
        #     projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] cloud_vm_cluster_id
        #   @return [::String]
        #     Required. The ID of the VM Cluster to create. This value is restricted
        #     to (^[a-z]([a-z0-9-]\\{0,61}[a-z0-9])?$) and must be a maximum of 63
        #     characters in length. The value must start with a letter and end with
        #     a letter or a number.
        # @!attribute [rw] cloud_vm_cluster
        #   @return [::Google::Cloud::OracleDatabase::V1::CloudVmCluster]
        #     Required. The resource being created
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        class CreateCloudVmClusterRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `CloudVmCluster.Delete`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Cloud VM Cluster in the following format:
        #     projects/\\{project}/locations/\\{location}/cloudVmClusters/\\{cloud_vm_cluster}.
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        # @!attribute [rw] force
        #   @return [::Boolean]
        #     Optional. If set to true, all child resources for the VM Cluster will be
        #     deleted. A VM Cluster can only be deleted once all its child resources have
        #     been deleted.
        class DeleteCloudVmClusterRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `Entitlement.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for the entitlement in the following format:
        #     projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, a maximum of 50 entitlements will be returned.
        #     The maximum value is 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListEntitlementsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `Entitlement.List`.
        # @!attribute [rw] entitlements
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::Entitlement>]
        #     The list of Entitlements
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListEntitlementsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `DbServer.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for database server in the following format:
        #     projects/\\{project}/locations/\\{location}/cloudExadataInfrastructures/\\{cloudExadataInfrastructure}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, a maximum of 50 db servers will be returned.
        #     The maximum value is 1000; values above 1000 will be reset to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListDbServersRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `DbServer.List`.
        # @!attribute [rw] db_servers
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::DbServer>]
        #     The list of database servers.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListDbServersResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `DbNode.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for database node in the following format:
        #     projects/\\{project}/locations/\\{location}/cloudVmClusters/\\{cloudVmCluster}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 db nodes will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the node should return.
        class ListDbNodesRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `DbNode.List`.
        # @!attribute [rw] db_nodes
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::DbNode>]
        #     The list of DB Nodes
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the node should return.
        class ListDbNodesResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `GiVersion.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for Grid Infrastructure Version in the following
        #     format: Format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, a maximum of 50 Oracle Grid Infrastructure (GI) versions
        #     will be returned. The maximum value is 1000; values above 1000 will be
        #     reset to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListGiVersionsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `GiVersion.List`.
        # @!attribute [rw] gi_versions
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::GiVersion>]
        #     The list of Oracle Grid Infrastructure (GI) versions.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListGiVersionsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `DbSystemShape.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for Database System Shapes in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 database system shapes will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListDbSystemShapesRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `DbSystemShape.List`.
        # @!attribute [rw] db_system_shapes
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::DbSystemShape>]
        #     The list of Database System shapes.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListDbSystemShapesResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Represents the metadata of the long-running operation.
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
        #     Output only. The status of the operation.
        # @!attribute [r] requested_cancellation
        #   @return [::Boolean]
        #     Output only. Identifies whether the user has requested cancellation
        #     of the operation. Operations that have been cancelled successfully
        #     have [Operation.error][] value with a
        #     {::Google::Rpc::Status#code google.rpc.Status.code} of 1, corresponding to
        #     `Code.CANCELLED`.
        # @!attribute [r] api_version
        #   @return [::String]
        #     Output only. API version used to start the operation.
        # @!attribute [r] percent_complete
        #   @return [::Float]
        #     Output only. An estimated percentage of the operation that has been
        #     completed at a given moment of time, between 0 and 100.
        class OperationMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for the Autonomous Database in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 Autonomous Database will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        # @!attribute [rw] filter
        #   @return [::String]
        #     Optional. An expression for filtering the results of the request.
        # @!attribute [rw] order_by
        #   @return [::String]
        #     Optional. An expression for ordering the results of the request.
        class ListAutonomousDatabasesRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `AutonomousDatabase.List`.
        # @!attribute [rw] autonomous_databases
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::AutonomousDatabase>]
        #     The list of Autonomous Databases.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListAutonomousDatabasesResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Get`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        class GetAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Create`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The name of the parent in the following format:
        #     projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] autonomous_database_id
        #   @return [::String]
        #     Required. The ID of the Autonomous Database to create. This value is
        #     restricted to (^[a-z]([a-z0-9-]\\{0,61}[a-z0-9])?$) and must be a maximum of
        #     63 characters in length. The value must start with a letter and end with a
        #     letter or a number.
        # @!attribute [rw] autonomous_database
        #   @return [::Google::Cloud::OracleDatabase::V1::AutonomousDatabase]
        #     Required. The Autonomous Database being created.
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        class CreateAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Delete`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the resource in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        # @!attribute [rw] request_id
        #   @return [::String]
        #     Optional. An optional ID to identify the request. This value is used to
        #     identify duplicate requests. If you make a request with the same request ID
        #     and the original request is still in progress or completed, the server
        #     ignores the second request. This prevents clients from
        #     accidentally creating duplicate commitments.
        #
        #     The request ID must be a valid UUID with the exception that zero UUID is
        #     not supported (00000000-0000-0000-0000-000000000000).
        class DeleteAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Restore`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        # @!attribute [rw] restore_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Required. The time and date to restore the database to.
        class RestoreAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Stop`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        class StopAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Start`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        class StartAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.Restart`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        class RestartAutonomousDatabaseRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabase.GenerateWallet`.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The name of the Autonomous Database in the following format:
        #     projects/\\{project}/locations/\\{location}/autonomousDatabases/\\{autonomous_database}.
        # @!attribute [rw] type
        #   @return [::Google::Cloud::OracleDatabase::V1::GenerateType]
        #     Optional. The type of wallet generation for the Autonomous Database. The
        #     default value is SINGLE.
        # @!attribute [rw] is_regional
        #   @return [::Boolean]
        #     Optional. True when requesting regional connection strings in PDB connect
        #     info, applicable to cross-region Data Guard only.
        # @!attribute [rw] password
        #   @return [::String]
        #     Required. The password used to encrypt the keys inside the wallet. The
        #     password must be a minimum of 8 characters.
        class GenerateAutonomousDatabaseWalletRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `AutonomousDatabase.GenerateWallet`.
        # @!attribute [r] archive_content
        #   @return [::String]
        #     Output only. The base64 encoded wallet files.
        class GenerateAutonomousDatabaseWalletResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDbVersion.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for the Autonomous Database in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 Autonomous DB Versions will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListAutonomousDbVersionsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `AutonomousDbVersion.List`.
        # @!attribute [rw] autonomous_db_versions
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::AutonomousDbVersion>]
        #     The list of Autonomous Database versions.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListAutonomousDbVersionsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabaseCharacterSet.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for the Autonomous Database in the following
        #     format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 Autonomous DB Character Sets will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        # @!attribute [rw] filter
        #   @return [::String]
        #     Optional. An expression for filtering the results of the request. Only the
        #     **character_set_type** field is supported in the following format:
        #     `character_set_type="{characterSetType}"`. Accepted values include
        #     `DATABASE` and `NATIONAL`.
        class ListAutonomousDatabaseCharacterSetsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `AutonomousDatabaseCharacterSet.List`.
        # @!attribute [rw] autonomous_database_character_sets
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::AutonomousDatabaseCharacterSet>]
        #     The list of Autonomous Database Character Sets.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListAutonomousDatabaseCharacterSetsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request for `AutonomousDatabaseBackup.List`.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent value for ListAutonomousDatabaseBackups in the
        #     following format: projects/\\{project}/locations/\\{location}.
        # @!attribute [rw] filter
        #   @return [::String]
        #     Optional. An expression for filtering the results of the request. Only the
        #     **autonomous_database_id** field is supported in the following format:
        #     `autonomous_database_id="{autonomous_database_id}"`. The accepted values
        #     must be a valid Autonomous Database ID, limited to the naming
        #     restrictions of the ID: ^[a-z]([a-z0-9-]\\{0,61}[a-z0-9])?$).
        #     The ID must start with a letter, end with a letter or a number, and be
        #     a maximum of 63 characters.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of items to return.
        #     If unspecified, at most 50 Autonomous DB Backups will be returned.
        #     The maximum value is 1000; values above 1000 will be coerced to 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A token identifying a page of results the server should return.
        class ListAutonomousDatabaseBackupsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response for `AutonomousDatabaseBackup.List`.
        # @!attribute [rw] autonomous_database_backups
        #   @return [::Array<::Google::Cloud::OracleDatabase::V1::AutonomousDatabaseBackup>]
        #     The list of Autonomous Database Backups.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A token identifying a page of results the server should return.
        class ListAutonomousDatabaseBackupsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
