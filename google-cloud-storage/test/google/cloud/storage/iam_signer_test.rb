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

require "helper"
require "google/cloud/storage/iam_signer"
require "google/apis/iamcredentials_v1"

describe Google::Cloud::Storage::IAMSigner do
  it "signs a payload using IAMCredentialsService" do
    issuer = "test@email.com"
    payload = "my-payload"
    expected_resource = "projects/-/serviceAccounts/test@email.com"
    expected_signature = "mocked-signature"

    mock_auth = Minitest::Mock.new
    
    mock_response = Minitest::Mock.new
    mock_response.expect :signed_blob, expected_signature

    mock_service = Minitest::Mock.new
    mock_client_options = OpenStruct.new
    mock_service.expect :client_options, mock_client_options
    mock_service.expect :client_options, mock_client_options
    mock_service.expect :client_options, mock_client_options
    mock_service.expect :request_options, OpenStruct.new
    mock_service.expect :universe_domain=, nil, ["googleapis.com"]
    mock_service.expect :authorization=, nil, [mock_auth]
    mock_service.expect :sign_service_account_blob, mock_response do |resource, request|
      resource == expected_resource && request.payload == payload
    end

    mock_credentials = OpenStruct.new client: mock_auth
    api_service = OpenStruct.new(
      client_options: OpenStruct.new(open_timeout_sec: 60, read_timeout_sec: 60, send_timeout_sec: 60),
      request_options: OpenStruct.new(quota_project: "test_project"),
      universe_domain: "googleapis.com"
    )
    mock_storage_service = OpenStruct.new(
      credentials: mock_credentials,
      service: api_service
    )

    Google::Apis::IamcredentialsV1::IAMCredentialsService.stub :new, mock_service do
      signer = Google::Cloud::Storage::IAMSigner.new mock_storage_service
      signature = signer.sign issuer, payload

      _(signature).must_equal expected_signature
    end

    mock_service.verify
    mock_response.verify
  end
end
