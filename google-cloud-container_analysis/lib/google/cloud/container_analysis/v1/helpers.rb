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
    module ContainerAnalysis
      module V1
        class ContainerAnalysisClient
          # Returns a fully-qualified note resource name string.
          # @param project [String]
          # @param note [String]
          # @return [String]
          def self.note_path project, note
            "projects/#{project}/notes/#{note}"
          end

          # Returns a fully-qualified occurrence resource name string.
          # @param project [String]
          # @param occurrence [String]
          # @return [String]
          def self.occurrence_path project, occurrence
            "projects/#{project}/occurrences/#{occurrence}"
          end
        end
      end
    end
  end
end
