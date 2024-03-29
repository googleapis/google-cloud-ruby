# frozen_string_literal: true

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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module ResourceManager
      module V3
        # The root node in the resource hierarchy to which a particular entity's
        # (a company, for example) resources belong.
        # @!attribute [r] name
        #   @return [::String]
        #     Output only. The resource name of the organization. This is the
        #     organization's relative path in the API. Its format is
        #     "organizations/[organization_id]". For example, "organizations/1234".
        # @!attribute [r] display_name
        #   @return [::String]
        #     Output only. A human-readable string that refers to the organization in the
        #     Google Cloud Console. This string is set by the server and cannot be
        #     changed. The string will be set to the primary domain (for example,
        #     "google.com") of the Google Workspace customer that owns the organization.
        # @!attribute [rw] directory_customer_id
        #   @return [::String]
        #     Immutable. The G Suite / Workspace customer id used in the Directory API.
        # @!attribute [r] state
        #   @return [::Google::Cloud::ResourceManager::V3::Organization::State]
        #     Output only. The organization's current lifecycle state.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Timestamp when the Organization was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Timestamp when the Organization was last modified.
        # @!attribute [r] delete_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Timestamp when the Organization was requested for deletion.
        # @!attribute [r] etag
        #   @return [::String]
        #     Output only. A checksum computed by the server based on the current value
        #     of the Organization resource. This may be sent on update and delete
        #     requests to ensure the client has an up-to-date value before proceeding.
        class Organization
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Organization lifecycle states.
          module State
            # Unspecified state.  This is only useful for distinguishing unset values.
            STATE_UNSPECIFIED = 0

            # The normal and active state.
            ACTIVE = 1

            # The organization has been marked for deletion by the user.
            DELETE_REQUESTED = 2
          end
        end

        # The request sent to the `GetOrganization` method. The `name` field is
        # required. `organization_id` is no longer accepted.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The resource name of the Organization to fetch. This is the
        #     organization's relative path in the API, formatted as
        #     "organizations/[organizationId]". For example, "organizations/1234".
        class GetOrganizationRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The request sent to the `SearchOrganizations` method.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Optional. The maximum number of organizations to return in the response.
        #     The server can return fewer organizations than requested. If unspecified,
        #     server picks an appropriate default.
        # @!attribute [rw] page_token
        #   @return [::String]
        #     Optional. A pagination token returned from a previous call to
        #     `SearchOrganizations` that indicates from where listing should continue.
        # @!attribute [rw] query
        #   @return [::String]
        #     Optional. An optional query string used to filter the Organizations to
        #     return in the response. Query rules are case-insensitive.
        #
        #
        #     ```
        #     | Field            | Description                                |
        #     |------------------|--------------------------------------------|
        #     | directoryCustomerId, owner.directoryCustomerId | Filters by directory
        #     customer id. |
        #     | domain           | Filters by domain.                         |
        #     ```
        #
        #     Organizations may be queried by `directoryCustomerId` or by
        #     `domain`, where the domain is a G Suite domain, for example:
        #
        #     * Query `directorycustomerid:123456789` returns Organization
        #     resources with `owner.directory_customer_id` equal to `123456789`.
        #     * Query `domain:google.com` returns Organization resources corresponding
        #     to the domain `google.com`.
        class SearchOrganizationsRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # The response returned from the `SearchOrganizations` method.
        # @!attribute [rw] organizations
        #   @return [::Array<::Google::Cloud::ResourceManager::V3::Organization>]
        #     The list of Organizations that matched the search query, possibly
        #     paginated.
        # @!attribute [rw] next_page_token
        #   @return [::String]
        #     A pagination token to be used to retrieve the next page of results. If the
        #     result is too large to fit within the page size specified in the request,
        #     this field will be set with a token that can be used to fetch the next page
        #     of results. If this field is empty, it indicates that this response
        #     contains the last page of results.
        class SearchOrganizationsResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # A status object which is used as the `metadata` field for the operation
        # returned by DeleteOrganization.
        class DeleteOrganizationMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # A status object which is used as the `metadata` field for the Operation
        # returned by UndeleteOrganization.
        class UndeleteOrganizationMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
