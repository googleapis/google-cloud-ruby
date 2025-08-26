# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START storage_batch_cancel_job]
require "google/cloud/storage_batch_operations"

def cancel_job project_id:, job_id:
  # The ID of your project
  # project_id = "your-project-id"

  # The ID of your Storage batch operation job
  # job_id = "your-job-id"

  client = Google::Cloud::StorageBatchOperations.storage_batch_operations
  parent = "projects/#{project_id}/locations/global"

  request = Google::Cloud::StorageBatchOperations::V1::CancelJobRequest.new name: "#{parent}/jobs/#{job_id}"
  result = client.cancel_job request
  message = if result.is_a? Google::Cloud::StorageBatchOperations::V1::CancelJobResponse
              "The #{job_id} is canceled."
            else
              "The #{job_id} is not canceled."
            end
  puts message
end
# [END storage_batch_cancel_job]

cancel_job project_id: ARGV.shift, job_id: ARGV.shift if $PROGRAM_NAME == __FILE__
