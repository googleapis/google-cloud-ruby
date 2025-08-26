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
require "google/cloud/storage_batch_operations"

# [START storage_batch_list_job]
def list_job project_name:
  # The Name/ID of your project
  # project_name = "your-project-id"
  client = Google::Cloud::StorageBatchOperations.storage_batch_operations
  parent = "projects/#{project_name}/locations/global"
  request = Google::Cloud::StorageBatchOperations::V1::ListJobsRequest.new parent: parent, page_size: 10
  result = client.list_jobs request
  result.each do |job|
    puts "Job name: #{job.name}"
  end
end
# [END storage_batch_list_job]

list_job project_name: ARGV.shift if $PROGRAM_NAME == __FILE__
