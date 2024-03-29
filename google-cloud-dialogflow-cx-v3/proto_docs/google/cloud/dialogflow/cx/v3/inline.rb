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
    module Dialogflow
      module CX
        module V3
          # Inline destination for a Dialogflow operation that writes or exports objects
          # (e.g. {::Google::Cloud::Dialogflow::CX::V3::Intent intents}) outside of Dialogflow.
          # @!attribute [r] content
          #   @return [::String]
          #     Output only. The uncompressed byte content for the objects.
          #     Only populated in responses.
          class InlineDestination
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Inline source for a Dialogflow operation that reads or imports objects
          # (e.g. {::Google::Cloud::Dialogflow::CX::V3::Intent intents}) into Dialogflow.
          # @!attribute [rw] content
          #   @return [::String]
          #     The uncompressed byte content for the objects.
          class InlineSource
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end
      end
    end
  end
end
