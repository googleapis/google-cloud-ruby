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
def cancel_job parent:, job_name:
  # The parent location for your job
  # parent = "projects/your-project-id/locations/your-location"

  # The name of your Storage batch operation job
  # job_name = "your-job-name"

  require "google/cloud/storage_batch_operations/v1"

  client = Google::Cloud::StorageBatchOperations::V1::StorageBatchOperations::Client.new

  request = Google::Cloud::StorageBatchOperations::V1::CancelJobRequest.new name: "#{parent}/jobs/#{job_name}"
  result = client.cancel_job request
  puts result.is_a?(Google::Cloud::StorageBatchOperations::V1::CancelJobResponse) ? "The job is canceled." : "The job is not canceled."
end
# [END storage_batch_cancel_job]

cancel_job parent: ARGV.shift, job_name: ARGV.shift if $PROGRAM_NAME == __FILE__
