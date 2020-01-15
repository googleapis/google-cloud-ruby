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


module Google
  module Cloud
    module Kms
      module V1
        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListKeyRings KeyManagementService::ListKeyRings}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the location associated with the
        #     {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format `projects/*/locations/*`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. Optional limit on the number of {Google::Cloud::Kms::V1::KeyRing KeyRings} to include in the
        #     response.  Further {Google::Cloud::Kms::V1::KeyRing KeyRings} can subsequently be obtained by
        #     including the {Google::Cloud::Kms::V1::ListKeyRingsResponse#next_page_token ListKeyRingsResponse#next_page_token} in a subsequent
        #     request.  If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListKeyRingsResponse#next_page_token ListKeyRingsResponse#next_page_token}.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional. Only include resources that match the filter in the response. For
        #     more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional. Specify how the results should be sorted. If not specified, the
        #     results will be sorted in the default order.  For more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        class ListKeyRingsRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeys KeyManagementService::ListCryptoKeys}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to list, in the format
        #     `projects/*/locations/*/keyRings/*`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. Optional limit on the number of {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} to include in the
        #     response.  Further {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} can subsequently be obtained by
        #     including the {Google::Cloud::Kms::V1::ListCryptoKeysResponse#next_page_token ListCryptoKeysResponse#next_page_token} in a subsequent
        #     request.  If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListCryptoKeysResponse#next_page_token ListCryptoKeysResponse#next_page_token}.
        # @!attribute [rw] version_view
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionView]
        #     The fields of the primary version to include in the response.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional. Only include resources that match the filter in the response. For
        #     more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional. Specify how the results should be sorted. If not specified, the
        #     results will be sorted in the default order. For more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        class ListCryptoKeysRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListCryptoKeyVersions KeyManagementService::ListCryptoKeyVersions}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to list, in the format
        #     `projects/*/locations/*/keyRings/*/cryptoKeys/*`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. Optional limit on the number of {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions} to
        #     include in the response. Further {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions} can
        #     subsequently be obtained by including the
        #     {Google::Cloud::Kms::V1::ListCryptoKeyVersionsResponse#next_page_token ListCryptoKeyVersionsResponse#next_page_token} in a subsequent request.
        #     If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListCryptoKeyVersionsResponse#next_page_token ListCryptoKeyVersionsResponse#next_page_token}.
        # @!attribute [rw] view
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionView]
        #     The fields to include in the response.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional. Only include resources that match the filter in the response. For
        #     more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional. Specify how the results should be sorted. If not specified, the
        #     results will be sorted in the default order. For more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        class ListCryptoKeyVersionsRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ListImportJobs KeyManagementService::ListImportJobs}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to list, in the format
        #     `projects/*/locations/*/keyRings/*`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Optional. Optional limit on the number of {Google::Cloud::Kms::V1::ImportJob ImportJobs} to include in the
        #     response. Further {Google::Cloud::Kms::V1::ImportJob ImportJobs} can subsequently be obtained by
        #     including the {Google::Cloud::Kms::V1::ListImportJobsResponse#next_page_token ListImportJobsResponse#next_page_token} in a subsequent
        #     request. If unspecified, the server will pick an appropriate default.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Optional. Optional pagination token, returned earlier via
        #     {Google::Cloud::Kms::V1::ListImportJobsResponse#next_page_token ListImportJobsResponse#next_page_token}.
        # @!attribute [rw] filter
        #   @return [String]
        #     Optional. Only include resources that match the filter in the response. For
        #     more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        # @!attribute [rw] order_by
        #   @return [String]
        #     Optional. Specify how the results should be sorted. If not specified, the
        #     results will be sorted in the default order. For more information, see
        #     [Sorting and filtering list
        #     results](https://cloud.google.com/kms/docs/sorting-and-filtering).
        class ListImportJobsRequest; end

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

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::ListImportJobs KeyManagementService::ListImportJobs}.
        # @!attribute [rw] import_jobs
        #   @return [Array<Google::Cloud::Kms::V1::ImportJob>]
        #     The list of {Google::Cloud::Kms::V1::ImportJob ImportJobs}.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     A token to retrieve next page of results. Pass this value in
        #     {Google::Cloud::Kms::V1::ListImportJobsRequest#page_token ListImportJobsRequest#page_token} to retrieve the next page of results.
        # @!attribute [rw] total_size
        #   @return [Integer]
        #     The total number of {Google::Cloud::Kms::V1::ImportJob ImportJobs} that matched the query.
        class ListImportJobsResponse; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetKeyRing KeyManagementService::GetKeyRing}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::KeyRing#name name} of the {Google::Cloud::Kms::V1::KeyRing KeyRing} to get.
        class GetKeyRingRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetCryptoKey KeyManagementService::GetCryptoKey}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to get.
        class GetCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetCryptoKeyVersion KeyManagementService::GetCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKeyVersion#name name} of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to get.
        class GetCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetPublicKey KeyManagementService::GetPublicKey}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKeyVersion#name name} of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} public key to
        #     get.
        class GetPublicKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::GetImportJob KeyManagementService::GetImportJob}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::ImportJob#name name} of the {Google::Cloud::Kms::V1::ImportJob ImportJob} to get.
        class GetImportJobRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateKeyRing KeyManagementService::CreateKeyRing}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The resource name of the location associated with the
        #     {Google::Cloud::Kms::V1::KeyRing KeyRings}, in the format `projects/*/locations/*`.
        # @!attribute [rw] key_ring_id
        #   @return [String]
        #     Required. It must be unique within a location and match the regular
        #     expression `[a-zA-Z0-9_-]{1,63}`
        # @!attribute [rw] key_ring
        #   @return [Google::Cloud::Kms::V1::KeyRing]
        #     Required. A {Google::Cloud::Kms::V1::KeyRing KeyRing} with initial field values.
        class CreateKeyRingRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKey KeyManagementService::CreateCryptoKey}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::KeyRing#name name} of the KeyRing associated with the
        #     {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
        # @!attribute [rw] crypto_key_id
        #   @return [String]
        #     Required. It must be unique within a KeyRing and match the regular
        #     expression `[a-zA-Z0-9_-]{1,63}`
        # @!attribute [rw] crypto_key
        #   @return [Google::Cloud::Kms::V1::CryptoKey]
        #     Required. A {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with initial field values.
        # @!attribute [rw] skip_initial_version_creation
        #   @return [true, false]
        #     If set to true, the request will create a {Google::Cloud::Kms::V1::CryptoKey CryptoKey} without any
        #     {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}. You must manually call
        #     {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKeyVersion CreateCryptoKeyVersion} or
        #     {Google::Cloud::Kms::V1::KeyManagementService::ImportCryptoKeyVersion ImportCryptoKeyVersion}
        #     before you can use this {Google::Cloud::Kms::V1::CryptoKey CryptoKey}.
        class CreateCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKeyVersion KeyManagementService::CreateCryptoKeyVersion}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} associated with
        #     the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersions}.
        # @!attribute [rw] crypto_key_version
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
        #     Required. A {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with initial field values.
        class CreateCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::ImportCryptoKeyVersion KeyManagementService::ImportCryptoKeyVersion}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKey#name name} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to
        #     be imported into.
        # @!attribute [rw] algorithm
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionAlgorithm]
        #     Required. The {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionAlgorithm algorithm} of
        #     the key being imported. This does not need to match the
        #     {Google::Cloud::Kms::V1::CryptoKey#version_template version_template} of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} this
        #     version imports into.
        # @!attribute [rw] import_job
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::ImportJob#name name} of the {Google::Cloud::Kms::V1::ImportJob ImportJob} that was used to
        #     wrap this key material.
        # @!attribute [rw] rsa_aes_wrapped_key
        #   @return [String]
        #     Wrapped key material produced with
        #     {Google::Cloud::Kms::V1::ImportJob::ImportMethod::RSA_OAEP_3072_SHA1_AES_256 RSA_OAEP_3072_SHA1_AES_256}
        #     or
        #     {Google::Cloud::Kms::V1::ImportJob::ImportMethod::RSA_OAEP_4096_SHA1_AES_256 RSA_OAEP_4096_SHA1_AES_256}.
        #
        #     This field contains the concatenation of two wrapped keys:
        #     <ol>
        #       <li>An ephemeral AES-256 wrapping key wrapped with the
        #           {Google::Cloud::Kms::V1::ImportJob#public_key public_key} using RSAES-OAEP with SHA-1,
        #           MGF1 with SHA-1, and an empty label.
        #       </li>
        #       <li>The key to be imported, wrapped with the ephemeral AES-256 key
        #           using AES-KWP (RFC 5649).
        #       </li>
        #     </ol>
        #
        #     If importing symmetric key material, it is expected that the unwrapped
        #     key contains plain bytes. If importing asymmetric key material, it is
        #     expected that the unwrapped key is in PKCS#8-encoded DER format (the
        #     PrivateKeyInfo structure from RFC 5208).
        #
        #     This format is the same as the format produced by PKCS#11 mechanism
        #     CKM_RSA_AES_KEY_WRAP.
        class ImportCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::CreateImportJob KeyManagementService::CreateImportJob}.
        # @!attribute [rw] parent
        #   @return [String]
        #     Required. The {Google::Cloud::Kms::V1::KeyRing#name name} of the {Google::Cloud::Kms::V1::KeyRing KeyRing} associated with the
        #     {Google::Cloud::Kms::V1::ImportJob ImportJobs}.
        # @!attribute [rw] import_job_id
        #   @return [String]
        #     Required. It must be unique within a KeyRing and match the regular
        #     expression `[a-zA-Z0-9_-]{1,63}`
        # @!attribute [rw] import_job
        #   @return [Google::Cloud::Kms::V1::ImportJob]
        #     Required. An {Google::Cloud::Kms::V1::ImportJob ImportJob} with initial field values.
        class CreateImportJobRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKey KeyManagementService::UpdateCryptoKey}.
        # @!attribute [rw] crypto_key
        #   @return [Google::Cloud::Kms::V1::CryptoKey]
        #     Required. {Google::Cloud::Kms::V1::CryptoKey CryptoKey} with updated values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Required. List of fields to be updated in this request.
        class UpdateCryptoKeyRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyVersion KeyManagementService::UpdateCryptoKeyVersion}.
        # @!attribute [rw] crypto_key_version
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
        #     Required. {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} with updated values.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Required. List of fields to be updated in this request.
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
        #
        #     The maximum size depends on the key version's
        #     {Google::Cloud::Kms::V1::CryptoKeyVersionTemplate#protection_level protection_level}. For
        #     {Google::Cloud::Kms::V1::ProtectionLevel::SOFTWARE SOFTWARE} keys, the plaintext must be no larger
        #     than 64KiB. For {Google::Cloud::Kms::V1::ProtectionLevel::HSM HSM} keys, the combined length of the
        #     plaintext and additional_authenticated_data fields must be no larger than
        #     8KiB.
        # @!attribute [rw] additional_authenticated_data
        #   @return [String]
        #     Optional. Optional data that, if specified, must also be provided during decryption
        #     through {Google::Cloud::Kms::V1::DecryptRequest#additional_authenticated_data DecryptRequest#additional_authenticated_data}.
        #
        #     The maximum size depends on the key version's
        #     {Google::Cloud::Kms::V1::CryptoKeyVersionTemplate#protection_level protection_level}. For
        #     {Google::Cloud::Kms::V1::ProtectionLevel::SOFTWARE SOFTWARE} keys, the AAD must be no larger than
        #     64KiB. For {Google::Cloud::Kms::V1::ProtectionLevel::HSM HSM} keys, the combined length of the
        #     plaintext and additional_authenticated_data fields must be no larger than
        #     8KiB.
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
        #     Optional. Optional data that must match the data originally supplied in
        #     {Google::Cloud::Kms::V1::EncryptRequest#additional_authenticated_data EncryptRequest#additional_authenticated_data}.
        class DecryptRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::AsymmetricSign KeyManagementService::AsymmetricSign}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to use for signing.
        # @!attribute [rw] digest
        #   @return [Google::Cloud::Kms::V1::Digest]
        #     Required. The digest of the data to sign. The digest must be produced with
        #     the same digest algorithm as specified by the key version's
        #     {Google::Cloud::Kms::V1::CryptoKeyVersion#algorithm algorithm}.
        class AsymmetricSignRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::AsymmetricDecrypt KeyManagementService::AsymmetricDecrypt}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to use for
        #     decryption.
        # @!attribute [rw] ciphertext
        #   @return [String]
        #     Required. The data encrypted with the named {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}'s public
        #     key using OAEP.
        class AsymmetricDecryptRequest; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::Decrypt KeyManagementService::Decrypt}.
        # @!attribute [rw] plaintext
        #   @return [String]
        #     The decrypted data originally supplied in {Google::Cloud::Kms::V1::EncryptRequest#plaintext EncryptRequest#plaintext}.
        class DecryptResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::Encrypt KeyManagementService::Encrypt}.
        # @!attribute [rw] name
        #   @return [String]
        #     The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} used in encryption. Check
        #     this field to verify that the intended resource was used for encryption.
        # @!attribute [rw] ciphertext
        #   @return [String]
        #     The encrypted data.
        class EncryptResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::AsymmetricSign KeyManagementService::AsymmetricSign}.
        # @!attribute [rw] signature
        #   @return [String]
        #     The created signature.
        class AsymmetricSignResponse; end

        # Response message for {Google::Cloud::Kms::V1::KeyManagementService::AsymmetricDecrypt KeyManagementService::AsymmetricDecrypt}.
        # @!attribute [rw] plaintext
        #   @return [String]
        #     The decrypted data originally encrypted with the matching public key.
        class AsymmetricDecryptResponse; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyPrimaryVersion KeyManagementService::UpdateCryptoKeyPrimaryVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKey CryptoKey} to update.
        # @!attribute [rw] crypto_key_version_id
        #   @return [String]
        #     Required. The id of the child {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to use as primary.
        class UpdateCryptoKeyPrimaryVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::DestroyCryptoKeyVersion KeyManagementService::DestroyCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to destroy.
        class DestroyCryptoKeyVersionRequest; end

        # Request message for {Google::Cloud::Kms::V1::KeyManagementService::RestoreCryptoKeyVersion KeyManagementService::RestoreCryptoKeyVersion}.
        # @!attribute [rw] name
        #   @return [String]
        #     Required. The resource name of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} to restore.
        class RestoreCryptoKeyVersionRequest; end

        # A {Google::Cloud::Kms::V1::Digest Digest} holds a cryptographic message digest.
        # @!attribute [rw] sha256
        #   @return [String]
        #     A message digest produced with the SHA-256 algorithm.
        # @!attribute [rw] sha384
        #   @return [String]
        #     A message digest produced with the SHA-384 algorithm.
        # @!attribute [rw] sha512
        #   @return [String]
        #     A message digest produced with the SHA-512 algorithm.
        class Digest; end

        # Cloud KMS metadata for the given {Google::Cloud::Location::Location}.
        # @!attribute [rw] hsm_available
        #   @return [true, false]
        #     Indicates whether {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} with
        #     {Google::Cloud::Kms::V1::CryptoKeyVersionTemplate#protection_level protection_level}
        #     {Google::Cloud::Kms::V1::ProtectionLevel::HSM HSM} can be created in this location.
        class LocationMetadata; end
      end
    end
  end
end