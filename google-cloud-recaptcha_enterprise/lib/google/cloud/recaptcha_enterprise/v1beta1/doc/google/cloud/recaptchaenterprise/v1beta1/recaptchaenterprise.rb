# Copyright 2019 Google LLC
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
    module Recaptchaenterprise
      module V1beta1
        # The create assessment request message.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The name of the project in which the assessment will be created,
        #     in the format "projects/\\{project_number}".
        # @!attribute [rw] assessment
        #   @return [Google::Cloud::Recaptchaenterprise::V1beta1::Assessment]
        #     The asessment details.
        class CreateAssessmentRequest; end

        # The request message to annotate an Assessment.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the Assessment, in the format
        #     "projects/\\{project_number}/assessments/\\{assessment_id}".
        # @!attribute [rw] annotation
        #   @return [Google::Cloud::Recaptchaenterprise::V1beta1::AnnotateAssessmentRequest::Annotation]
        #     The annotation that will be assigned to the Event.
        class AnnotateAssessmentRequest
          # Enum that reprensents the types of annotations.
          module Annotation
            # Default unspecified type.
            ANNOTATION_UNSPECIFIED = 0

            # Provides information that the event turned out to be legitimate.
            LEGITIMATE = 1

            # Provides information that the event turned out to be fraudulent.
            FRAUDULENT = 2
          end
        end

        # Empty response for AnnotateAssessment.
        class AnnotateAssessmentResponse; end

        # A recaptcha assessment resource.
        # @!attribute [rw] name
        #   @return [String]
        #     Output only. The resource name for the Assessment in the format
        #     "projects/\\{project_number}/assessments/\\{assessment_id}".
        # @!attribute [rw] event
        #   @return [Google::Cloud::Recaptchaenterprise::V1beta1::Event]
        #     The event being assessed.
        # @!attribute [rw] score
        #   @return [Float]
        #     Output only. Legitimate event score from 0.0 to 1.0.
        #     (1.0 means very likely legitimate traffic while 0.0 means very likely
        #     non-legitimate traffic).
        # @!attribute [rw] token_properties
        #   @return [Google::Cloud::Recaptchaenterprise::V1beta1::TokenProperties]
        #     Output only. Properties of the provided event token.
        # @!attribute [rw] reasons
        #   @return [Array<Google::Cloud::Recaptchaenterprise::V1beta1::Assessment::ClassificationReason>]
        #     Output only. Reasons contributing to the risk analysis verdict.
        class Assessment
          # LINT.IfChange(classification_reason)
          # Reasons contributing to the risk analysis verdict.
          module ClassificationReason
            # Default unspecified type.
            CLASSIFICATION_REASON_UNSPECIFIED = 0

            # The event appeared to be automated.
            AUTOMATION = 1

            # The event was not made from the proper context on the real site.
            UNEXPECTED_ENVIRONMENT = 2

            # Browsing behavior leading up to the event was generated was out of the
            # ordinary.
            UNEXPECTED_USAGE_PATTERNS = 4

            # Too little traffic has been received from this site thus far to generate
            # quality risk analysis.
            PROVISIONAL_RISK_ANALYSIS = 5
          end
        end

        # @!attribute [rw] token
        #   @return [String]
        #     The user response token provided by the reCAPTCHA client-side integration
        #     on your site.
        # @!attribute [rw] site_key
        #   @return [String]
        #     The site key that was used to invoke reCAPTCHA on your site and generate
        #     the token.
        class Event; end

        # @!attribute [rw] valid
        #   @return [true, false]
        #     Output only. Whether the provided user response token is valid.
        # @!attribute [rw] invalid_reason
        #   @return [Google::Cloud::Recaptchaenterprise::V1beta1::TokenProperties::InvalidReason]
        #     Output only. Reason associated with the response when valid = false.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The timestamp corresponding to the generation of the token.
        # @!attribute [rw] hostname
        #   @return [String]
        #     Output only. The hostname of the page on which the token was generated.
        # @!attribute [rw] action
        #   @return [String]
        #     Output only. Action name provided at token generation.
        class TokenProperties
          # Enum that represents the types of invalid token reasons.
          module InvalidReason
            # Default unspecified type.
            INVALID_REASON_UNSPECIFIED = 0

            # If the failure reason was not accounted for.
            UNKNOWN_INVALID_REASON = 1

            # The provided user verification token was malformed.
            MALFORMED = 2

            # The user verification token had expired.
            EXPIRED = 3

            # The user verification had already been seen.
            DUPE = 4

            # The user verification token did not match the provided site secret.
            # This may be a configuration error (e.g. development keys used in
            # production) or end users trying to use verification tokens from other
            # sites.
            SITE_MISMATCH = 5

            # The user verification token was not present.  It is a required input.
            MISSING = 6
          end
        end
      end
    end
  end
end