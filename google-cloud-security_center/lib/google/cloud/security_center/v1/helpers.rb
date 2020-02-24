# Copyright 2019 Google LLC
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
    module SecurityCenter
      module V1
        class SecurityCenterClient

          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.asset_security_marks_path.
          # @param organization [String]
          # @param asset [String]
          # @return [String]
          def asset_security_marks_path organization, asset
            self.class.asset_security_marks_path organization, asset
          end
          
          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_path.
          # @param organization [String]
          # @param source [String]
          # @param finding [String]
          # @return [String]
          def finding_path organization, source, finding
            self.class.finding_path organization, source, finding
          end
          
          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.finding_security_marks_path.
          # @param organization [String]
          # @param source [String]
          # @param finding [String]
          # @return [String]
          def finding_security_marks_path organization, source, finding
            self.class.finding_security_marks_path organization, source, finding
          end
          
          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_path.
          # @param organization [String]
          # @return [String]
          def organization_path organization
            self.class.organization_path organization
          end
          
          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.organization_settings_path.
          # @param organization [String]
          # @return [String]
          def organization_settings_path organization
            self.class.organization_settings_path organization
          end
          
          # Alias for Google::Cloud::SecurityCenter::V1::SecurityCenterClient.source_path.
          # @param organization [String]
          # @param source [String]
          # @return [String]
          def source_path organization, source
            self.class.source_path organization, source
          end
        end
      end
    end
  end
end
