# frozen_string_literal: true

# Copyright 2026 Google LLC
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

require "googleauth"

module Google
  module Cloud
    module Storage
      ##
      # @private
      # Helper class for signing blobs via the IAM Credentials API.
      class IAMSigner
        def initialize
          require "google/apis/iamcredentials_v1"

          @client = Google::Apis::IamcredentialsV1::IAMCredentialsService.new
          @client.authorization = Google::Auth.get_application_default(
            ["https://www.googleapis.com/auth/iam"]
          )
        end

        def sign issuer, string_to_sign
          request = Google::Apis::IamcredentialsV1::SignBlobRequest.new(
            payload: string_to_sign
          )
          resource = "projects/-/serviceAccounts/#{issuer}"

          response = @client.sign_service_account_blob resource, request

          response.signed_blob
        end
      end
    end
  end
end
