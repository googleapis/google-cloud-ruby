# Copyright 2017 Google LLC
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
      module Common
        # The POSIX account information associated with a Google account.
        # @!attribute [rw] primary
        #   @return [true, false]
        #     Only one POSIX account can be marked as primary.
        # @!attribute [rw] username
        #   @return [String]
        #     The username of the POSIX account.
        # @!attribute [rw] uid
        #   @return [Integer]
        #     The user ID.
        # @!attribute [rw] gid
        #   @return [Integer]
        #     The default group ID.
        # @!attribute [rw] home_directory
        #   @return [String]
        #     The path to the home directory for this account.
        # @!attribute [rw] shell
        #   @return [String]
        #     The path to the logic shell for this account.
        # @!attribute [rw] gecos
        #   @return [String]
        #     The GECOS (user information) entry for this account.
        # @!attribute [rw] system_id
        #   @return [String]
        #     System identifier for which account the username or uid applies to.
        #     By default, the empty value is used.
        # @!attribute [rw] account_id
        #   @return [String]
        #     Output only. A POSIX account identifier.
        class PosixAccount; end

        # The SSH public key information associated with a Google account.
        # @!attribute [rw] key
        #   @return [String]
        #     Public key text in SSH format, defined by
        #     <a href="https://www.ietf.org/rfc/rfc4253.txt" target="_blank">RFC4253</a>
        #     section 6.6.
        # @!attribute [rw] expiration_time_usec
        #   @return [Integer]
        #     An expiration time in microseconds since epoch.
        # @!attribute [rw] fingerprint
        #   @return [String]
        #     Output only. The SHA-256 fingerprint of the SSH public key.
        class SshPublicKey; end
      end
    end
  end
end