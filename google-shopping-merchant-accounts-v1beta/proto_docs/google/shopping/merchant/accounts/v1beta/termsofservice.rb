# frozen_string_literal: true

# Copyright 2024 Google LLC
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
  module Shopping
    module Merchant
      module Accounts
        module V1beta
          # A `TermsOfService`.
          # @!attribute [rw] name
          #   @return [::String]
          #     Identifier. The resource name of the terms of service version.
          #     Format: `termsOfService/{version}`
          # @!attribute [rw] region_code
          #   @return [::String]
          #     Region code as defined by [CLDR](https://cldr.unicode.org/). This is either
          #     a country where the ToS applies specifically to that country or `001` when
          #     the same `TermsOfService` can be signed in any country. However note that
          #     when signing a ToS that applies globally we still expect that a specific
          #     country is provided  (this should be merchant business country or program
          #     country of participation).
          # @!attribute [rw] kind
          #   @return [::Google::Shopping::Merchant::Accounts::V1beta::TermsOfServiceKind]
          #     The Kind this terms of service version applies to.
          # @!attribute [rw] file_uri
          #   @return [::String]
          #     URI for terms of service file that needs to be displayed to signing users.
          # @!attribute [rw] external
          #   @return [::Boolean]
          #     Whether this terms of service version is external. External terms of
          #     service versions can only be agreed through external processes and not
          #     directly by the merchant through UI or API.
          class TermsOfService
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request message for the `GetTermsOfService` method.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. The resource name of the terms of service version.
          #     Format: `termsOfService/{version}`
          class GetTermsOfServiceRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request message for the `RetrieveLatestTermsOfService` method.
          # @!attribute [rw] region_code
          #   @return [::String]
          #     Required. Region code as defined by [CLDR](https://cldr.unicode.org/). This
          #     is either a country when the ToS applies specifically to that country or
          #     001 when it applies globally.
          # @!attribute [rw] kind
          #   @return [::Google::Shopping::Merchant::Accounts::V1beta::TermsOfServiceKind]
          #     Required. The Kind this terms of service version applies to.
          class RetrieveLatestTermsOfServiceRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Request message for the `AcceptTermsOfService` method.
          # @!attribute [rw] name
          #   @return [::String]
          #     Required. The resource name of the terms of service version.
          #     Format: `termsOfService/{version}`
          # @!attribute [rw] account
          #   @return [::String]
          #     Required. The account for which to accept the ToS.
          # @!attribute [rw] region_code
          #   @return [::String]
          #     Required. Region code as defined by [CLDR](https://cldr.unicode.org/). This
          #     is either a country when the ToS applies specifically to that country or
          #     001 when it applies globally.
          class AcceptTermsOfServiceRequest
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end
      end
    end
  end
end
