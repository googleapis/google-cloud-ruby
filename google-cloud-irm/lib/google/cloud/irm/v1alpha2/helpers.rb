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
    module Irm
      module V1alpha2
        class IncidentServiceClient
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.annotation_path.
          # @param project [String]
          # @param incident [String]
          # @param annotation [String]
          # @return [String]
          def annotation_path project, incident, annotation
            self.class.annotation_path project, incident, annotation
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.artifact_path.
          # @param project [String]
          # @param incident [String]
          # @param artifact [String]
          # @return [String]
          def artifact_path project, incident, artifact
            self.class.artifact_path project, incident, artifact
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_path.
          # @param project [String]
          # @param incident [String]
          # @return [String]
          def incident_path project, incident
            self.class.incident_path project, incident
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.incident_role_assignment_path.
          # @param project_id_or_number [String]
          # @param incident_id [String]
          # @param role_id [String]
          # @return [String]
          def incident_role_assignment_path project_id_or_number, incident_id, role_id
            self.class.incident_role_assignment_path project_id_or_number, incident_id, role_id
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.project_path.
          # @param project [String]
          # @return [String]
          def project_path project
            self.class.project_path project
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.signal_path.
          # @param project [String]
          # @param signal [String]
          # @return [String]
          def signal_path project, signal
            self.class.signal_path project, signal
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.subscription_path.
          # @param project [String]
          # @param incident [String]
          # @param subscription [String]
          # @return [String]
          def subscription_path project, incident, subscription
            self.class.subscription_path project, incident, subscription
          end
          
          # Alias for Google::Cloud::Irm::V1alpha2::IncidentServiceClient.tag_path.
          # @param project [String]
          # @param incident [String]
          # @param tag [String]
          # @return [String]
          def tag_path project, incident, tag
            self.class.tag_path project, incident, tag
          end
        end
      end
    end
  end
end