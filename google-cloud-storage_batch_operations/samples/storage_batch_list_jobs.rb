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

# [START storage_batch_list_jobs]
require "google/cloud/storage_batch_operations"

# Lists Storage Batch Operations jobs for a given project.
#
# @param project_id [String] The ID of your Google Cloud project.
#
# @example
#   list_jobs project_id: "your-project-id"
#

def list_jobs project_id:

  client = Google::Cloud::StorageBatchOperations.storage_batch_operations
  parent = "projects/#{project_id}/locations/global"
  request = Google::Cloud::StorageBatchOperations::V1::ListJobsRequest.new parent: parent, page_size: 10
  job_list = client.list_jobs request
  job_list.each { |job| puts "Job name: #{job.name} present in the list" }
end
# [END storage_batch_list_jobs]

list_jobs project_id: ARGV.shift if $PROGRAM_NAME == __FILE__
