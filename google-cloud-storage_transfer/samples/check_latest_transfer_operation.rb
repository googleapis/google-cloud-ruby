# Copyright 2024 Google LLC
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

# [START storagetransfer_get_latest_transfer_operation]
def check_latest_transfer_operation project_id:, job_name:
  # Your Google Cloud Project ID
  # project_id = "your-project_id"

  # Storage Transfer Service job name
  # job_name = 'transferJobs/1234567890'

  require "google/cloud/storage_transfer"

  client = Google::Cloud::StorageTransfer.storage_transfer_service

  job_request = {
    project_id: project_id,
    job_name: job_name
  }
  transfer_job = client.get_transfer_job job_request

  operation = client.operations_client.get_operation(
    {
      name: transfer_job.latest_operation_name
    }
  )
  if operation
    operation_status = operation.metadata.status
    puts "Latest transfer operation for #{job_name}: #{operation_status}"
  else
    puts "Transfer Job #{job_name} has not ran yet"
  end
end
# [END storagetransfer_get_latest_transfer_operation]

if $PROGRAM_NAME == __FILE__
  check_latest_transfer_operation project_id: ARGV.shift, job_name: ARGV.shift
end
