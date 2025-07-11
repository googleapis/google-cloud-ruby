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
    module Dialogflow
      module CX
        module V3
          # A fulfillment can do one or more of the following actions at the same time:
          #
          #   * Generate rich message responses.
          #   * Set parameter values.
          #   * Call the webhook.
          #
          # Fulfillments can be called at various stages in the
          # {::Google::Cloud::Dialogflow::CX::V3::Page Page} or
          # {::Google::Cloud::Dialogflow::CX::V3::Form Form} lifecycle. For example, when a
          # {::Google::Cloud::Dialogflow::CX::V3::DetectIntentRequest DetectIntentRequest}
          # drives a session to enter a new page, the page's entry fulfillment can add a
          # static response to the
          # {::Google::Cloud::Dialogflow::CX::V3::QueryResult QueryResult} in the returning
          # {::Google::Cloud::Dialogflow::CX::V3::DetectIntentResponse DetectIntentResponse},
          # call the webhook (for example, to load user data from a database), or both.
          # @!attribute [rw] messages
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::ResponseMessage>]
          #     The list of rich message responses to present to the user.
          # @!attribute [rw] webhook
          #   @return [::String]
          #     The webhook to call.
          #     Format:
          #     `projects/<ProjectID>/locations/<LocationID>/agents/<AgentID>/webhooks/<WebhookID>`.
          # @!attribute [rw] return_partial_responses
          #   @return [::Boolean]
          #     Whether Dialogflow should return currently queued fulfillment response
          #     messages in streaming APIs. If a webhook is specified, it happens before
          #     Dialogflow invokes webhook.
          #     Warning:
          #     1) This flag only affects streaming API. Responses are still queued
          #     and returned once in non-streaming API.
          #     2) The flag can be enabled in any fulfillment but only the first 3 partial
          #     responses will be returned. You may only want to apply it to fulfillments
          #     that have slow webhooks.
          # @!attribute [rw] tag
          #   @return [::String]
          #     The value of this field will be populated in the
          #     {::Google::Cloud::Dialogflow::CX::V3::WebhookRequest WebhookRequest}
          #     `fulfillmentInfo.tag` field by Dialogflow when the associated webhook is
          #     called.
          #     The tag is typically used by the webhook service to identify which
          #     fulfillment is being called, but it could be used for other purposes.
          #     This field is required if `webhook` is specified.
          # @!attribute [rw] set_parameter_actions
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::Fulfillment::SetParameterAction>]
          #     Set parameter values before executing the webhook.
          # @!attribute [rw] conditional_cases
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::Fulfillment::ConditionalCases>]
          #     Conditional cases for this fulfillment.
          # @!attribute [rw] advanced_settings
          #   @return [::Google::Cloud::Dialogflow::CX::V3::AdvancedSettings]
          #     Hierarchical advanced settings for this fulfillment. The settings exposed
          #     at the lower level overrides the settings exposed at the higher level.
          # @!attribute [rw] enable_generative_fallback
          #   @return [::Boolean]
          #     If the flag is true, the agent will utilize LLM to generate a text
          #     response. If LLM generation fails, the defined
          #     {::Google::Cloud::Dialogflow::CX::V3::Fulfillment#messages responses} in the
          #     fulfillment will be respected. This flag is only useful for fulfillments
          #     associated with no-match event handlers.
          # @!attribute [rw] generators
          #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::Fulfillment::GeneratorSettings>]
          #     A list of Generators to be called during this fulfillment.
          class Fulfillment
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Setting a parameter value.
            # @!attribute [rw] parameter
            #   @return [::String]
            #     Display name of the parameter.
            # @!attribute [rw] value
            #   @return [::Google::Protobuf::Value]
            #     The new value of the parameter. A null value clears the parameter.
            class SetParameterAction
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods
            end

            # A list of cascading if-else conditions. Cases are mutually exclusive.
            # The first one with a matching condition is selected, all the rest ignored.
            # @!attribute [rw] cases
            #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::Fulfillment::ConditionalCases::Case>]
            #     A list of cascading if-else conditions.
            class ConditionalCases
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # Each case has a Boolean condition. When it is evaluated to be True, the
              # corresponding messages will be selected and evaluated recursively.
              # @!attribute [rw] condition
              #   @return [::String]
              #     The condition to activate and select this case. Empty means the
              #     condition is always true. The condition is evaluated against [form
              #     parameters][Form.parameters] or [session
              #     parameters][SessionInfo.parameters].
              #
              #     See the [conditions
              #     reference](https://cloud.google.com/dialogflow/cx/docs/reference/condition).
              # @!attribute [rw] case_content
              #   @return [::Array<::Google::Cloud::Dialogflow::CX::V3::Fulfillment::ConditionalCases::Case::CaseContent>]
              #     A list of case content.
              class Case
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods

                # The list of messages or conditional cases to activate for this case.
                # @!attribute [rw] message
                #   @return [::Google::Cloud::Dialogflow::CX::V3::ResponseMessage]
                #     Returned message.
                #
                #     Note: The following fields are mutually exclusive: `message`, `additional_cases`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                # @!attribute [rw] additional_cases
                #   @return [::Google::Cloud::Dialogflow::CX::V3::Fulfillment::ConditionalCases]
                #     Additional cases to be evaluated.
                #
                #     Note: The following fields are mutually exclusive: `additional_cases`, `message`. If a field in that set is populated, all other fields in the set will automatically be cleared.
                class CaseContent
                  include ::Google::Protobuf::MessageExts
                  extend ::Google::Protobuf::MessageExts::ClassMethods
                end
              end
            end

            # Generator settings used by the LLM to generate a text response.
            # @!attribute [rw] generator
            #   @return [::String]
            #     Required. The generator to call.
            #     Format:
            #     `projects/<ProjectID>/locations/<LocationID>/agents/<AgentID>/generators/<GeneratorID>`.
            # @!attribute [rw] input_parameters
            #   @return [::Google::Protobuf::Map{::String => ::String}]
            #     Map from [placeholder parameter][Generator.Parameter.id] in the
            #     {::Google::Cloud::Dialogflow::CX::V3::Generator Generator} to corresponding
            #     session parameters. By default, Dialogflow uses the session parameter
            #     with the same name to fill in the generator template. e.g. If there is a
            #     placeholder parameter `city` in the Generator, Dialogflow default to fill
            #     in the `$city` with
            #     `$session.params.city`. However, you may choose to fill `$city` with
            #     `$session.params.desination-city`.
            #     - Map key: [parameter ID][Genrator.Parameter.id]
            #     - Map value: session parameter name
            # @!attribute [rw] output_parameter
            #   @return [::String]
            #     Required. Output parameter which should contain the generator response.
            class GeneratorSettings
              include ::Google::Protobuf::MessageExts
              extend ::Google::Protobuf::MessageExts::ClassMethods

              # @!attribute [rw] key
              #   @return [::String]
              # @!attribute [rw] value
              #   @return [::String]
              class InputParametersEntry
                include ::Google::Protobuf::MessageExts
                extend ::Google::Protobuf::MessageExts::ClassMethods
              end
            end
          end
        end
      end
    end
  end
end
