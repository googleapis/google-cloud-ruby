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
    module Scheduler
      module V1beta1
        class CloudSchedulerClient

          # Alias for Google::Cloud::Scheduler::V1beta1.location_path.
          # @param args [Array<String>]
          # @return [String]
          def location_path *args
            self.class.location_path *args
          end
          
          # Alias for Google::Cloud::Scheduler::V1beta1.job_path.
          # @param args [Array<String>]
          # @return [String]
          def job_path *args
            self.class.job_path *args
          end
          
          # Alias for Google::Cloud::Scheduler::V1beta1.project_path.
          # @param args [Array<String>]
          # @return [String]
          def project_path *args
            self.class.project_path *args
          end
         
        end
      end
    end
  end
end
