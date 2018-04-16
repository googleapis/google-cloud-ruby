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
      ##
      # # Dialogflow API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [IntentsClient][] | An intent represents a mapping between input from a user and an action to be taken by your application. |
      # | [Data Types][] | Data types for Google::Cloud::Dialogflow::V2 |
      #
      # [IntentsClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dialogflow/latest/google/cloud/dialogflow/v2/intentsclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-dialogflow/latest/google/cloud/dialogflow/v2/datatypes
      #
      module V2
        # Represents an intent.
        # Intents convert a number of user expressions or patterns into an action. An
        # action is an extraction of a user command or sentence semantics.
        # @!attribute [rw] name
        #   @return [String]
        #     Required for all methods except +create+ (+create+ populates the name
        #     automatically.
        #     The unique identifier of this intent.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        # @!attribute [rw] display_name
        #   @return [String]
        #     Required. The name of this intent.
        # @!attribute [rw] webhook_state
        #   @return [Google::Cloud::Dialogflow::V2::Intent::WebhookState]
        #     Required. Indicates whether webhooks are enabled for the intent.
        # @!attribute [rw] priority
        #   @return [Integer]
        #     Optional. The priority of this intent. Higher numbers represent higher
        #     priorities. Zero or negative numbers mean that the intent is disabled.
        # @!attribute [rw] is_fallback
        #   @return [true, false]
        #     Optional. Indicates whether this is a fallback intent.
        # @!attribute [rw] ml_disabled
        #   @return [true, false]
        #     Optional. Indicates whether Machine Learning is disabled for the intent.
        #     Note: If +ml_diabled+ setting is set to true, then this intent is not
        #     taken into account during inference in +ML ONLY+ match mode. Also,
        #     auto-markup in the UI is turned off.
        # @!attribute [rw] input_context_names
        #   @return [Array<String>]
        #     Optional. The list of context names required for this intent to be
        #     triggered.
        #     Format: +projects/<Project ID>/agent/sessions/-/contexts/<Context ID>+.
        # @!attribute [rw] events
        #   @return [Array<String>]
        #     Optional. The collection of event names that trigger the intent.
        #     If the collection of input contexts is not empty, all of the contexts must
        #     be present in the active user session for an event to trigger this intent.
        # @!attribute [rw] training_phrases
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::TrainingPhrase>]
        #     Optional. The collection of examples/templates that the agent is
        #     trained on.
        # @!attribute [rw] action
        #   @return [String]
        #     Optional. The name of the action associated with the intent.
        # @!attribute [rw] output_contexts
        #   @return [Array<Google::Cloud::Dialogflow::V2::Context>]
        #     Optional. The collection of contexts that are activated when the intent
        #     is matched. Context messages in this collection should not set the
        #     parameters field. Setting the +lifespan_count+ to 0 will reset the context
        #     when the intent is matched.
        #     Format: +projects/<Project ID>/agent/sessions/-/contexts/<Context ID>+.
        # @!attribute [rw] reset_contexts
        #   @return [true, false]
        #     Optional. Indicates whether to delete all contexts in the current
        #     session when this intent is matched.
        # @!attribute [rw] parameters
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Parameter>]
        #     Optional. The collection of parameters associated with the intent.
        # @!attribute [rw] messages
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message>]
        #     Optional. The collection of rich messages corresponding to the
        #     +Response+ field in the Dialogflow console.
        # @!attribute [rw] default_response_platforms
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::Platform>]
        #     Optional. The list of platforms for which the first response will be
        #     taken from among the messages assigned to the DEFAULT_PLATFORM.
        # @!attribute [rw] root_followup_intent_name
        #   @return [String]
        #     The unique identifier of the root intent in the chain of followup intents.
        #     It identifies the correct followup intents chain for this intent.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        # @!attribute [rw] parent_followup_intent_name
        #   @return [String]
        #     The unique identifier of the parent intent in the chain of followup
        #     intents.
        #     It identifies the parent followup intent.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        # @!attribute [rw] followup_intent_info
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::FollowupIntentInfo>]
        #     Optional. Collection of information about all followup intents that have
        #     name of this intent as a root_name.
        class Intent
          # Represents an example or template that the agent is trained on.
          # @!attribute [rw] name
          #   @return [String]
          #     Required. The unique identifier of this training phrase.
          # @!attribute [rw] type
          #   @return [Google::Cloud::Dialogflow::V2::Intent::TrainingPhrase::Type]
          #     Required. The type of the training phrase.
          # @!attribute [rw] parts
          #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::TrainingPhrase::Part>]
          #     Required. The collection of training phrase parts (can be annotated).
          #     Fields: +entity_type+, +alias+ and +user_defined+ should be populated
          #     only for the annotated parts of the training phrase.
          # @!attribute [rw] times_added_count
          #   @return [Integer]
          #     Optional. Indicates how many times this example or template was added to
          #     the intent. Each time a developer adds an existing sample by editing an
          #     intent or training, this counter is increased.
          class TrainingPhrase
            # Represents a part of a training phrase.
            # @!attribute [rw] text
            #   @return [String]
            #     Required. The text corresponding to the example or template,
            #     if there are no annotations. For
            #     annotated examples, it is the text for one of the example's parts.
            # @!attribute [rw] entity_type
            #   @return [String]
            #     Optional. The entity type name prefixed with +@+. This field is
            #     required for the annotated part of the text and applies only to
            #     examples.
            # @!attribute [rw] alias
            #   @return [String]
            #     Optional. The parameter name for the value extracted from the
            #     annotated part of the example.
            # @!attribute [rw] user_defined
            #   @return [true, false]
            #     Optional. Indicates whether the text was manually annotated by the
            #     developer.
            class Part; end

            # Represents different types of training phrases.
            module Type
              # Not specified. This value should never be used.
              TYPE_UNSPECIFIED = 0

              # Examples do not contain @-prefixed entity type names, but example parts
              # can be annotated with entity types.
              EXAMPLE = 1

              # Templates are not annotated with entity types, but they can contain
              # @-prefixed entity type names as substrings.
              TEMPLATE = 2
            end
          end

          # Represents intent parameters.
          # @!attribute [rw] name
          #   @return [String]
          #     The unique identifier of this parameter.
          # @!attribute [rw] display_name
          #   @return [String]
          #     Required. The name of the parameter.
          # @!attribute [rw] value
          #   @return [String]
          #     Optional. The definition of the parameter value. It can be:
          #     * a constant string,
          #     * a parameter value defined as +$parameter_name+,
          #     * an original parameter value defined as +$parameter_name.original+,
          #     * a parameter value from some context defined as
          #       +#context_name.parameter_name+.
          # @!attribute [rw] default_value
          #   @return [String]
          #     Optional. The default value to use when the +value+ yields an empty
          #     result.
          #     Default values can be extracted from contexts by using the following
          #     syntax: +#context_name.parameter_name+.
          # @!attribute [rw] entity_type_display_name
          #   @return [String]
          #     Optional. The name of the entity type, prefixed with +@+, that
          #     describes values of the parameter. If the parameter is
          #     required, this must be provided.
          # @!attribute [rw] mandatory
          #   @return [true, false]
          #     Optional. Indicates whether the parameter is required. That is,
          #     whether the intent cannot be completed without collecting the parameter
          #     value.
          # @!attribute [rw] prompts
          #   @return [Array<String>]
          #     Optional. The collection of prompts that the agent can present to the
          #     user in order to collect value for the parameter.
          # @!attribute [rw] is_list
          #   @return [true, false]
          #     Optional. Indicates whether the parameter represents a list of values.
          class Parameter; end

          # Corresponds to the +Response+ field in the Dialogflow console.
          # @!attribute [rw] text
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Text]
          #     The text response.
          # @!attribute [rw] image
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Image]
          #     The image response.
          # @!attribute [rw] quick_replies
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::QuickReplies]
          #     The quick replies response.
          # @!attribute [rw] card
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Card]
          #     The card response.
          # @!attribute [rw] payload
          #   @return [Google::Protobuf::Struct]
          #     Returns a response containing a custom, platform-specific payload.
          #     See the Intent.Message.Platform type for a description of the
          #     structure that may be required for your platform.
          # @!attribute [rw] simple_responses
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::SimpleResponses]
          #     The voice and text-only responses for Actions on Google.
          # @!attribute [rw] basic_card
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::BasicCard]
          #     The basic card response for Actions on Google.
          # @!attribute [rw] suggestions
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Suggestions]
          #     The suggestion chips for Actions on Google.
          # @!attribute [rw] link_out_suggestion
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::LinkOutSuggestion]
          #     The link out suggestion chip for Actions on Google.
          # @!attribute [rw] list_select
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::ListSelect]
          #     The list card response for Actions on Google.
          # @!attribute [rw] carousel_select
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::CarouselSelect]
          #     The carousel card response for Actions on Google.
          # @!attribute [rw] platform
          #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Platform]
          #     Optional. The platform that this message is intended for.
          class Message
            # The text response message.
            # @!attribute [rw] text
            #   @return [Array<String>]
            #     Optional. The collection of the agent's responses.
            class Text; end

            # The image response message.
            # @!attribute [rw] image_uri
            #   @return [String]
            #     Optional. The public URI to an image file.
            # @!attribute [rw] accessibility_text
            #   @return [String]
            #     Optional. A text description of the image to be used for accessibility,
            #     e.g., screen readers.
            class Image; end

            # The quick replies response message.
            # @!attribute [rw] title
            #   @return [String]
            #     Optional. The title of the collection of quick replies.
            # @!attribute [rw] quick_replies
            #   @return [Array<String>]
            #     Optional. The collection of quick replies.
            class QuickReplies; end

            # The card response message.
            # @!attribute [rw] title
            #   @return [String]
            #     Optional. The title of the card.
            # @!attribute [rw] subtitle
            #   @return [String]
            #     Optional. The subtitle of the card.
            # @!attribute [rw] image_uri
            #   @return [String]
            #     Optional. The public URI to an image file for the card.
            # @!attribute [rw] buttons
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::Card::Button>]
            #     Optional. The collection of card buttons.
            class Card
              # Optional. Contains information about a button.
              # @!attribute [rw] text
              #   @return [String]
              #     Optional. The text to show on the button.
              # @!attribute [rw] postback
              #   @return [String]
              #     Optional. The text to send back to the Dialogflow API or a URI to
              #     open.
              class Button; end
            end

            # The simple response message containing speech or text.
            # @!attribute [rw] text_to_speech
            #   @return [String]
            #     One of text_to_speech or ssml must be provided. The plain text of the
            #     speech output. Mutually exclusive with ssml.
            # @!attribute [rw] ssml
            #   @return [String]
            #     One of text_to_speech or ssml must be provided. Structured spoken
            #     response to the user in the SSML format. Mutually exclusive with
            #     text_to_speech.
            # @!attribute [rw] display_text
            #   @return [String]
            #     Optional. The text to display.
            class SimpleResponse; end

            # The collection of simple response candidates.
            # This message in +QueryResult.fulfillment_messages+ and
            # +WebhookResponse.fulfillment_messages+ should contain only one
            # +SimpleResponse+.
            # @!attribute [rw] simple_responses
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::SimpleResponse>]
            #     Required. The list of simple responses.
            class SimpleResponses; end

            # The basic card message. Useful for displaying information.
            # @!attribute [rw] title
            #   @return [String]
            #     Optional. The title of the card.
            # @!attribute [rw] subtitle
            #   @return [String]
            #     Optional. The subtitle of the card.
            # @!attribute [rw] formatted_text
            #   @return [String]
            #     Required, unless image is present. The body text of the card.
            # @!attribute [rw] image
            #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Image]
            #     Optional. The image for the card.
            # @!attribute [rw] buttons
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::BasicCard::Button>]
            #     Optional. The collection of card buttons.
            class BasicCard
              # The button object that appears at the bottom of a card.
              # @!attribute [rw] title
              #   @return [String]
              #     Required. The title of the button.
              # @!attribute [rw] open_uri_action
              #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::BasicCard::Button::OpenUriAction]
              #     Required. Action to take when a user taps on the button.
              class Button
                # Opens the given URI.
                # @!attribute [rw] uri
                #   @return [String]
                #     Required. The HTTP or HTTPS scheme URI.
                class OpenUriAction; end
              end
            end

            # The suggestion chip message that the user can tap to quickly post a reply
            # to the conversation.
            # @!attribute [rw] title
            #   @return [String]
            #     Required. The text shown the in the suggestion chip.
            class Suggestion; end

            # The collection of suggestions.
            # @!attribute [rw] suggestions
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::Suggestion>]
            #     Required. The list of suggested replies.
            class Suggestions; end

            # The suggestion chip message that allows the user to jump out to the app
            # or website associated with this agent.
            # @!attribute [rw] destination_name
            #   @return [String]
            #     Required. The name of the app or site this chip is linking to.
            # @!attribute [rw] uri
            #   @return [String]
            #     Required. The URI of the app or site to open when the user taps the
            #     suggestion chip.
            class LinkOutSuggestion; end

            # The card for presenting a list of options to select from.
            # @!attribute [rw] title
            #   @return [String]
            #     Optional. The overall title of the list.
            # @!attribute [rw] items
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::ListSelect::Item>]
            #     Required. List items.
            class ListSelect
              # An item in the list.
              # @!attribute [rw] info
              #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::SelectItemInfo]
              #     Required. Additional information about this option.
              # @!attribute [rw] title
              #   @return [String]
              #     Required. The title of the list item.
              # @!attribute [rw] description
              #   @return [String]
              #     Optional. The main text describing the item.
              # @!attribute [rw] image
              #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Image]
              #     Optional. The image to display.
              class Item; end
            end

            # The card for presenting a carousel of options to select from.
            # @!attribute [rw] items
            #   @return [Array<Google::Cloud::Dialogflow::V2::Intent::Message::CarouselSelect::Item>]
            #     Required. Carousel items.
            class CarouselSelect
              # An item in the carousel.
              # @!attribute [rw] info
              #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::SelectItemInfo]
              #     Required. Additional info about the option item.
              # @!attribute [rw] title
              #   @return [String]
              #     Required. Title of the carousel item.
              # @!attribute [rw] description
              #   @return [String]
              #     Optional. The body text of the card.
              # @!attribute [rw] image
              #   @return [Google::Cloud::Dialogflow::V2::Intent::Message::Image]
              #     Optional. The image to display.
              class Item; end
            end

            # Additional info about the select item for when it is triggered in a
            # dialog.
            # @!attribute [rw] key
            #   @return [String]
            #     Required. A unique key that will be sent back to the agent if this
            #     response is given.
            # @!attribute [rw] synonyms
            #   @return [Array<String>]
            #     Optional. A list of synonyms that can also be used to trigger this
            #     item in dialog.
            class SelectItemInfo; end

            # Represents different platforms that a rich message can be intended for.
            module Platform
              # Not specified.
              PLATFORM_UNSPECIFIED = 0

              # Facebook.
              FACEBOOK = 1

              # Slack.
              SLACK = 2

              # Telegram.
              TELEGRAM = 3

              # Kik.
              KIK = 4

              # Skype.
              SKYPE = 5

              # Line.
              LINE = 6

              # Viber.
              VIBER = 7

              # Actions on Google.
              # When using Actions on Google, you can choose one of the specific
              # Intent.Message types that mention support for Actions on Google,
              # or you can use the advanced Intent.Message.payload field.
              # The payload field provides access to AoG features not available in the
              # specific message types.
              # If using the Intent.Message.payload field, it should have a structure
              # similar to the JSON message shown here. For more information, see
              # [Actions on Google Webhook
              # Format](https://developers.google.com/actions/dialogflow/webhook)
              # <pre>{
              #   "expectUserResponse": true,
              #   "isSsml": false,
              #   "noInputPrompts": [],
              #   "richResponse": {
              #     "items": [
              #       {
              #         "simpleResponse": {
              #           "displayText": "hi",
              #           "textToSpeech": "hello"
              #         }
              #       }
              #     ],
              #     "suggestions": [
              #       {
              #         "title": "Say this"
              #       },
              #       {
              #         "title": "or this"
              #       }
              #     ]
              #   },
              #   "systemIntent": {
              #     "data": {
              #       "@type": "type.googleapis.com/google.actions.v2.OptionValueSpec",
              #       "listSelect": {
              #         "items": [
              #           {
              #             "optionInfo": {
              #               "key": "key1",
              #               "synonyms": [
              #                 "key one"
              #               ]
              #             },
              #             "title": "must not be empty, but unique"
              #           },
              #           {
              #             "optionInfo": {
              #               "key": "key2",
              #               "synonyms": [
              #                 "key two"
              #               ]
              #             },
              #             "title": "must not be empty, but unique"
              #           }
              #         ]
              #       }
              #     },
              #     "intent": "actions.intent.OPTION"
              #   }
              # }</pre>
              ACTIONS_ON_GOOGLE = 8
            end
          end

          # Represents a single followup intent in the chain.
          # @!attribute [rw] followup_intent_name
          #   @return [String]
          #     The unique identifier of the followup intent.
          #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
          # @!attribute [rw] parent_followup_intent_name
          #   @return [String]
          #     The unique identifier of the followup intent parent.
          #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
          class FollowupIntentInfo; end

          # Represents the different states that webhooks can be in.
          module WebhookState
            # Webhook is disabled in the agent and in the intent.
            WEBHOOK_STATE_UNSPECIFIED = 0

            # Webhook is enabled in the agent and in the intent.
            WEBHOOK_STATE_ENABLED = 1

            # Webhook is enabled in the agent and in the intent. Also, each slot
            # filling prompt is forwarded to the webhook.
            WEBHOOK_STATE_ENABLED_FOR_SLOT_FILLING = 2
          end
        end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::ListIntents Intents::ListIntents}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The agent to list all intents from.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language to list training phrases, parameters and rich
        #     messages for. If not specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent before they can be used.
        # @!attribute [rw] intent_view
        #   @return [Google::Cloud::Dialogflow::V2::IntentView]
        #     Optional. The resource view to apply to the returned intent.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. The maximum number of items to return in a single page. By
        #     default 100 and at most 1000.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. The next_page_token value returned from a previous list request.
        class ListIntentsRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::Intents::ListIntents Intents::ListIntents}.
        # @!attribute [rw] intents
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent>]
        #     The list of agent intents. There will be a maximum number of items
        #     returned based on the page_size field in the request.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     Token to retrieve the next page of results, or empty if there are no
        #     more results in the list.
        class ListIntentsResponse; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::GetIntent Intents::GetIntent}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the intent.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language to retrieve training phrases, parameters and rich
        #     messages for. If not specified, the agent's default language is used.
        #     [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] intent_view
        #   @return [Google::Cloud::Dialogflow::V2::IntentView]
        #     Optional. The resource view to apply to the returned intent.
        class GetIntentRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::CreateIntent Intents::CreateIntent}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The agent to create a intent for.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] intent
        #   @return [Google::Cloud::Dialogflow::V2::Intent]
        #     Required. The intent to create.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of training phrases, parameters and rich messages
        #     defined in +intent+. If not specified, the agent's default language is
        #     used. [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] intent_view
        #   @return [Google::Cloud::Dialogflow::V2::IntentView]
        #     Optional. The resource view to apply to the returned intent.
        class CreateIntentRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::UpdateIntent Intents::UpdateIntent}.
        # @!attribute [rw] intent
        #   @return [Google::Cloud::Dialogflow::V2::Intent]
        #     Required. The intent to update.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of training phrases, parameters and rich messages
        #     defined in +intent+. If not specified, the agent's default language is
        #     used. [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        # @!attribute [rw] intent_view
        #   @return [Google::Cloud::Dialogflow::V2::IntentView]
        #     Optional. The resource view to apply to the returned intent.
        class UpdateIntentRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::DeleteIntent Intents::DeleteIntent}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The name of the intent to delete.
        #     Format: +projects/<Project ID>/agent/intents/<Intent ID>+.
        class DeleteIntentRequest; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::BatchUpdateIntents Intents::BatchUpdateIntents}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the agent to update or create intents in.
        #     Format: +projects/<Project ID>/agent+.
        # @!attribute [rw] intent_batch_uri
        #   @return [String]
        #     The URI to a Google Cloud Storage file containing intents to update or
        #     create. The file format can either be a serialized proto (of IntentBatch
        #     type) or JSON object. Note: The URI must start with "gs://".
        # @!attribute [rw] intent_batch_inline
        #   @return [Google::Cloud::Dialogflow::V2::IntentBatch]
        #     The collection of intents to update or create.
        # @!attribute [rw] language_code
        #   @return [String]
        #     Optional. The language of training phrases, parameters and rich messages
        #     defined in +intents+. If not specified, the agent's default language is
        #     used. [More than a dozen
        #     languages](https://dialogflow.com/docs/reference/language) are supported.
        #     Note: languages must be enabled in the agent, before they can be used.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Optional. The mask to control which fields get updated.
        # @!attribute [rw] intent_view
        #   @return [Google::Cloud::Dialogflow::V2::IntentView]
        #     Optional. The resource view to apply to the returned intent.
        class BatchUpdateIntentsRequest; end

        # The response message for {Google::Cloud::Dialogflow::V2::Intents::BatchUpdateIntents Intents::BatchUpdateIntents}.
        # @!attribute [rw] intents
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent>]
        #     The collection of updated or created intents.
        class BatchUpdateIntentsResponse; end

        # The request message for {Google::Cloud::Dialogflow::V2::Intents::BatchDeleteIntents Intents::BatchDeleteIntents}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the agent to delete all entities types for. Format:
        #     +projects/<Project ID>/agent+.
        # @!attribute [rw] intents
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent>]
        #     Required. The collection of intents to delete. Only intent +name+ must be
        #     filled in.
        class BatchDeleteIntentsRequest; end

        # This message is a wrapper around a collection of intents.
        # @!attribute [rw] intents
        #   @return [Array<Google::Cloud::Dialogflow::V2::Intent>]
        #     A collection of intents.
        class IntentBatch; end

        # Represents the options for views of an intent.
        # An intent can be a sizable object. Therefore, we provide a resource view that
        # does not return training phrases in the response by default.
        module IntentView
          # Training phrases field is not populated in the response.
          INTENT_VIEW_UNSPECIFIED = 0

          # All fields are populated.
          INTENT_VIEW_FULL = 1
        end
      end
    end
  end
end