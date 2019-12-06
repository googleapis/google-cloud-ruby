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
    module Tasks
      module V2beta3
        class CloudTasksClient
          # Alias for Google::Cloud::Tasks::V2beta3::CloudTasksClient.location_path.
          # @param project [String]
          # @param location [String]
          # @return [String]
          def location_path project, location
            self.class.location_path project, location
          end
          
          # Alias for Google::Cloud::Tasks::V2beta3::CloudTasksClient.queue_path.
          # @param project [String]
          # @param location [String]
          # @param queue [String]
          # @return [String]
          def queue_path project, location, queue
            self.class.queue_path project, location, queue
          end
          
          # Alias for Google::Cloud::Tasks::V2beta3::CloudTasksClient.task_path.
          # @param project [String]
          # @param location [String]
          # @param queue [String]
          # @param task [String]
          # @return [String]
          def task_path project, location, queue, task
            self.class.task_path project, location, queue, task
          end
        end
      end
    end
  end
end