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
# # limitations under the License.
 module Google
  module Cloud
    module Kms
      module V1
        class KeyManagementServiceClient
          # Alias for Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_version_path.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key [String]
          # @param crypto_key_version [String]
          # @return [String]
          def crypto_key_version_path project, location, key_ring, crypto_key, crypto_key_version
            self.class.crypto_key_version_path project, location, key_ring, crypto_key, crypto_key_version
          end
          
          # Alias for Google::Cloud::Kms::V1::KeyManagementServiceClient.key_ring_path.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @return [String]
          def key_ring_path project, location, key_ring
            self.class.key_ring_path project, location, key_ring
          end
          
          # Alias for Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path_path.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key_path [String]
          # @return [String]
          def crypto_key_path_path project, location, key_ring, crypto_key_path
            self.class.crypto_key_path_path project, location, key_ring, crypto_key_path
          end
          
          # Alias for Google::Cloud::Kms::V1::KeyManagementServiceClient.crypto_key_path.
          # @param project [String]
          # @param location [String]
          # @param key_ring [String]
          # @param crypto_key [String]
          # @return [String]
          def crypto_key_path project, location, key_ring, crypto_key
            self.class.crypto_key_path project, location, key_ring, crypto_key
          end
          
          # Alias for Google::Cloud::Kms::V1::KeyManagementServiceClient.location_path.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def location_path project, location
            self.class.location_path project, location
          end
        end
      end
    end
  end
end