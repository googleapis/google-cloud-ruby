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

def delete_job project_name:, job_name:
  # The ID of your project
  # project_name = "your-project-id"

  # The name of your Storage batch operation job
  # job_name = "your-job-name"

  client = Google::Cloud::StorageBatchOperations.storage_batch_operations
  parent = "projects/#{project_name}/locations/global"
  request = Google::Cloud::StorageBatchOperations::V1::DeleteJobRequest.new name: "#{parent}/jobs/#{job_name}"
  result = client.delete_job request
  puts result.is_a?(Google::Protobuf::Empty) ? "The #{job_name} is deleted." : "The #{job_name} is not deleted."
end
# [END storage_batch_delete_job]

delete_job project_name: ARGV.shift, job_name: ARGV.shift if $PROGRAM_NAME == __FILE__
