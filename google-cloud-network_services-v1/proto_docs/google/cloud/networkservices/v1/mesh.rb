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
    module NetworkServices
      module V1
        # Mesh represents a logical configuration grouping for workload to workload
        # communication within a service mesh. Routes that point to mesh dictate how
        # requests are routed within this logical mesh boundary.
        # @!attribute [rw] name
        #   @return [::String]
        #     Identifier. Name of the Mesh resource. It matches pattern
        #     `projects/*/locations/global/meshes/<mesh_name>`.
        # @!attribute [r] self_link
        #   @return [::String]
        #     Output only. Server-defined URL of this resource
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. The timestamp when the resource was updated.
        # @!attribute [rw] labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     Optional. Set of label tags associated with the Mesh resource.
        # @!attribute [rw] description
        #   @return [::String]
        #     Optional. A free-text description of the resource. Max length 1024
        #     characters.
        # @!attribute [rw] interception_port
        #   @return [::Integer]
        #     Optional. If set to a valid TCP port (1-65535), instructs the SIDECAR proxy
        #     to listen on the specified port of localhost (127.0.0.1) address. The
        #     SIDECAR proxy will expect all traffic to be redirected to this port
        #     regardless of its actual ip:port destination. If unset, a port '15001' is
        #     used as the interception port. This is applicable only for sidecar proxy
        #     deployments.
        # @!attribute [rw] envoy_headers
        #   @return [::Google::Cloud::NetworkServices::V1::EnvoyHeaders]
        #     Optional. Determines if envoy will insert internal debug headers into
        #     upstream requests. Other Envoy headers may still be injected. By default,
        #     envoy will not insert any debug headers.
        class Mesh
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Request used with the ListMeshes method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The project and location from which the Meshes should be
        #     listed, specified in the format `projects/*/locations/global`.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Maximum number of Meshes to return per call.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     The value returned by the last `ListMeshesResponse`
        #     Indicates that this is a continuation of a prior `ListMeshes` call,
        #     and that the system should return the next page of data.
        # @!attribute [rw] return_partial_success
        #   @return [::Boolean]
        #     Optional. If true, allow partial responses for multi-regional Aggregated
        #     List requests. Otherwise if one of the locations is down or unreachable,
        #     the Aggregated List request will fail.
        class ListMeshesRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response returned by the ListMeshes method.
        # @!attribute [rw] meshes
        #   @return [::Array<::Google::Cloud::NetworkServices::V1::Mesh>]
        #     List of Mesh resources.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     If there might be more results than those appearing in this response, then
        #     `next_page_token` is included. To get the next set of results, call this
        #     method again using the value of `next_page_token` as `page_token`.
        # @!attribute [rw] unreachable
        #   @return [::Array<::String>]
        #     Unreachable resources. Populated when the request opts into
        #     `return_partial_success` and reading across collections e.g. when
        #     attempting to list all resources across all supported locations.
        class ListMeshesResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the GetMesh method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the Mesh to get. Must be in the format
        #     `projects/*/locations/global/meshes/*`.
        class GetMeshRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the CreateMesh method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The parent resource of the Mesh. Must be in the
        #     format `projects/*/locations/global`.
        # @!attribute [rw] mesh_id
        #   @return [::String]
        #     Required. Short name of the Mesh resource to be created.
        # @!attribute [rw] mesh
        #   @return [::Google::Cloud::NetworkServices::V1::Mesh]
        #     Required. Mesh resource to be created.
        class CreateMeshRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the UpdateMesh method.
        # @!attribute [rw] update_mask
        #   @return [::Google::Protobuf::FieldMask]
        #     Optional. Field mask is used to specify the fields to be overwritten in the
        #     Mesh resource by the update.
        #     The fields specified in the update_mask are relative to the resource, not
        #     the full request. A field will be overwritten if it is in the mask. If the
        #     user does not provide a mask then all fields will be overwritten.
        # @!attribute [rw] mesh
        #   @return [::Google::Cloud::NetworkServices::V1::Mesh]
        #     Required. Updated Mesh resource.
        class UpdateMeshRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request used by the DeleteMesh method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. A name of the Mesh to delete. Must be in the format
        #     `projects/*/locations/global/meshes/*`.
        class DeleteMeshRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
