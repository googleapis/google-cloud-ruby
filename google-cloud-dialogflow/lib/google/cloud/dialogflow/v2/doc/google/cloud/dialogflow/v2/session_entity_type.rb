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
  module Cloud
    module Dialogflow
      module V2
        # Represents a session entity type.
        #
        # Extends or replaces a developer entity type at the user session level (we
        # refer to the entity types defined at the agent level as "developer entity
        # types").
        #
        # Note: session entity types apply to all queries, regardless of the language.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The unique identifier of this session entity type. Format:
        #     +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
        #     Display Name>+.
        # @!attribute [rw] entity_override_mode
        #   @return [Google::Cloud::Dialogflow::V2::SessionEntityType::EntityOverrideMode]
        #     Required. Indicates whether the additional data should override or
        #     supplement the developer entity type definition.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType::Entity>]
        #     Required. The collection of entities associated with this session entity
        #     type.
        class SessionEntityType
          # The types of modifications for a session entity type.
          module EntityOverrideMode
            # Not specified. This value should be never used.
            ENTITY_OVERRIDE_MODE_UNSPECIFIED = 0

            # The collection of session entities overrides the collection of entities
            # in the corresponding developer entity type.
            ENTITY_OVERRIDE_MODE_OVERRIDE = 1

            # The collection of session entities extends the collection of entities in
            # the corresponding developer entity type.
            # Calls to +ListSessionEntityTypes+, +GetSessionEntityType+,
            # +CreateSessionEntityType+ and +UpdateSessionEntityType+ return the full
            # collection of entities from the developer entity type in the agent's
            # default language and the session entity type.
            ENTITY_OVERRIDE_MODE_SUPPLEMENT = 2
          end
        end

        # The request message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::ListSessionEntityTypes SessionEntityTypes::ListSessionEntityTypes}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The session to list all session entity types from.
        #     Format: +projects/<Project ID>/agent/sessions/<Session ID>+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. The maximum number of items to return in a single page. By
        #     default 100 and at most 1000.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. The next_page_token value returned from a previous list request.
        class ListSessionEntityTypesRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::ListSessionEntityTypes SessionEntityTypes::ListSessionEntityTypes}.
        # @!attribute [rw] session_entity_types
        #   @return [Array<Google::Cloud::Dialogflow::V2::SessionEntityType>]
        #     The list of session entity types. There will be a maximum number of items
        #     returned based on the page_size field in the request.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Token to retrieve the next page of results, or empty if there are no
        #     more results in the list.
        class ListSessionEntityTypesResponse; end

        # The request message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::GetSessionEntityType SessionEntityTypes::GetSessionEntityType}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the session entity type. Format:
        #     +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
        #     Display Name>+.
        class GetSessionEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::CreateSessionEntityType SessionEntityTypes::CreateSessionEntityType}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The session to create a session entity type for.
        #     Format: +projects/<Project ID>/agent/sessions/<Session ID>+.
        # @!attribute [rw] session_entity_type
        #   @return [Google::Cloud::Dialogflow::V2::SessionEntityType]
        #     Required. The session entity type to create.
        class CreateSessionEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::UpdateSessionEntityType SessionEntityTypes::UpdateSessionEntityType}.
        # @!attribute [rw] session_entity_type
        #   @return [Google::Cloud::Dialogflow::V2::SessionEntityType]
        #     Required. The entity type to update. Format:
        #     +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
        #     Display Name>+.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        class UpdateSessionEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::SessionEntityTypes::DeleteSessionEntityType SessionEntityTypes::DeleteSessionEntityType}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the entity type to delete. Format:
        #     +projects/<Project ID>/agent/sessions/<Session ID>/entityTypes/<Entity Type
        #     Display Name>+.
        class DeleteSessionEntityTypeRequest; end
      end
    end
  end
end