# frozen_string_literal: true

# Copyright 2020 Google LLC
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
    module Talent
      module V4beta1
        # Auto-complete parameters.
        # @!attribute [rw] parent
        #   @return [::String]
        #     Required. Resource name of tenant the completion is performed within.
        #
        #     The format is "projects/\\{project_id}/tenants/\\{tenant_id}", for example,
        #     "projects/foo/tenant/bar".
        #
        #     If tenant id is unspecified, the default tenant is used, for
        #     example, "projects/foo".
        # @!attribute [rw] query
        #   @return [::String]
        #     Required. The query used to generate suggestions.
        #
        #     The maximum number of allowed characters is 255.
        # @!attribute [rw] language_codes
        #   @return [::Array<::String>]
        #     The list of languages of the query. This is
        #     the BCP-47 language code, such as "en-US" or "sr-Latn".
        #     For more information, see
        #     [Tags for Identifying Languages](https://tools.ietf.org/html/bcp47).
        #
        #     The maximum number of allowed characters is 255.
        # @!attribute [rw] page_size
        #   @return [::Integer]
        #     Required. Completion result count.
        #
        #     The maximum allowed page size is 10.
        # @!attribute [rw] company
        #   @return [::String]
        #     If provided, restricts completion to specified company.
        #
        #     The format is
        #     "projects/\\{project_id}/tenants/\\{tenant_id}/companies/\\{company_id}", for
        #     example, "projects/foo/tenants/bar/companies/baz".
        #
        #     If tenant id is unspecified, the default tenant is used, for
        #     example, "projects/foo".
        # @!attribute [rw] scope
        #   @return [::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionScope]
        #     The scope of the completion. The defaults is
        #     {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionScope::PUBLIC CompletionScope.PUBLIC}.
        # @!attribute [rw] type
        #   @return [::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType]
        #     The completion topic. The default is
        #     {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType::COMBINED CompletionType.COMBINED}.
        class CompleteQueryRequest
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Enum to specify the scope of completion.
          module CompletionScope
            # Default value.
            COMPLETION_SCOPE_UNSPECIFIED = 0

            # Suggestions are based only on the data provided by the client.
            TENANT = 1

            # Suggestions are based on all jobs data in the system that's visible to
            # the client
            PUBLIC = 2
          end

          # Enum to specify auto-completion topics.
          module CompletionType
            # Default value.
            COMPLETION_TYPE_UNSPECIFIED = 0

            # Suggest job titles for jobs autocomplete.
            #
            # For
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType::JOB_TITLE CompletionType.JOB_TITLE}
            # type, only open jobs with the same
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest#language_codes language_codes}
            # are returned.
            JOB_TITLE = 1

            # Suggest company names for jobs autocomplete.
            #
            # For
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType::COMPANY_NAME CompletionType.COMPANY_NAME}
            # type, only companies having open jobs with the same
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest#language_codes language_codes}
            # are returned.
            COMPANY_NAME = 2

            # Suggest both job titles and company names for jobs autocomplete.
            #
            # For
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType::COMBINED CompletionType.COMBINED}
            # type, only open jobs with the same
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest#language_codes language_codes}
            # or companies having open jobs with the same
            # {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest#language_codes language_codes}
            # are returned.
            COMBINED = 3
          end
        end

        # Response of auto-complete query.
        # @!attribute [rw] completion_results
        #   @return [::Array<::Google::Cloud::Talent::V4beta1::CompleteQueryResponse::CompletionResult>]
        #     Results of the matching job/company candidates.
        # @!attribute [rw] metadata
        #   @return [::Google::Cloud::Talent::V4beta1::ResponseMetadata]
        #     Additional information for the API invocation, such as the request
        #     tracking id.
        class CompleteQueryResponse
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Resource that represents completion results.
          # @!attribute [rw] suggestion
          #   @return [::String]
          #     The suggestion for the query.
          # @!attribute [rw] type
          #   @return [::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType]
          #     The completion topic.
          # @!attribute [rw] image_uri
          #   @return [::String]
          #     The URI of the company image for
          #     {::Google::Cloud::Talent::V4beta1::CompleteQueryRequest::CompletionType::COMPANY_NAME COMPANY_NAME}.
          class CompletionResult
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end
      end
    end
  end
end
