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
    module Oslogin
      module V1
        # The user profile information used for logging in to a virtual machine on
        # Google Compute Engine.
        # @!attribute [rw] name
        #   @return [String]
        #     The primary email address that uniquely identifies the user.
        # @!attribute [rw] posix_accounts
        #   @return [Array<Google::Cloud::Oslogin::Common::PosixAccount>]
        #     The list of POSIX accounts associated with the user.
        # @!attribute [rw] ssh_public_keys
        #   @return [Hash{String => Google::Cloud::Oslogin::Common::SshPublicKey}]
        #     A map from SSH public key fingerprint to the associated key object.
        # @!attribute [rw] suspended
        #   @return [true, false]
        #     Indicates if the user is suspended. A suspended user cannot log in but
        #     their profile information is retained.
        class LoginProfile; end

        # A request message for deleting a POSIX account entry.
        # @!attribute [rw] name
        #   @return [String]
        #     A reference to the POSIX account to update. POSIX accounts are identified
        #     by the project ID they are associated with. A reference to the POSIX
        #     account is in format +users/\\{user}/projects/\\{project}+.
        class DeletePosixAccountRequest; end

        # A request message for deleting an SSH public key.
        # @!attribute [rw] name
        #   @return [String]
        #     The fingerprint of the public key to update. Public keys are identified by
        #     their SHA-256 fingerprint. The fingerprint of the public key is in format
        #     +users/\\{user}/sshPublicKeys/\\{fingerprint}+.
        class DeleteSshPublicKeyRequest; end

        # A request message for retrieving the login profile information for a user.
        # @!attribute [rw] name
        #   @return [String]
        #     The unique ID for the user in format +users/\\{user}+.
        class GetLoginProfileRequest; end

        # A request message for retrieving an SSH public key.
        # @!attribute [rw] name
        #   @return [String]
        #     The fingerprint of the public key to retrieve. Public keys are identified
        #     by their SHA-256 fingerprint. The fingerprint of the public key is in
        #     format +users/\\{user}/sshPublicKeys/\\{fingerprint}+.
        class GetSshPublicKeyRequest; end

        # A request message for importing an SSH public key.
        # @!attribute [rw] parent
        #   @return [String]
        #     The unique ID for the user in format +users/\\{user}+.
        # @!attribute [rw] ssh_public_key
        #   @return [Google::Cloud::Oslogin::Common::SshPublicKey]
        #     The SSH public key and expiration time.
        # @!attribute [rw] project_id
        #   @return [String]
        #     The project ID of the Google Cloud Platform project.
        class ImportSshPublicKeyRequest; end

        # A response message for importing an SSH public key.
        # @!attribute [rw] login_profile
        #   @return [Google::Cloud::Oslogin::V1::LoginProfile]
        #     The login profile information for the user.
        class ImportSshPublicKeyResponse; end

        # A request message for updating an SSH public key.
        # @!attribute [rw] name
        #   @return [String]
        #     The fingerprint of the public key to update. Public keys are identified by
        #     their SHA-256 fingerprint. The fingerprint of the public key is in format
        #     +users/\\{user}/sshPublicKeys/\\{fingerprint}+.
        # @!attribute [rw] ssh_public_key
        #   @return [Google::Cloud::Oslogin::Common::SshPublicKey]
        #     The SSH public key and expiration time.
        # @!attribute [rw] update_mask
        #   @return [Google::Protobuf::FieldMask]
        #     Mask to control which fields get updated. Updates all if not present.
        class UpdateSshPublicKeyRequest; end
      end
    end
  end
end