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

# [START storage_batch_delete_job]
require "google/cloud/storage_batch_operations"

# Deletes a Storage Batch Operations job.
#
# @param project_id [String] The ID of your Google Cloud project.
# @param job_id [String] The ID of the Storage Batch Operations job to be deleted.
#
# @example
#   delete_job project_id: "your-project-id", job_id: "your-job-id"
#
def delete_job project_id:, job_id:
  client = Google::Cloud::StorageBatchOperations.storage_batch_operations
  parent = "projects/#{project_id}/locations/global"
  request = Google::Cloud::StorageBatchOperations::V1::DeleteJobRequest.new name: "#{parent}/jobs/#{job_id}"

  begin
    result = client.delete_job request
    message = "The #{job_id} is deleted."
  rescue StandardError
    # This error is thrown when the job is not deleted.
    message = "Failed to delete job #{job_id}. Error: #{result.error.message}"
  end
  puts message
end
# [END storage_batch_delete_job]

delete_job project_id: ARGV.shift, job_id: ARGV.shift if $PROGRAM_NAME == __FILE__
