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

# [START storage_batch_create_job]
def create_job bucket_name:, prefix:, job_name:, project_name:
  # The ID of your GCS bucket
  # bucket_name = "your-unique-bucket-name"

  # Prefix is the first part of filename on which job has to be executed
  # prefix = 'test'

  # The Name/ID of your project
  # project_name = "your-project-id"

  # The name of your Storage batch operation job
  # job_name = "your-job-name"

  client = Google::Cloud::StorageBatchOperations.storage_batch_operations

  parent = "projects/#{project_name}/locations/global"

  prefix_list = Google::Cloud::StorageBatchOperations::V1::PrefixList.new(
    included_object_prefixes: [prefix]
  )

  bucket = Google::Cloud::StorageBatchOperations::V1::BucketList::Bucket.new(
    bucket: bucket_name,
    prefix_list: prefix_list
  )

  bucket_list = Google::Cloud::StorageBatchOperations::V1::BucketList.new(
    buckets: [bucket]
  )

  # Define the delete operation
  delete_object = Google::Cloud::StorageBatchOperations::V1::DeleteObject.new(
    permanent_object_deletion_enabled: false
  )

  # Build the job
  job = Google::Cloud::StorageBatchOperations::V1::Job.new(
    name: job_name,
    bucket_list: bucket_list,
    delete_object: delete_object
  )

  request = Google::Cloud::StorageBatchOperations::V1::CreateJobRequest.new parent: parent, job_id: job_name, job: job
  result = client.create_job request

  puts result.is_a?(Gapic::Operation) ? "The #{job_name} is created." : "The #{job_name} is not created."
end
# [END storage_batch_create_job]

if $PROGRAM_NAME == __FILE__
  create_job(
    bucket_name: ARGV.shift,
    prefix: ARGV.shift,
    job_name: ARGV.shift,
    project_name: ARGV.shift,
    job_type: ARGV.shift
  )
end
