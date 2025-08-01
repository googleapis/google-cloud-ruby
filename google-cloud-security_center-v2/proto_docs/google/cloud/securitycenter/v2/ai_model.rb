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
    module SecurityCenter
      module V2
        # Contains information about the AI model associated with the finding.
        # @!attribute [rw] name
        #   @return [::String]
        #     The name of the AI model, for example, "gemini:1.0.0".
        # @!attribute [rw] domain
        #   @return [::String]
        #     The domain of the model, for example, “image-classification”.
        # @!attribute [rw] library
        #   @return [::String]
        #     The name of the model library, for example, “transformers”.
        # @!attribute [rw] location
        #   @return [::String]
        #     The region in which the model is used, for example, “us-central1”.
        # @!attribute [rw] publisher
        #   @return [::String]
        #     The publisher of the model, for example, “google” or “nvidia”.
        # @!attribute [rw] deployment_platform
        #   @return [::Google::Cloud::SecurityCenter::V2::AiModel::DeploymentPlatform]
        #     The platform on which the model is deployed.
        # @!attribute [rw] display_name
        #   @return [::String]
        #     The user defined display name of model. Ex. baseline-classification-model
        class AiModel
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # The platform on which the model is deployed.
          module DeploymentPlatform
            # Unspecified deployment platform.
            DEPLOYMENT_PLATFORM_UNSPECIFIED = 0

            # Vertex AI.
            VERTEX_AI = 1

            # Google Kubernetes Engine.
            GKE = 2
          end
        end
      end
    end
  end
end
