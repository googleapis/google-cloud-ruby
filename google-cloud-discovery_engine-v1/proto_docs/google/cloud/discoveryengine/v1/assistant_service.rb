# frozen_string_literal: true

# Copyright 2025 Google LLC
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
      module V1
        # User metadata of the request.
        # @!attribute [rw] time_zone
        #   @return [::String]
        #     Optional. IANA time zone, e.g. Europe/Budapest.
        # @!attribute [rw] preferred_language_code
        #   @return [::String]
        #     Optional. Preferred language to be used for answering if language detection
        #     fails. Also used as the language of error messages created by actions,
        #     regardless of language detection results.
        class AssistUserMetadata
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end

        # Request for the
        # {::Google::Cloud::DiscoveryEngine::V1::AssistantService::Client#stream_assist AssistantService.StreamAssist}
        # method.
        # @!attribute [rw] name
        #   @return [::String]
        #     Required. The resource name of the
        #     {::Google::Cloud::DiscoveryEngine::V1::Assistant Assistant}. Format:
        #     `projects/{project}/locations/{location}/collections/{collection}/engines/{engine}/assistants/{assistant}`
        # @!attribute [rw] query
        #   @return [::Google::Cloud::DiscoveryEngine::V1::Query]
        #     Optional. Current user query.
        #
        #     Empty query is only supported if `file_ids` are provided. In this case, the
        #     answer will be generated based on those context files.
        # @!attribute [rw] session
        #   @return [::String]
        #     Optional. The session to use for the request. If specified, the assistant
        #     has access to the session history, and the query and the answer are stored
        #     there.
        #
        #     If `-` is specified as the session ID, or it is left empty, then a new
        #     session is created with an automatically generated ID.
        #
        #     Format:
        #     `projects/{project}/locations/{location}/collections/{collection}/engines/{engine}/sessions/{session}`
        # @!attribute [rw] user_metadata
        #   @return [::Google::Cloud::DiscoveryEngine::V1::AssistUserMetadata]
        #     Optional. Information about the user initiating the query.
        # @!attribute [rw] tools_spec
        #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::ToolsSpec]
        #     Optional. Specification of tools that are used to serve the request.
        # @!attribute [rw] generation_spec
        #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::GenerationSpec]
        #     Optional. Specification of the generation configuration for the request.
        class StreamAssistRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Specification of tools that are used to serve the request.
          # @!attribute [rw] vertex_ai_search_spec
          #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::ToolsSpec::VertexAiSearchSpec]
          #     Optional. Specification of the Vertex AI Search tool.
          # @!attribute [rw] web_grounding_spec
          #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::ToolsSpec::WebGroundingSpec]
          #     Optional. Specification of the web grounding tool.
          #     If field is present, enables grounding with web search. Works only if
          #     [Assistant.web_grounding_type][google.cloud.discoveryengine.v1.Assistant.web_grounding_type]
          #     is [WEB_GROUNDING_TYPE_GOOGLE_SEARCH][] or
          #     [WEB_GROUNDING_TYPE_ENTERPRISE_WEB_SEARCH][].
          # @!attribute [rw] image_generation_spec
          #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::ToolsSpec::ImageGenerationSpec]
          #     Optional. Specification of the image generation tool.
          # @!attribute [rw] video_generation_spec
          #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistRequest::ToolsSpec::VideoGenerationSpec]
          #     Optional. Specification of the video generation tool.
          class ToolsSpec
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Specification of the Vertex AI Search tool.
            # @!attribute [rw] data_store_specs
            #   @return [::Array<::Google::Cloud::DiscoveryEngine::V1::SearchRequest::DataStoreSpec>]
            #     Optional. Specs defining
            #     {::Google::Cloud::DiscoveryEngine::V1::DataStore DataStore}s to filter on in
            #     a search call and configurations for those data stores. This is only
            #     considered for {::Google::Cloud::DiscoveryEngine::V1::Engine Engine}s with
            #     multiple data stores.
            # @!attribute [rw] filter
            #   @return [::String]
            #     Optional. The filter syntax consists of an expression language for
            #     constructing a predicate from one or more fields of the documents being
            #     filtered. Filter expression is case-sensitive.
            #
            #     If this field is unrecognizable, an  `INVALID_ARGUMENT`  is returned.
            #
            #     Filtering in Vertex AI Search is done by mapping the LHS filter key to
            #     a key property defined in the Vertex AI Search backend -- this mapping
            #     is defined by the customer in their schema. For example a media
            #     customer might have a field 'name' in their schema. In this case the
            #     filter would look like this: filter --> name:'ANY("king kong")'
            #
            #     For more information about filtering including syntax and filter
            #     operators, see
            #     [Filter](https://cloud.google.com/generative-ai-app-builder/docs/filter-search-metadata)
            class VertexAiSearchSpec
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Specification of the web grounding tool.
            class WebGroundingSpec
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Specification of the image generation tool.
            class ImageGenerationSpec
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # Specification of the video generation tool.
            class VideoGenerationSpec
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end
          end

          # Assistant generation specification for the request.
          # This allows to override the default generation configuration at the engine
          # level.
          # @!attribute [rw] model_id
          #   @return [::String]
          #     Optional. The Vertex AI model_id used for the generative model. If not
          #     set, the default Assistant model will be used.
          class GenerationSpec
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Response for the
        # {::Google::Cloud::DiscoveryEngine::V1::AssistantService::Client#stream_assist AssistantService.StreamAssist}
        # method.
        # @!attribute [rw] answer
        #   @return [::Google::Cloud::DiscoveryEngine::V1::AssistAnswer]
        #     Assist answer resource object containing parts of the assistant's final
        #     answer for the user's query.
        #
        #     Not present if the current response doesn't add anything to previously
        #     sent
        #     {::Google::Cloud::DiscoveryEngine::V1::AssistAnswer#replies AssistAnswer.replies}.
        #
        #     Observe
        #     {::Google::Cloud::DiscoveryEngine::V1::AssistAnswer#state AssistAnswer.state} to
        #     see if more parts are to be expected. While the state is `IN_PROGRESS`, the
        #     {::Google::Cloud::DiscoveryEngine::V1::AssistAnswer#replies AssistAnswer.replies}
        #     field in each response will contain replies (reply fragments) to be
        #     appended to the ones received in previous responses. [AssistAnswer.name][]
        #     won't be filled.
        #
        #     If the state is `SUCCEEDED`, `FAILED` or `SKIPPED`, the response
        #     is the last response and [AssistAnswer.name][] will have a value.
        # @!attribute [rw] session_info
        #   @return [::Google::Cloud::DiscoveryEngine::V1::StreamAssistResponse::SessionInfo]
        #     Session information.
        # @!attribute [rw] assist_token
        #   @return [::String]
        #     A global unique ID that identifies the current pair of request and stream
        #     of responses. Used for feedback and support.
        class StreamAssistResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Information about the session.
          # @!attribute [rw] session
          #   @return [::String]
          #     Name of the newly generated or continued session.
          #
          #     Format:
          #     `projects/{project}/locations/{location}/collections/{collection}/engines/{engine}/sessions/{session}`.
          class SessionInfo
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end
      end
    end
  end
end
