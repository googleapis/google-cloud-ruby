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
        def initialize storage_service
          require "google/apis/iamcredentials_v1"

          @client = Google::Apis::IamcredentialsV1::IAMCredentialsService.new
          
          api_service = storage_service.service
          @client.client_options.open_timeout_sec = api_service.client_options.open_timeout_sec
          @client.client_options.read_timeout_sec = api_service.client_options.read_timeout_sec
          @client.client_options.send_timeout_sec = api_service.client_options.send_timeout_sec

          if api_service.request_options.quota_project
            @client.request_options.quota_project = api_service.request_options.quota_project
          end

          if api_service.respond_to?(:universe_domain) && api_service.universe_domain
            @client.universe_domain = api_service.universe_domain
          end

          auth_client = storage_service.credentials.client
          if auth_client.respond_to? :duplicate
            @client.authorization = auth_client.duplicate scope: ["https://www.googleapis.com/auth/iam"]
          else
            @client.authorization = auth_client
          end
        end

        def sign issuer, string_to_sign
          request = Google::Apis::IamcredentialsV1::SignBlobRequest.new(
            payload: string_to_sign
          )
          resource = "projects/-/serviceAccounts/#{issuer}"

          begin
            response = @client.sign_service_account_blob resource, request
            response.signed_blob
          rescue Google::Apis::Error => e
            raise Google::Cloud::Storage::SignedUrlUnavailable, "Failed to sign URL via IAM Credentials API. Ensure the Workload Identity service account has the 'Service Account Token Creator' role. Underlying error: #{e.message}"
          end
        end
      end
    end
  end
end
