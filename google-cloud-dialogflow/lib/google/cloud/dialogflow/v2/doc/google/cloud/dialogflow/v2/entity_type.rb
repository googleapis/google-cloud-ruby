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
        # Represents an entity type.
        # Entity types serve as a tool for extracting parameter values from natural
        # language queries.
        # @!attribute [rw] name
        #   @return [String]
        #     Required for all methods except +create+ (+create+ populates the name
        #     automatically.
        #     The unique identifier of the entity type. Format:
        #     +projects/<Project ID>/agent/entityTypes/<Entity Type ID>+.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Required. The name of the entity.
        # @!attribute [rw] kind
        #   @return [Google::Cloud::Dialogflow::V2::EntityType::Kind]
        #     Required. Indicates the kind of entity type.
        # @!attribute [rw] auto_expansion_mode
        #   @return [Google::Cloud::Dialogflow::V2::EntityType::AutoExpansionMode]
        #     Optional. Indicates whether the entity type can be automatically
        #     expanded.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType::Entity>]
        #     Optional. The collection of entities associated with the entity type.
        class EntityType
          # Optional. Represents an entity.
          # @!attribute [rw] value
          #   @return [String]
          #     Required.
          #     For +KIND_MAP+ entity types:
          #       A canonical name to be used in place of synonyms.
          #     For +KIND_LIST+ entity types:
          #       A string that can contain references to other entity types (with or
          #       without aliases).
          # @!attribute [rw] synonyms
          #   @return [Array<String>]
          #     Required. A collection of synonyms. For +KIND_LIST+ entity types this
          #     must contain exactly one synonym equal to +value+.
          class Entity; end

          # Represents kinds of entities.
          module Kind
            # Not specified. This value should be never used.
            KIND_UNSPECIFIED = 0

            # Map entity types allow mapping of a group of synonyms to a canonical
            # value.
            KIND_MAP = 1

            # List entity types contain a set of entries that do not map to canonical
            # values. However, list entity types can contain references to other entity
            # types (with or without aliases).
            KIND_LIST = 2
          end

          # Represents different entity type expansion modes. Automated expansion
          # allows an agent to recognize values that have not been explicitly listed in
          # the entity (for example, new kinds of shopping list items).
          module AutoExpansionMode
            # Auto expansion disabled for the entity.
            AUTO_EXPANSION_MODE_UNSPECIFIED = 0

            # Allows an agent to recognize values that have not been explicitly
            # listed in the entity.
            AUTO_EXPANSION_MODE_DEFAULT = 1
          end
        end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::ListEntityTypes EntityTypes::ListEntityTypes}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The agent to list all entity types from.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language to list entity synonyms for. If not specified,
        #     the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. The maximum number of items to return in a single page. By
        #     default 100 and at most 1000.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. The next_page_token value returned from a previous list request.
        class ListEntityTypesRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::EntityTypes::ListEntityTypes EntityTypes::ListEntityTypes}.
        # @!attribute [rw] entity_types
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType>]
        #     The list of agent entity types. There will be a maximum number of items
        #     returned based on the page_size field in the request.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Token to retrieve the next page of results, or empty if there are no
        #     more results in the list.
        class ListEntityTypesResponse; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::GetEntityType EntityTypes::GetEntityType}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the entity type.
        #     Format: +projects/<Project ID>/agent/entityTypes/<EntityType ID>+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language to retrieve entity synonyms for. If not specified,
        #     the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        class GetEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::CreateEntityType EntityTypes::CreateEntityType}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The agent to create a entity type for.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] entity_type
        #   @return [Google::Cloud::Dialogflow::V2::EntityType]
        #     Required. The entity type to create.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entity_type+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        class CreateEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::UpdateEntityType EntityTypes::UpdateEntityType}.
        # @!attribute [rw] entity_type
        #   @return [Google::Cloud::Dialogflow::V2::EntityType]
        #     Required. The entity type to update.
        #     Format: +projects/<Project ID>/agent/entityTypes/<EntityType ID>+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entity_type+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        class UpdateEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::DeleteEntityType EntityTypes::DeleteEntityType}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the entity type to delete.
        #     Format: +projects/<Project ID>/agent/entityTypes/<EntityType ID>+.
        class DeleteEntityTypeRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchUpdateEntityTypes EntityTypes::BatchUpdateEntityTypes}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the agent to update or create entity types in.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] entity_type_batch_uri
        #   @return [String]
        #     The URI to a Google Cloud Storage file containing entity types to update
        #     or create. The file format can either be a serialized proto (of
        #     EntityBatch type) or a JSON object. Note: The URI must start with
        #     "gs://".
        # @!attribute [rw] entity_type_batch_inline
        #   @return [Google::Cloud::Dialogflow::V2::EntityTypeBatch]
        #     The collection of entity type to update or create.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entity_types+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        class BatchUpdateEntityTypesRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchUpdateEntityTypes EntityTypes::BatchUpdateEntityTypes}.
        # @!attribute [rw] entity_types
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType>]
        #     The collection of updated or created entity types.
        class BatchUpdateEntityTypesResponse; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchDeleteEntityTypes EntityTypes::BatchDeleteEntityTypes}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the agent to delete all entities types for. Format:
        #     +projects/<Project ID>/agent+.
        # @!attribute [rw] entity_type_names
        #   @return [Array<String>]
        #     Required. The names entity types to delete. All names must point to the
        #     same agent as +parent+.
        class BatchDeleteEntityTypesRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchCreateEntities EntityTypes::BatchCreateEntities}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the entity type to create entities in. Format:
        #     +projects/<Project ID>/agent/entityTypes/<Entity Type ID>+.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType::Entity>]
        #     Required. The collection of entities to create.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entities+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        class BatchCreateEntitiesRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchCreateEntities EntityTypes::BatchCreateEntities}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the entity type to update the entities in. Format:
        #     +projects/<Project ID>/agent/entityTypes/<Entity Type ID>+.
        # @!attribute [rw] entities
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType::Entity>]
        #     Required. The collection of new entities to replace the existing entities.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entities+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        class BatchUpdateEntitiesRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::EntityTypes::BatchDeleteEntities EntityTypes::BatchDeleteEntities}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the entity type to delete entries for. Format:
        #     +projects/<Project ID>/agent/entityTypes/<Entity Type ID>+.
        # @!attribute [rw] entity_values
        #   @return [Array<String>]
        #     Required. The canonical +values+ of the entities to delete. Note that
        #     these are not fully-qualified names, i.e. they don't start with
        #     +projects/<Project ID>+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of entity synonyms defined in +entities+. If not
        #     specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        class BatchDeleteEntitiesRequest; end

        # This message is a wrapper around a collection of entity types.
        # @!attribute [rw] entity_types
        #   @return [Array<Google::Cloud::Dialogflow::V2::EntityType>]
        #     A collection of entity types.
        class EntityTypeBatch; end
      end
    end
  end
end