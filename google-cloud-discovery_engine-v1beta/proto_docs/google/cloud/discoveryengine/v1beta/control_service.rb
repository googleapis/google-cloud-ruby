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
    module DiscoveryEngine
      module V1beta
        # Request for CreateControl method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. Full resource name of parent data store. Format:
        #     `projects/{project}/locations/{location}/collections/{collection_id}/dataStores/{data_store_id}`
        #     or
        #     `projects/{project}/locations/{location}/collections/{collection_id}/engines/{engine_id}`.
        # @!attribute [rw] control
        #   @return [::Google::Cloud::DiscoveryEngine::V1beta::Control]
        #     Required. The Control to create.
        # @!attribute [rw] control_id
        #   @return [::String]
        #     Required. The ID to use for the Control, which will become the final
        #     component of the Control's resource name.
        #
        #     This value must be within 1-63 characters.
        #     Valid characters are /[a-z][0-9]-_/.
        class CreateControlRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request for UpdateControl method.
        # @!attribute [rw] control
        #   @return [::Google::Cloud::DiscoveryEngine::V1beta::Control]
        #     Required. The Control to update.
        # @!attribute [rw] update_mask
        #   @return [::Google::Protobuf::FieldMask]
        #     Optional. Indicates which fields in the provided
        #     {::Google::Cloud::DiscoveryEngine::V1beta::Control Control} to update. The
        #     following are NOT supported:
        #
        #     * {::Google::Cloud::DiscoveryEngine::V1beta::Control#name Control.name}
        #     * {::Google::Cloud::DiscoveryEngine::V1beta::Control#solution_type Control.solution_type}
        #
        #     If not set or empty, all supported fields are updated.
        class UpdateControlRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request for DeleteControl method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The resource name of the Control to delete. Format:
        #     `projects/{project}/locations/{location}/collections/{collection_id}/dataStores/{data_store_id}/controls/{control_id}`
        class DeleteControlRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request for GetControl method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The resource name of the Control to get. Format:
        #     `projects/{project}/locations/{location}/collections/{collection_id}/dataStores/{data_store_id}/controls/{control_id}`
        class GetControlRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request for ListControls method.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. The data store resource name. Format:
        #     `projects/{project}/locations/{location}/collections/{collection_id}/dataStores/{data_store_id}`
        #     or
        #     `projects/{project}/locations/{location}/collections/{collection_id}/engines/{engine_id}`.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. Maximum number of results to return. If unspecified, defaults
        #     to 50. Max allowed value is 1000.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A page token, received from a previous `ListControls` call.
        #     Provide this to retrieve the subsequent page.
        # @!attribute [rw] filter
        #   @return [::String]
        #     Optional. A filter to apply on the list results. Supported features:
        #
        #     * List all the products under the parent branch if
        #     {::Google::Cloud::DiscoveryEngine::V1beta::ListControlsRequest#filter filter} is
        #     unset. Currently this field is unsupported.
        class ListControlsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Response for ListControls method.
        # @!attribute [rw] controls
        #   @return [::Array<::Google::Cloud::DiscoveryEngine::V1beta::Control>]
        #     All the Controls for a given data store.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     Pagination token, if not returned indicates the last page.
        class ListControlsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
