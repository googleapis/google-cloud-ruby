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
    module Kms
      module V1
        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListKeyRings KeyManagementService::ListKeyRings}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the location associated with the
        #     {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format +projects/*/locations/*+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional limit on the number of {Google::Cloud::Kms::V1::KeyRing KeyRings} to include in the
        #     response.  Further {Google::Cloud::Kms::V1::KeyRing KeyRings} can subsequently be obtained by
        #     including the {Google::Cloud::Kms::V1::ListKeyRingsResponse#next_page_token ListKeyRingsResponse#next_page_token} in a subsequent
        #     request.  If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListKeyRingsResponse#next_page_token ListKeyRingsResponse#next_page_token}.
        class ListKeyRingsRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeys KeyManagementService::ListCryptoKeys}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to list, in the format
        #     +projects/*/locations/*/keyRings/*+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional limit on the number of {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} to include in the
        #     response.  Further {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} can subsequently be obtained by
        #     including the {Google::Cloud::Kms::V1::ListCryptoKeysResponse#next_page_token ListCryptoKeysResponse#next_page_token} in a subsequent
        #     request.  If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListCryptoKeysResponse#next_page_token ListCryptoKeysResponse#next_page_token}.
        class ListCryptoKeysRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeyVersions KeyManagementService::ListCryptoKeyVersions}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to list, in the format
        #     +projects/*/locations/*/keyRings/*/cryptoKeys/*+.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional limit on the number of {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions} to
        #     include in the response. Further {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions} can
        #     subsequently be obtained by including the
        #     {Google::Cloud::Kms::V1::ListCryptoKeyVersionsResponse#next_page_token ListCryptoKeyVersionsResponse#next_page_token} in a subsequent request.
        #     If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListCryptoKeyVersionsResponse#next_page_token ListCryptoKeyVersionsResponse#next_page_token}.
        class ListCryptoKeyVersionsRequest; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::ListKeyRings KeyManagementService::ListKeyRings}.
        # @!attribute [rw] key_rings
        #   @return [Array<Google::Cloud::Kms::V1::KeyRing>]
        #     The list of {Google::Cloud::Kms::V1::KeyRing KeyRings}.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve next page of results. Pass this value in
        #     {Google::Cloud::Kms::V1::ListKeyRingsRequest#page_token ListKeyRingsRequest#page_token} to retrieve the next page of results.
        # @!attribute [rw] total_size
        #   @return [Integer]
        #     The total number of {Google::Cloud::Kms::V1::KeyRing KeyRings} that matched the query.
        class ListKeyRingsResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeys KeyManagementService::ListCryptoKeys}.
        # @!attribute [rw] crypto_keys
        #   @return [Array<Google::Cloud::Kms::V1::CryptoKey>]
        #     The list of {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve next page of results. Pass this value in
        #     {Google::Cloud::Kms::V1::ListCryptoKeysRequest#page_token ListCryptoKeysRequest#page_token} to retrieve the next page of results.
        # @!attribute [rw] total_size
        #   @return [Integer]
        #     The total number of {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} that matched the query.
        class ListCryptoKeysResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeyVersions KeyManagementService::ListCryptoKeyVersions}.
        # @!attribute [rw] crypto_key_versions
        #   @return [Array<Google::Cloud::Kms::V1::CryptoKeyVersion>]
        #     The list of {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve next page of results. Pass this value in
        #     {Google::Cloud::Kms::V1::ListCryptoKeyVersionsRequest#page_token ListCryptoKeyVersionsRequest#page_token} to retrieve the next page of
        #     results.
        # @!attribute [rw] total_size
        #   @return [Integer]
        #     The total number of {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions} that matched the
        #     query.
        class ListCryptoKeyVersionsResponse; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetKeyRing KeyManagementService::GetKeyRing}.
        # @!attribute [rw] name
        #   @return [String]
        #     The {Google::Cloud::Kms::V1::KeyRing#name name} of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to get.
        class GetKeyRingRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetCryptoKey KeyManagementService::GetCryptoKey}.
        # @!attribute [rw] name
        #   @return [String]
        #     The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to get.
        class GetCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetCryptoKeyVersion KeyManagementService::GetCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     The {Google::Cloud::Kms::V1::CryptoKeyVersion#name name} of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to get.
        class GetCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateKeyRing KeyManagementService::CreateKeyRing}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the location associated with the
        #     {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format +projects/*/locations/*+.
        # @!attribute [rw] key_ring_id
        #   @return [String]
        #     Required. It must be unique within a location and match the regular
        #     expression +[a-zA-Z0-9_-]\\{1,63}+
        # @!attribute [rw] key_ring
        #   @return [Google::Cloud::Kms::V1::KeyRing]
        #     A {Google::Cloud::Kms::V1::KeyRing KeyRing} with initial field values.
        class CreateKeyRingRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKey KeyManagementService::CreateCryptoKey}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::KeyRing#name name} of the KeyRing associated with the
        #     {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
        # @!attribute [rw] crypto_key_id
        #   @return [String]
        #     Required. It must be unique within a KeyRing and match the regular
        #     expression +[a-zA-Z0-9_-]\\{1,63}+
        # @!attribute [rw] crypto_key
        #   @return [Google::Cloud::Kms::V1::CryptoKey]
        #     A {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with initial field values.
        class CreateCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKeyVersion KeyManagementService::CreateCryptoKeyVersion}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} associated with
        #     the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}.
        # @!attribute [rw] crypto_key_version
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
        #     A {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with initial field values.
        class CreateCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKey KeyManagementService::UpdateCryptoKey}.
        # @!attribute [rw] crypto_key
        #   @return [Google::Cloud::Kms::V1::CryptoKey]
        #     {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with updated values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Required list of fields to be updated in this request.
        class UpdateCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyVersion KeyManagementService::UpdateCryptoKeyVersion}.
        # @!attribute [rw] crypto_key_version
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
        #     {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with updated values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Required list of fields to be updated in this request.
        class UpdateCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::Encrypt KeyManagementService::Encrypt}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} or {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}
        #     to use for encryption.
        #
        #     If a {Google::Cloud::Kms::V1::CryptoKey CryptoKey} is specified, the server will use its
        #     {Google::Cloud::Kms::V1::CryptoKey#primary primary version}.
        # @!attribute [rw] plaintext
        #   @return [String]
        #     Required. The data to encrypt. Must be no larger than 64KiB.
        # @!attribute [rw] additional_authenticated_data
        #   @return [String]
        #     Optional data that, if specified, must also be provided during decryption
        #     through {Google::Cloud::Kms::V1::DecryptRequest#additional_authenticated_data DecryptRequest#additional_authenticated_data}.  Must be no
        #     larger than 64KiB.
        class EncryptRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::Decrypt KeyManagementService::Decrypt}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to use for decryption.
        #     The server will choose the appropriate version.
        # @!attribute [rw] ciphertext
        #   @return [String]
        #     Required. The encrypted data originally returned in
        #     {Google::Cloud::Kms::V1::EncryptResponse#ciphertext EncryptResponse#ciphertext}.
        # @!attribute [rw] additional_authenticated_data
        #   @return [String]
        #     Optional data that must match the data originally supplied in
        #     {Google::Cloud::Kms::V1::EncryptRequest#additional_authenticated_data EncryptRequest#additional_authenticated_data}.
        class DecryptRequest; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::Decrypt KeyManagementService::Decrypt}.
        # @!attribute [rw] plaintext
        #   @return [String]
        #     The decrypted data originally supplied in {Google::Cloud::Kms::V1::EncryptRequest#plaintext EncryptRequest#plaintext}.
        class DecryptResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::Encrypt KeyManagementService::Encrypt}.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} used in encryption.
        # @!attribute [rw] ciphertext
        #   @return [String]
        #     The encrypted data.
        class EncryptResponse; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyPrimaryVersion KeyManagementService::UpdateCryptoKeyPrimaryVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to update.
        # @!attribute [rw] crypto_key_version_id
        #   @return [String]
        #     The id of the child {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to use as primary.
        class UpdateCryptoKeyPrimaryVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::DestroyCryptoKeyVersion KeyManagementService::DestroyCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to destroy.
        class DestroyCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::RestoreCryptoKeyVersion KeyManagementService::RestoreCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to restore.
        class RestoreCryptoKeyVersionRequest; end
      end
    end
  end
end