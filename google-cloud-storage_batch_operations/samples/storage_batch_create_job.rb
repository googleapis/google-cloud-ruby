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

# [START storage_batch_create_job]
require "google/cloud/storage_batch_operations"

# Creates a Storage Batch Operations job to delete objects in a bucket
# that match a given prefix. The deletion is a "soft delete", meaning
# objects can be recovered if versioning is enabled on the bucket.
#
# @param bucket_name [String] The name of the Google Cloud Storage bucket.
# @param prefix [String] The prefix of the objects to be included in the job.
#   The job will operate on all objects whose names start with this prefix.
# @param job_id [String] A unique identifier for the job.
# @param project_id [String] The ID of the Google Cloud project where the job will be created.
#
# @example
#   create_job(
#     bucket_name: "your-unique-bucket-name",
#     prefix: "test-files/",
#     job_id: "your-job-id",
#     project_id: "your-project-id"
#   )
#
def create_job bucket_name:, prefix:, job_id:, project_id:
  client = Google::Cloud::StorageBatchOperations.storage_batch_operations

  parent = "projects/#{project_id}/locations/global"

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
    bucket_list: bucket_list,
    delete_object: delete_object
  )

  request = Google::Cloud::StorageBatchOperations::V1::CreateJobRequest.new parent: parent, job_id: job_id, job: job
  create_job_operation = client.create_job request

  # To fetch job details using get_job to confirm creation
  get_request = Google::Cloud::StorageBatchOperations::V1::GetJobRequest.new name: "#{parent}/jobs/#{job_id}"

  begin
    ## Waiting for operation to complete
    create_job_operation.wait_until_done!
    ## Fetch the newly created job to confirm creation
    job_detail = client.get_job get_request
    message = "Storage Batch Operations job #{job_detail.name} is created."
  rescue StandardError
    # This error is thrown when the job is not created.
    message = "Failed to create job #{job_id}. Error: #{create_job_operation.error.message}"
  end
  puts message
end
# [END storage_batch_create_job]

if $PROGRAM_NAME == __FILE__
  create_job(
    bucket_name: ARGV.shift,
    prefix: ARGV.shift,
    job_id: ARGV.shift,
    project_id: ARGV.shift
  )
end
