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
        # A {Google::Cloud::Kms::V1::KeyRing KeyRing} is a toplevel logical grouping of {Google::Cloud::Kms::V1::CryptoKey CryptoKeys}.
        # @!attribute [rw] name
        #   @return [String]
        #     Output only. The resource name for the {Google::Cloud::Kms::V1::KeyRing KeyRing} in the format
        #     +projects/*/locations/*/keyRings/*+.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time at which this {Google::Cloud::Kms::V1::KeyRing KeyRing} was created.
        class KeyRing; end

        # A {Google::Cloud::Kms::V1::CryptoKey CryptoKey} represents a logical key that can be used for cryptographic
        # operations.
        #
        # A {Google::Cloud::Kms::V1::CryptoKey CryptoKey} is made up of one or more {Google::Cloud::Kms::V1::CryptoKeyVersion versions}, which
        # represent the actual key material used in cryptographic operations.
        # @!attribute [rw] name
        #   @return [String]
        #     Output only. The resource name for this {Google::Cloud::Kms::V1::CryptoKey CryptoKey} in the format
        #     +projects/*/locations/*/keyRings/*/cryptoKeys/*+.
        # @!attribute [rw] primary
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion]
        #     Output only. A copy of the "primary" {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} that will be used
        #     by {Google::Cloud::Kms::V1::KeyManagementService::Encrypt Encrypt} when this {Google::Cloud::Kms::V1::CryptoKey CryptoKey} is given
        #     in {Google::Cloud::Kms::V1::EncryptRequest#name EncryptRequest#name}.
        #
        #     The {Google::Cloud::Kms::V1::CryptoKey CryptoKey}'s primary version can be updated via
        #     {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyPrimaryVersion UpdateCryptoKeyPrimaryVersion}.
        # @!attribute [rw] purpose
        #   @return [Google::Cloud::Kms::V1::CryptoKey::CryptoKeyPurpose]
        #     The immutable purpose of this {Google::Cloud::Kms::V1::CryptoKey CryptoKey}. Currently, the only acceptable
        #     purpose is {Google::Cloud::Kms::V1::CryptoKey::CryptoKeyPurpose::ENCRYPT_DECRYPT ENCRYPT_DECRYPT}.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time at which this {Google::Cloud::Kms::V1::CryptoKey CryptoKey} was created.
        # @!attribute [rw] next_rotation_time
        #   @return [Google::Protobuf::Timestamp]
        #     At {Google::Cloud::Kms::V1::CryptoKey#next_rotation_time next_rotation_time}, the Key Management Service will automatically:
        #
        #     1. Create a new version of this {Google::Cloud::Kms::V1::CryptoKey CryptoKey}.
        #     2. Mark the new version as primary.
        #
        #     Key rotations performed manually via
        #     {Google::Cloud::Kms::V1::KeyManagementService::CreateCryptoKeyVersion CreateCryptoKeyVersion} and
        #     {Google::Cloud::Kms::V1::KeyManagementService::UpdateCryptoKeyPrimaryVersion UpdateCryptoKeyPrimaryVersion}
        #     do not affect {Google::Cloud::Kms::V1::CryptoKey#next_rotation_time next_rotation_time}.
        # @!attribute [rw] rotation_period
        #   @return [Google::Protobuf::Duration]
        #     {Google::Cloud::Kms::V1::CryptoKey#next_rotation_time next_rotation_time} will be advanced by this period when the service
        #     automatically rotates a key. Must be at least one day.
        #
        #     If {Google::Cloud::Kms::V1::CryptoKey#rotation_period rotation_period} is set, {Google::Cloud::Kms::V1::CryptoKey#next_rotation_time next_rotation_time} must also be set.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Labels with user-defined metadata. For more information, see
        #     [Labeling Keys](https://cloud.google.com/kms/docs/labeling-keys).
        class CryptoKey
          # {Google::Cloud::Kms::V1::CryptoKey::CryptoKeyPurpose CryptoKeyPurpose} describes the capabilities of a {Google::Cloud::Kms::V1::CryptoKey CryptoKey}. Two
          # keys with the same purpose may use different underlying algorithms, but
          # must support the same set of operations.
          module CryptoKeyPurpose
            # Not specified.
            CRYPTO_KEY_PURPOSE_UNSPECIFIED = 0

            # {Google::Cloud::Kms::V1::CryptoKey CryptoKeys} with this purpose may be used with
            # {Google::Cloud::Kms::V1::KeyManagementService::Encrypt Encrypt} and
            # {Google::Cloud::Kms::V1::KeyManagementService::Decrypt Decrypt}.
            ENCRYPT_DECRYPT = 1
          end
        end

        # A {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} represents an individual cryptographic key, and the
        # associated key material.
        #
        # It can be used for cryptographic operations either directly, or via its
        # parent {Google::Cloud::Kms::V1::CryptoKey CryptoKey}, in which case the server will choose the appropriate
        # version for the operation.
        #
        # For security reasons, the raw cryptographic key material represented by a
        # {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} can never be viewed or exported. It can only be used to
        # encrypt or decrypt data when an authorized user or application invokes Cloud
        # KMS.
        # @!attribute [rw] name
        #   @return [String]
        #     Output only. The resource name for this {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} in the format
        #     +projects/*/locations/*/keyRings/*/cryptoKeys/*/cryptoKeyVersions/*+.
        # @!attribute [rw] state
        #   @return [Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState]
        #     The current state of the {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}.
        # @!attribute [rw] create_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time at which this {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion} was created.
        # @!attribute [rw] destroy_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time this {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}'s key material is scheduled
        #     for destruction. Only present if {Google::Cloud::Kms::V1::CryptoKeyVersion#state state} is
        #     {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DESTROY_SCHEDULED DESTROY_SCHEDULED}.
        # @!attribute [rw] destroy_event_time
        #   @return [Google::Protobuf::Timestamp]
        #     Output only. The time this CryptoKeyVersion's key material was
        #     destroyed. Only present if {Google::Cloud::Kms::V1::CryptoKeyVersion#state state} is
        #     {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DESTROYED DESTROYED}.
        class CryptoKeyVersion
          # The state of a {Google::Cloud::Kms::V1::CryptoKeyVersion CryptoKeyVersion}, indicating if it can be used.
          module CryptoKeyVersionState
            # Not specified.
            CRYPTO_KEY_VERSION_STATE_UNSPECIFIED = 0

            # This version may be used in {Google::Cloud::Kms::V1::KeyManagementService::Encrypt Encrypt} and
            # {Google::Cloud::Kms::V1::KeyManagementService::Decrypt Decrypt} requests.
            ENABLED = 1

            # This version may not be used, but the key material is still available,
            # and the version can be placed back into the {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::ENABLED ENABLED} state.
            DISABLED = 2

            # This version is destroyed, and the key material is no longer stored.
            # A version may not leave this state once entered.
            DESTROYED = 3

            # This version is scheduled for destruction, and will be destroyed soon.
            # Call
            # {Google::Cloud::Kms::V1::KeyManagementService::RestoreCryptoKeyVersion RestoreCryptoKeyVersion}
            # to put it back into the {Google::Cloud::Kms::V1::CryptoKeyVersion::CryptoKeyVersionState::DISABLED DISABLED} state.
            DESTROY_SCHEDULED = 4
          end
        end
      end
    end
  end
end