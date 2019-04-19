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
    module RecaptchaEnterprise
      module V1beta1
        class RecaptchaEnterpriseClient

          # Alias for Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.assessment_path.
          # @param project [String]
          # @param assessment [String]
          # @return [String]
          def assessment_path project, assessment
            self.class.assessment_path project, assessment
          end
          
          # Alias for Google::Cloud::RecaptchaEnterprise::V1beta1::RecaptchaEnterpriseClient.project_path.
          # @param project [String]
          # @return [String]
          def project_path project
            self.class.project_path project
          end
        end
      end
    end
  end
end
